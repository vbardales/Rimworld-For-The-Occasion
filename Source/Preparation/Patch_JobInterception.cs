using System;
using HarmonyLib;
using RimWorld;
using Verse;
using Verse.AI;

namespace ForTheOccasion
{
    /// <summary>
    /// The wardrobe detour, inserted ahead of the job the pawn was about to start.
    ///
    /// <c>JobGiver_OptimizeApparel</c> sits **below** the lord-duty node in the humanlike think
    /// tree (<c>Humanlike.xml</c>): during a ritual it never runs. Changing a participant's
    /// apparel policy would therefore produce strictly nothing. A job has to be inserted, and the
    /// only place that sees every job go past is <c>StartJob</c>.
    ///
    /// **Fail open, non-negotiable.** This prefix runs when every job of every pawn starts. An
    /// unhandled exception here is a bricked colony. Everything is inside try/catch, and the first
    /// exception cuts the mod off for the session.
    /// </summary>
    [HarmonyPatch(typeof(Pawn_JobTracker), nameof(Pawn_JobTracker.StartJob))]
    public static class Patch_JobInterception
    {
        /// <summary>
        /// Starting a job from inside a <c>StartJob</c> prefix re-enters the prefix. Without this
        /// guard, the detour would divert itself.
        /// </summary>
        static bool reentrant;

        /// <summary>
        /// One detour per pawn at most every 300 ticks. A pawn whose jobs keep getting interrupted
        /// would otherwise restart the wardrobe trip on every interruption without ever finishing
        /// it, and the detour would loop. No effect on the normal case, where the trip is a single
        /// job that does not come back through here.
        /// </summary>
        const int DivertCooldownTicks = 300;

        static readonly System.Collections.Generic.Dictionary<Pawn, int> lastDivert =
            new System.Collections.Generic.Dictionary<Pawn, int>();

        static bool OnCooldown(Pawn pawn)
        {
            int now = Find.TickManager.TicksGame;
            if (!lastDivert.TryGetValue(pawn, out int last)) return false;
            // Loading an older save in the same session rewinds the clock: the counter would end
            // up in the future and block the pawn until time caught up with it. Any rewind is
            // treated as an expiry.
            if (now < last) { lastDivert.Remove(pawn); return false; }
            return now - last < DivertCooldownTicks;
        }

        static void StampCooldown(Pawn pawn)
        {
            lastDivert[pawn] = Find.TickManager.TicksGame;
            // The dictionary only lives for the session; it is purged when it grows rather than
            // scribed, since a lost entry costs one extra detour and nothing more.
            if (lastDivert.Count > 200) lastDivert.Clear();
        }

        static bool Prefix(Pawn_JobTracker __instance, Pawn ___pawn, Job newJob,
            JobCondition lastJobEndCondition, bool resumeCurJobAfterwards, bool cancelBusyStances)
        {
            if (FtoLog.Disabled || reentrant) return true;

            try
            {
                return Decide(__instance, ___pawn, newJob, lastJobEndCondition, resumeCurJobAfterwards,
                    cancelBusyStances);
            }
            catch (Exception e)
            {
                FtoLog.Fail("Patch_JobInterception", e);
                return true;
            }
        }

        static bool Decide(Pawn_JobTracker tracker, Pawn pawn, Job newJob,
            JobCondition lastJobEndCondition, bool resumeCurJobAfterwards, bool cancelBusyStances)
        {
            if (!ForTheOccasionMod.Settings.preparationEnabled) return true;
            if (newJob == null || pawn == null || !pawn.Spawned || pawn.Map == null) return true;
            if (!pawn.RaceProps.Humanlike || pawn.Faction != Faction.OfPlayer) return true;
            if (newJob.def == FtoDefOf.FTO_PrepareForOccasion) return true;

            // The gates. Each one says: this pawn is in no state to be sent on a detour. Being
            // ordered about, being on the floor, not being themselves.
            if (pawn.Drafted || pawn.Downed || pawn.InMentalState) return true;
            // A direct order executes immediately, in both directions.
            if (newJob.playerForced) return true;
            // Emergency work givers exist because something cannot wait.
            if (newJob.workGiverDef != null && newJob.workGiverDef.emergency) return true;
            // A pawn lying down is a pawn left lying down: vanilla issues in-bed jobs on purpose.
            if (pawn.GetPosture() != PawnPosture.Standing) return true;

            PreparationRecord record = PreparationTracker.RecordFor(pawn);
            if (OnCooldown(pawn)) return true;

            // ---------------------------------------------------------------- return trip
            if (record != null && !PreparationReason.ShouldStayDressed(pawn))
            {
                // No-building path: free and on the spot. Dropping the force-worn flag is enough,
                // JobGiver_OptimizeApparel re-dresses the pawn on its own.
                if (!(record.stand is Building_OutfitStand stand) || !stand.Spawned || stand.Destroyed)
                {
                    CeremonialWardrobe.Undress(pawn, record);
                    return true;
                }

                if (!pawn.CanReserveAndReach(stand, PathEndMode.InteractionCell, Danger.Deadly))
                {
                    // The stand has become unreachable: hand the outfit back to the apparel policy
                    // rather than leaving the pawn in costume forever.
                    CeremonialWardrobe.Undress(pawn, record);
                    return true;
                }

                Job back = JobMaker.MakeJob(FtoDefOf.FTO_PrepareForOccasion, stand);
                back.count = 1;
                return Divert(tracker, pawn, newJob, back, lastJobEndCondition, resumeCurJobAfterwards,
                    cancelBusyStances);
            }

            // ---------------------------------------------------------------- danger
            // The danger gate sits **above the dress paths and below the return trip**. Placed
            // above both, a raid would freeze everyone in evening dress with no way to walk back
            // for their flak vest: that is the lesson Shift Change learned in play. Here it means
            // no changing *into* ceremonial clothes under threat, not no changing at all.
            if (pawn.Map.dangerWatcher.DangerRating != StoryDanger.None) return true;

            // ---------------------------------------------------------------- dressing
            if (record == null && PreparationReason.WantsToDress(pawn, out float maxDistance))
            {
                PrepPlan plan = CeremonialWardrobe.TryPlan(pawn, maxDistance);
                if (plan == null)
                {
                    // Nothing to wear: clear the mark so we do not replan on every single job.
                    PreparationTracker.ClearPending(pawn);
                    return true;
                }

                Job dress = JobMaker.MakeJob(FtoDefOf.FTO_PrepareForOccasion, plan.Target);
                dress.count = 0;
                PreparationTracker.ClearPending(pawn);
                return Divert(tracker, pawn, newJob, dress, lastJobEndCondition, resumeCurJobAfterwards,
                    cancelBusyStances);
            }

            return true;
        }

        /// <summary>
        /// Inserts <paramref name="detour"/> ahead of <paramref name="deferred"/>. The pattern is
        /// vanilla's own, which slips its opportunistic hauls in the same way
        /// (<c>Pawn_JobTracker.cs</c>, the <c>TryOpportunisticJob</c> path):
        ///
        /// 1. **Reserve the deferred job's targets.** Vanilla reserves inside <c>StartJob</c>,
        ///    which we skip: without this, the targets would sit free for the whole trip and
        ///    another pawn could take them. The reservation is made with <c>curJob</c> temporarily
        ///    set to the deferred job, because several drivers reserve against <c>pawn.CurJob</c>
        ///    rather than against their own field.
        /// 2. **Start the detour first, enqueue the original second.** If the detour threw after
        ///    the enqueue, the fail-open catch would let the original start as well: one Job object
        ///    in two places. <c>StartJob</c> never reads the queue, so enqueueing afterwards is
        ///    equivalent on success and safer on failure.
        /// </summary>
        static bool Divert(Pawn_JobTracker tracker, Pawn pawn, Job deferred, Job detour,
            JobCondition lastJobEndCondition, bool resumeCurJobAfterwards, bool cancelBusyStances)
        {
            reentrant = true;
            StampCooldown(pawn);
            try
            {
                Job savedJob = tracker.curJob;
                JobDriver savedDriver = tracker.curDriver;
                try
                {
                    tracker.curJob = deferred;
                    tracker.curDriver = deferred.MakeDriver(pawn);
                    tracker.curDriver.TryMakePreToilReservations(false);
                }
                catch (Exception e)
                {
                    FtoLog.WarnOnce("reserve", "could not pre-reserve a deferred job: " + e.Message);
                }
                finally
                {
                    tracker.curJob = savedJob;
                    tracker.curDriver = savedDriver;
                }

                bool started = false;
                try
                {
                    tracker.StartJob(detour, lastJobEndCondition, null, resumeCurJobAfterwards,
                        cancelBusyStances);
                    started = true;
                    tracker.jobQueue.EnqueueFirst(deferred);
                }
                catch (Exception e)
                {
                    FtoLog.Fail("Patch_JobInterception.Divert", e);
                    // The detour has started: letting the original start too would put one Job
                    // object in two places. We hand back without restarting it.
                    if (!started) return true;
                }
                return false;
            }
            finally
            {
                reentrant = false;
            }
        }
    }
}

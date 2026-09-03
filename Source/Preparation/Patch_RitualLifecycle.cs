using System;
using HarmonyLib;
using RimWorld;
using Verse;
using Verse.AI.Group;

namespace ForTheOccasion
{
    /// <summary>
    /// "A ritual begins": a postfix on <c>RitualBehaviorWorker.TryExecuteOn</c>.
    ///
    /// This is the hook, and there is no other. It is where the lord is created
    /// (<c>LordMaker.MakeNewLord</c>) and then <c>PreparePawns</c> is called: the pawns belong to
    /// the ritual from that instant, and the participant list is complete.
    /// </summary>
    [HarmonyPatch(typeof(RitualBehaviorWorker), nameof(RitualBehaviorWorker.TryExecuteOn))]
    public static class Patch_RitualStarted
    {
        /// <summary>
        /// One game hour for the mark to be picked up. A busy pawn does not necessarily start a
        /// new job within the second; past that delay the ritual is too far along for a detour to
        /// be worth taking anyway.
        /// </summary>
        const int PendingTicks = 2500;

        static void Postfix(TargetInfo target, Precept_Ritual ritual, RitualRoleAssignments assignments)
        {
            if (FtoLog.Disabled) return;
            try
            {
                FtoSettings s = ForTheOccasionMod.Settings;
                if (!s.preparationEnabled || !s.prepareOnLaunch) return;
                if (assignments?.Participants == null) return;

                int until = Find.TickManager.TicksGame + PendingTicks;
                foreach (Pawn p in assignments.Participants)
                {
                    if (p == null || !p.Spawned || !p.RaceProps.Humanlike) continue;
                    if (PreparationTracker.IsPrepared(p)) continue;
                    PreparationTracker.MarkPending(p, until);
                }
            }
            catch (Exception e)
            {
                FtoLog.Fail("Patch_RitualStarted", e);
            }
        }
    }

    /// <summary>
    /// Consuming the offerings when the ritual ends.
    ///
    /// Without consumption you would build the table once and **every** ritual in the game would
    /// be better forever. This step is what makes the mechanic honest.
    ///
    /// The prefix reads <c>ended</c> before the method sets it: <c>ApplyOutcome</c> can be called
    /// twice and returns immediately the second time. Without that reading, the second call would
    /// consume a second time.
    ///
    /// <c>LordJob_Ritual_Duel</c> overrides <c>ApplyOutcome</c>, but its body ends with an
    /// unconditional <c>base.ApplyOutcome(...)</c>: the hook placed on the base method is
    /// therefore reached for duels as well.
    /// </summary>
    [HarmonyPatch(typeof(LordJob_Ritual), nameof(LordJob_Ritual.ApplyOutcome))]
    public static class Patch_ConsumeOfferings
    {
        static AccessTools.FieldRef<LordJob_Ritual, bool> endedRef;

        internal static void Init()
        {
            endedRef = AccessTools.FieldRefAccess<LordJob_Ritual, bool>("ended");
        }

        static void Prefix(LordJob_Ritual __instance, out bool __state)
        {
            __state = true;
            try
            {
                if (endedRef != null) __state = endedRef(__instance);
            }
            catch (Exception e)
            {
                FtoLog.WarnOnce("ended", "could not read LordJob_Ritual.ended: " + e.Message
                                         + " -- offerings will not be consumed.");
            }
        }

        static void Postfix(LordJob_Ritual __instance, bool cancelled, bool __state)
        {
            if (FtoLog.Disabled) return;
            try
            {
                if (__state) return;                                   // already ended: nothing to do
                if (cancelled) return;                                 // cancelled: we take nothing
                if (!ForTheOccasionMod.Settings.offeringsEnabled) return;
                if (__instance.Map == null) return;

                int consumed = OfferingScan.Consume(__instance.Spot, __instance.Map);
                if (consumed > 0)
                    Messages.Message("FTO_OfferingsConsumed".Translate(consumed),
                        new TargetInfo(__instance.Spot, __instance.Map), MessageTypeDefOf.NeutralEvent, false);
            }
            catch (Exception e)
            {
                FtoLog.Fail("Patch_ConsumeOfferings", e);
            }
        }
    }

    /// <summary>
    /// Reaping the records when vanilla considers ownership to have ended.
    ///
    /// <c>Pawn_Ownership.UnclaimAll</c> is called on death, trade, kidnapping and map exit, but it
    /// does not walk the <c>CompAssignableToPawn</c> buildings: it frees a hardcoded list (bed,
    /// grave, throne, deathrest casket). A postfix extends the same moment to the preparation
    /// records.
    /// </summary>
    [HarmonyPatch(typeof(Pawn_Ownership), nameof(Pawn_Ownership.UnclaimAll))]
    public static class Patch_UnclaimAll
    {
        static void Postfix(Pawn ___pawn)
        {
            if (FtoLog.Disabled) return;
            try
            {
                PreparationTracker.Reap(___pawn);
            }
            catch (Exception e)
            {
                FtoLog.Fail("Patch_UnclaimAll", e);
            }
        }
    }

    /// <summary>
    /// Banishment is not on that list, and does not join it afterwards either:
    /// <c>PawnBanishUtility.Banish</c> clears guest status and then calls <c>SetFaction(null)</c>,
    /// which reaches no <c>UnclaimAll</c>; and the map-exit route rescues nothing, its
    /// <c>UnclaimAll</c> being gated on a flag that clearing the guest status has already made
    /// false. The colonist would walk away alive, with the outfit, and the record behind them.
    /// </summary>
    [HarmonyPatch(typeof(PawnBanishUtility), nameof(PawnBanishUtility.Banish),
        new[] { typeof(Pawn), typeof(RimWorld.Planet.PlanetTile), typeof(bool) })]
    public static class Patch_Banish
    {
        static void Postfix(Pawn pawn)
        {
            if (FtoLog.Disabled) return;
            try
            {
                PreparationTracker.Reap(pawn);
            }
            catch (Exception e)
            {
                FtoLog.Fail("Patch_Banish", e);
            }
        }
    }
}

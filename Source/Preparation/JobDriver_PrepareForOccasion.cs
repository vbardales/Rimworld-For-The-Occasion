using System;
using System.Collections.Generic;
using RimWorld;
using Verse;
using Verse.AI;

namespace ForTheOccasion
{
    /// <summary>
    /// The wardrobe trip. One driver for both directions: <c>job.count</c> is 0 to dress, 1 to
    /// change back.
    ///
    /// Target A is the stand, or the ceremonial garment on the no-building path. The duration is
    /// the sum of the relevant <c>EquipDelay</c>s, as in <c>JobDriver_Wear</c> and
    /// <c>JobDriver_UseOutfitStand</c>.
    /// </summary>
    public class JobDriver_PrepareForOccasion : JobDriver
    {
        int duration;

        bool Undressing => job.count == 1;

        public override void ExposeData()
        {
            base.ExposeData();
            Scribe_Values.Look(ref duration, "duration", 0);
        }

        public override bool TryMakePreToilReservations(bool errorOnFailed)
        {
            return pawn.Reserve(job.targetA, job, 1, -1, null, errorOnFailed);
        }

        public override void Notify_Starting()
        {
            base.Notify_Starting();
            duration = EstimateDuration();
        }

        int EstimateDuration()
        {
            int total = 0;
            Thing target = job.targetA.Thing;

            if (target is Building_OutfitStand stand)
            {
                foreach (Thing t in stand.HeldItems)
                    if (t is Apparel a) total += (int)(a.GetStatValue(StatDefOf.EquipDelay) * 60f);
            }
            else if (target is Apparel apparel)
            {
                total += (int)(apparel.GetStatValue(StatDefOf.EquipDelay) * 60f);
            }

            if (Undressing)
            {
                PreparationRecord record = PreparationTracker.RecordFor(pawn);
                if (record != null)
                    foreach (Apparel a in record.taken)
                        if (a != null && !a.Destroyed) total += (int)(a.GetStatValue(StatDefOf.EquipDelay) * 60f);
            }

            return Math.Max(60, total);
        }

        protected override IEnumerable<Toil> MakeNewToils()
        {
            this.FailOnBurningImmobile(TargetIndex.A);

            bool toStand = job.targetA.Thing is Building_OutfitStand;
            yield return Toils_Goto.GotoThing(TargetIndex.A,
                    toStand ? PathEndMode.InteractionCell : PathEndMode.ClosestTouch)
                .FailOnDespawnedNullOrForbidden(TargetIndex.A);

            Toil wait = ToilMaker.MakeToil("FTO_PrepareDelay");
            wait.WithProgressBarToilDelay(TargetIndex.A);
            wait.FailOnDespawnedNullOrForbidden(TargetIndex.A);
            wait.defaultCompleteMode = ToilCompleteMode.Delay;
            wait.defaultDuration = duration;
            yield return wait;

            // A single switching point, as a finish action: if the trip fails before it, nothing
            // has moved and the pawn stays dressed exactly as they were.
            yield return Toils_General.Do(DoChange);
        }

        void DoChange()
        {
            try
            {
                if (Undressing)
                {
                    PreparationRecord record = PreparationTracker.RecordFor(pawn);
                    if (record != null) CeremonialWardrobe.Undress(pawn, record);
                    return;
                }

                PrepPlan plan = job.targetA.Thing is Building_OutfitStand stand
                    ? new PrepPlan { stand = stand }
                    : new PrepPlan { apparel = job.targetA.Thing as Apparel };

                PreparationRecord fresh = CeremonialWardrobe.Dress(pawn, plan);
                if (fresh != null) PreparationTracker.Register(pawn, fresh);
            }
            catch (Exception e)
            {
                // Fail open: a wardrobe failure must not take the pawn's job down with it.
                FtoLog.Fail("JobDriver_PrepareForOccasion.DoChange", e);
            }
        }
    }
}

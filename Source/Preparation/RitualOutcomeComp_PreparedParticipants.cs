using System.Collections.Generic;
using System.Linq;
using RimWorld;
using UnityEngine;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// The quality bonus from **prepared** participants: in ceremonial clothes, and adorned where
    /// they could be.
    ///
    /// One comp for clothes and adornment together, not two. One comp is one number in the quality
    /// budget and one figure for the player to read; two comps would give two lines saying the
    /// same thing, and two chances to blow the cap.
    ///
    /// Modelled on <c>RitualOutcomeComp_ParticipantCount</c>: it ticks, accumulates presence time
    /// per pawn, and keeps only those present for at least half the duration. The difference is a
    /// single extra test - the presence has to have been *prepared*.
    /// </summary>
    public class RitualOutcomeComp_PreparedParticipants : RitualOutcomeComp_Quality
    {
        /// <summary>The label comes from the translation keys, set at startup: label is protected.</summary>
        public void SetLabel(string s) { label = s; }

        /// <summary>
        /// A **vanilla** type on purpose: compDatas are scribed into the save. A class of our own
        /// in there would leave an unreadable node behind the day the mod is uninstalled.
        /// </summary>
        public override RitualOutcomeComp_Data MakeData() => new RitualOutcomeComp_DataThingPresence();

        public override bool Applies(LordJob_Ritual ritual)
        {
            return ForTheOccasionMod.Settings.preparationEnabled;
        }

        public override void Tick(LordJob_Ritual ritual, RitualOutcomeComp_Data data, float progressAmount)
        {
            base.Tick(ritual, data, progressAmount);
            if (!ForTheOccasionMod.Settings.preparationEnabled) return;
            if (!(data is RitualOutcomeComp_DataThingPresence presence)) return;

            foreach (Pawn p in ritual.PawnsToCountTowardsPresence)
            {
                if (!Counts(ritual.assignments, p)) continue;
                if (!PreparationTracker.IsPrepared(p)) continue;
                if (!GatheringsUtility.InGatheringArea(p.Position, ritual.Spot, p.MapHeld)) continue;

                if (!presence.presentForTicks.ContainsKey(p)) presence.presentForTicks.Add(p, 0f);
                presence.presentForTicks[p] += progressAmount;
            }
        }

        public override float Count(LordJob_Ritual ritual, RitualOutcomeComp_Data data)
        {
            if (!(data is RitualOutcomeComp_DataThingPresence presence)) return 0f;
            float target = ritual.DurationTicks != 0 ? ritual.DurationTicks : ritual.TicksPassedWithProgress;
            int num = 0;
            foreach (KeyValuePair<Thing, float> pair in presence.presentForTicks)
            {
                if (pair.Key is Pawn p && Counts(ritual.assignments, p) && pair.Value >= target / 2f) num++;
            }
            return curve != null ? Mathf.Min(num, curve.Points[curve.PointsCount - 1].x) : num;
        }

        /// <summary>Same filter as vanilla: a role that does not count as a participant does not count here either.</summary>
        static bool Counts(RitualRoleAssignments assignments, Pawn p)
        {
            if (p == null || !p.RaceProps.Humanlike) return false;
            RitualRole role = assignments?.RoleForPawn(p);
            if (role != null && !role.countsAsParticipant) return false;
            return true;
        }

        public override QualityFactor GetQualityFactor(Precept_Ritual ritual, TargetInfo ritualTarget,
            RitualObligation obligation, RitualRoleAssignments assignments, RitualOutcomeComp_Data data)
        {
            if (!ForTheOccasionMod.Settings.preparationEnabled || assignments == null) return null;

            // What the Begin ritual window shows is the state at this instant: how many
            // participants are *already* ready. On a ritual launched cold that is zero, and that
            // is exact - they will get ready afterwards, paying in progress.
            int ready = assignments.Participants.Count(p => Counts(assignments, p) && PreparationTracker.IsPrepared(p));
            float quality = curve.Evaluate(ready);

            return new QualityFactor
            {
                label = "FTO_PreparedFactor".Translate(),
                count = ready + " / " + Mathf.Max(MaxValue, ready),
                qualityChange = ExpectedOffsetDesc(true, quality),
                quality = quality,
                positive = ready > 0,
                toolTip = "FTO_PreparedTooltip".Translate(),
                priority = 3.5f
            };
        }
    }
}

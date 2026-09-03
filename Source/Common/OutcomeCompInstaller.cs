using System;
using System.Collections.Generic;
using RimWorld;
using UnityEngine;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// Attaches the two quality comps to the ritual outcome defs of the game and of other mods.
    ///
    /// **Why in C# rather than by XML patch.** PatchOperations are applied before def inheritance
    /// is resolved, and an XML list *merges* with its parent's rather than replacing it
    /// (<c>XmlInheritance.RecursiveNodeCopyOverwriteElements</c> appends the child's <c>li</c>
    /// elements to the parent's). Several concrete ritual outcome defs inherit from another
    /// *concrete* one - <c>TrialMentalState</c> from <c>Trial</c>, the three
    /// <c>DestroyConsumableBuilding_*</c> from <c>DestroyConsumableBuilding</c>. An xpath catching
    /// both parent and child would therefore install the comp **twice** in the child and count the
    /// bonus twice: precisely the cap-busting this design exists to avoid. Walking the def
    /// database once it is resolved removes the problem, picks up other mods' outcome defs without
    /// naming them, and lets the settings slider rescale the curves live.
    /// </summary>
    [StaticConstructorOnStartup]
    public static class OutcomeCompInstaller
    {
        /// <summary>Maximum offerings budget, at slider 1.0.</summary>
        public const float OfferingsMax = 0.12f;

        /// <summary>Maximum preparation budget, at slider 1.0.</summary>
        public const float PreparedMax = 0.13f;

        static readonly List<RitualOutcomeComp_Offerings> offeringComps = new List<RitualOutcomeComp_Offerings>();
        static readonly List<RitualOutcomeComp_PreparedParticipants> preparedComps = new List<RitualOutcomeComp_PreparedParticipants>();

        static OutcomeCompInstaller()
        {
            try
            {
                int count = 0;
                foreach (RitualOutcomeEffectDef def in DefDatabase<RitualOutcomeEffectDef>.AllDefs)
                {
                    // Only workers deriving from FromQuality read quality comps. RoleChange and the
                    // two GiveMemory* workers have no quality at all: giving them a comp would only
                    // make it tick for nothing.
                    if (def.workerClass == null) continue;
                    if (!typeof(RitualOutcomeEffectWorker_FromQuality).IsAssignableFrom(def.workerClass)) continue;

                    if (def.comps == null) def.comps = new List<RitualOutcomeComp>();

                    RitualOutcomeComp_Offerings offerings = new RitualOutcomeComp_Offerings();
                    RitualOutcomeComp_PreparedParticipants prepared = new RitualOutcomeComp_PreparedParticipants();
                    offeringComps.Add(offerings);
                    preparedComps.Add(prepared);

                    // Appended at the end of the list: RitualOutcomeEffectWorker.DataForComp indexes
                    // by position, and an older save rebuilds itself (FillCompData starts over as
                    // soon as the two counts differ).
                    def.comps.Add(offerings);
                    def.comps.Add(prepared);
                    count++;
                }

                RescaleCurves();
                FtoLog.Message($"quality comps installed on {count} ritual outcome defs; "
                               + $"{OfferingScan.CategoryCount} offering categories loaded.");
            }
            catch (Exception e)
            {
                FtoLog.Fail("OutcomeCompInstaller", e);
            }
        }

        /// <summary>Replays both curves from the budget slider in the settings.</summary>
        public static void RescaleCurves()
        {
            float budget = ForTheOccasionMod.Settings.qualityBudget;

            SimpleCurve offeringCurve = OfferingCurve(OfferingsMax * budget);
            foreach (RitualOutcomeComp_Offerings c in offeringComps)
            {
                c.curve = offeringCurve;
                c.SetLabel("FTO_OfferingsFactor".Translate());
            }

            SimpleCurve preparedCurve = PreparedCurve(PreparedMax * budget);
            foreach (RitualOutcomeComp_PreparedParticipants c in preparedComps)
            {
                c.curve = preparedCurve;
                c.SetLabel("FTO_PreparedFactor".Translate());
            }
        }

        /// <summary>
        /// Diminishing returns on the number of distinct categories. With the four categories that
        /// ship, the points are exactly 0 / 4 / 7 / 10 / 12 %. A mod adding a category does not
        /// move the ceiling: the same curve is simply stretched.
        /// </summary>
        static SimpleCurve OfferingCurve(float max)
        {
            int n = Mathf.Max(1, OfferingScan.CategoryCount);
            SimpleCurve curve = new SimpleCurve();
            if (n == 4)
            {
                curve.Add(new CurvePoint(0f, 0f), false);
                curve.Add(new CurvePoint(1f, max * 0.3333f), false);
                curve.Add(new CurvePoint(2f, max * 0.5833f), false);
                curve.Add(new CurvePoint(3f, max * 0.8333f), false);
                curve.Add(new CurvePoint(4f, max), false);
            }
            else
            {
                for (int i = 0; i <= n; i++)
                    curve.Add(new CurvePoint(i, max * (1f - Mathf.Pow(1f - (float)i / n, 1.6f))), false);
            }
            curve.SortPoints();
            return curve;
        }

        /// <summary>
        /// The number of prepared participants. Capped at six: past that, a ceremony is not more
        /// beautiful because more people are dressed for it, and the cap bounds the budget.
        /// </summary>
        static SimpleCurve PreparedCurve(float max)
        {
            SimpleCurve curve = new SimpleCurve();
            curve.Add(new CurvePoint(0f, 0f), false);
            curve.Add(new CurvePoint(1f, max * 0.3077f), false);
            curve.Add(new CurvePoint(2f, max * 0.5385f), false);
            curve.Add(new CurvePoint(4f, max * 0.7692f), false);
            curve.Add(new CurvePoint(6f, max), false);
            curve.SortPoints();
            return curve;
        }
    }
}

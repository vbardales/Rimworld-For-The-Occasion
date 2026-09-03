using System.Collections.Generic;
using System.Text;
using RimWorld;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// The quality bonus from offerings laid out on offering tables inside the gathering area.
    ///
    /// Only comps deriving from <c>RitualOutcomeComp_Quality</c> enter the game's calculation
    /// (<c>RitualOutcomeEffectWorker_FromQuality.GetQuality</c> tests the type), hence this base
    /// rather than <c>RitualOutcomeComp</c>.
    /// </summary>
    public class RitualOutcomeComp_Offerings : RitualOutcomeComp_Quality
    {
        /// <summary>The label comes from the translation keys, set at startup: label is protected.</summary>
        public void SetLabel(string s) { label = s; }

        /// <summary>Nothing to accumulate: the count is read off the map when it is asked for.</summary>
        public override bool DataRequired => false;

        public override RitualOutcomeComp_Data MakeData() => null;

        /// <summary>
        /// The only switch this comp needs: a comp that does not apply is ignored by the quality
        /// calculation as though it did not exist.
        /// </summary>
        public override bool Applies(LordJob_Ritual ritual)
        {
            return ForTheOccasionMod.Settings.offeringsEnabled;
        }

        public override float Count(LordJob_Ritual ritual, RitualOutcomeComp_Data data)
        {
            if (ritual == null || ritual.Map == null) return 0f;
            return OfferingScan.CountSatisfied(ritual.Spot, ritual.Map);
        }

        public override QualityFactor GetQualityFactor(Precept_Ritual ritual, TargetInfo ritualTarget,
            RitualObligation obligation, RitualRoleAssignments assignments, RitualOutcomeComp_Data data)
        {
            if (!ForTheOccasionMod.Settings.offeringsEnabled || ritualTarget.Map == null) return null;

            List<KeyValuePair<OfferingCategoryDef, List<Thing>>> satisfied =
                OfferingScan.Satisfied(ritualTarget.Cell, ritualTarget.Map);
            int max = OfferingScan.CategoryCount;
            float quality = curve.Evaluate(satisfied.Count);

            return new QualityFactor
            {
                label = "FTO_OfferingsFactor".Translate(),
                count = satisfied.Count + " / " + max,
                qualityChange = ExpectedOffsetDesc(true, quality),
                quality = quality,
                positive = satisfied.Count > 0,
                toolTip = ToolTip(satisfied),
                priority = 3f
            };
        }

        static string ToolTip(List<KeyValuePair<OfferingCategoryDef, List<Thing>>> satisfied)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("FTO_OfferingsTooltip".Translate());
            foreach (OfferingCategoryDef cat in OfferingScan.Categories)
            {
                bool present = satisfied.Exists(p => p.Key == cat);
                sb.AppendLine("  " + (present ? "\u2713 " : "\u2717 ") + cat.LabelCap
                              + " (" + cat.countRequired + ")");
            }
            return sb.ToString().TrimEndNewlines();
        }
    }
}

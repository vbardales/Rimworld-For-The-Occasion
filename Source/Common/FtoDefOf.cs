using RimWorld;
using Verse;

namespace ForTheOccasion
{
    [DefOf]
    public static class FtoDefOf
    {
        public static JobDef FTO_PrepareForOccasion;

        /// <summary>The offering table shipped by this mod.</summary>
        public static ThingDef FTO_OfferingTable;

        static FtoDefOf()
        {
            DefOfHelper.EnsureInitializedInCtor(typeof(FtoDefOf));
        }
    }
}

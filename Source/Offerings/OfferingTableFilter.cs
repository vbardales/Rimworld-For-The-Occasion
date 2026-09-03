using System;
using System.Collections.Generic;
using RimWorld;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// Builds the offering table's fixed storage filter from the union of the
    /// <see cref="OfferingCategoryDef"/>s, at startup.
    ///
    /// The list of acceptable items therefore exists **exactly once**: in the categories. The
    /// table's def does not duplicate it, and a category added by another mod automatically makes
    /// its items storable here. A hand-written fixed filter would eventually drift, and the worst
    /// case of that drift is an offering the game counts but the player cannot put down.
    /// </summary>
    [StaticConstructorOnStartup]
    public static class OfferingTableFilter
    {
        static OfferingTableFilter()
        {
            try
            {
                ThingDef table = FtoDefOf.FTO_OfferingTable;
                if (table?.building?.fixedStorageSettings?.filter == null)
                {
                    FtoLog.WarnOnce("table", "the offering table def has no fixed storage filter.");
                    return;
                }

                ThingFilter fixedFilter = table.building.fixedStorageSettings.filter;
                ThingFilter defaultFilter = table.building.defaultStorageSettings?.filter;

                int allowed = 0;
                HashSet<ThingDef> seen = new HashSet<ThingDef>();

                foreach (OfferingCategoryDef cat in OfferingScan.Categories)
                {
                    if (cat.filter == null) continue;
                    foreach (ThingDef d in cat.filter.AllowedThingDefs)
                    {
                        if (d == null || !seen.Add(d)) continue;
                        fixedFilter.SetAllow(d, true);
                        defaultFilter?.SetAllow(d, true);
                        allowed++;
                    }
                }

                FtoLog.Message($"offering table accepts {allowed} thing defs from "
                               + $"{OfferingScan.CategoryCount} categories.");
            }
            catch (Exception e)
            {
                FtoLog.Fail("OfferingTableFilter", e);
            }
        }
    }
}

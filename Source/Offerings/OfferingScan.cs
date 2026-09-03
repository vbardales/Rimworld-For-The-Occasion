using System.Collections.Generic;
using System.Linq;
using RimWorld;
using Verse;

namespace ForTheOccasion
{
    /// <summary>What an offering table carries, and what is left of it after the ritual.</summary>
    public static class OfferingScan
    {
        static List<OfferingCategoryDef> categoriesCache;

        public static List<OfferingCategoryDef> Categories =>
            categoriesCache ?? (categoriesCache = DefDatabase<OfferingCategoryDef>.AllDefsListForReading
                .OrderBy(d => d.uiOrder).ToList());

        /// <summary>Maximum number of categories, hence the curve's last useful abscissa.</summary>
        public static int CategoryCount => Categories.Count;

        /// <summary>
        /// The offering tables inside the gathering area. The area is the game's own: the whole
        /// room when it qualifies, otherwise a radius of 18 cells
        /// (<c>GatheringsUtility.InGatheringArea</c>).
        /// </summary>
        public static IEnumerable<Building_Storage> TablesNear(IntVec3 spot, Map map)
        {
            if (map == null || FtoDefOf.FTO_OfferingTable == null) yield break;
            foreach (Thing t in map.listerThings.ThingsOfDef(FtoDefOf.FTO_OfferingTable))
            {
                if (t is Building_Storage table && t.Spawned && GatheringsUtility.InGatheringArea(t.Position, spot, map))
                    yield return table;
            }
        }

        /// <summary>Everything sitting on the area's offering tables.</summary>
        public static List<Thing> ThingsOnTables(IntVec3 spot, Map map)
        {
            List<Thing> result = new List<Thing>();
            foreach (Building_Storage table in TablesNear(spot, map))
            {
                SlotGroup group = table.GetSlotGroup();
                if (group == null) continue;
                foreach (Thing t in group.HeldThings)
                    if (!result.Contains(t)) result.Add(t);
            }
            return result;
        }

        /// <summary>The categories actually satisfied, together with what satisfies them.</summary>
        public static List<KeyValuePair<OfferingCategoryDef, List<Thing>>> Satisfied(IntVec3 spot, Map map)
        {
            List<KeyValuePair<OfferingCategoryDef, List<Thing>>> found =
                new List<KeyValuePair<OfferingCategoryDef, List<Thing>>>();
            List<Thing> onTables = ThingsOnTables(spot, map);
            if (onTables.Count == 0) return found;

            // An item counts towards one category only. Otherwise chocolate could fill both fine
            // food and treasure, and a single stack would be worth two categories.
            HashSet<Thing> claimed = new HashSet<Thing>();

            foreach (OfferingCategoryDef cat in Categories)
            {
                if (cat.filter == null) continue;
                List<Thing> taken = new List<Thing>();
                int count = 0;
                foreach (Thing t in onTables)
                {
                    if (claimed.Contains(t) || !cat.filter.Allows(t)) continue;
                    taken.Add(t);
                    count += t.stackCount;
                    if (count >= cat.countRequired) break;
                }
                if (count >= cat.countRequired)
                {
                    foreach (Thing t in taken) claimed.Add(t);
                    found.Add(new KeyValuePair<OfferingCategoryDef, List<Thing>>(cat, taken));
                }
            }
            return found;
        }

        public static int CountSatisfied(IntVec3 spot, Map map) => Satisfied(spot, map).Count;

        /// <summary>
        /// Consumes what counted, and nothing else. Without this step you would build the table
        /// once and every ritual in the game would be better forever: this is what makes the
        /// mechanic honest.
        /// </summary>
        public static int Consume(IntVec3 spot, Map map)
        {
            int consumed = 0;
            foreach (KeyValuePair<OfferingCategoryDef, List<Thing>> pair in Satisfied(spot, map))
            {
                int remaining = pair.Key.countRequired;
                foreach (Thing t in pair.Value)
                {
                    if (remaining <= 0 || t.Destroyed) continue;
                    int take = System.Math.Min(remaining, t.stackCount);
                    remaining -= take;
                    consumed += take;
                    if (take >= t.stackCount) t.Destroy(DestroyMode.Vanish);
                    else t.SplitOff(take).Destroy(DestroyMode.Vanish);
                }
            }
            return consumed;
        }
    }
}

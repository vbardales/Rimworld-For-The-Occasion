using System.Collections.Generic;
using System.Linq;
using RimWorks.Pickle;
using RimWorld;
using Verse;

namespace ForTheOccasion.PickleSteps
{
    /// <summary>
    /// TESTING.md scenarios 1 and 2: the offering table on a real map. The offline harness proves the
    /// categories' XML and the shape of the counting code; only a running game can say that the table
    /// really accepts the items, that its stacks really fit, and that consuming really takes them.
    /// </summary>
    [PickleSteps]
    public class OfferingSteps
    {
        private class Table
        {
            public Building_Storage Building;
            public int LastConsumed;
        }

        private static Building_Storage TableBuilding(PickleContext ctx)
        {
            Table t;
            try { t = ctx.Get<Table>(); }
            catch (System.InvalidOperationException) { t = null; }
            ctx.Require(t != null && t.Building != null && t.Building.Spawned,
                "no offering table stands on the map: a step must place one first");
            return t.Building;
        }

        private static Table State(PickleContext ctx)
        {
            try { return ctx.Get<Table>(); }
            catch (System.InvalidOperationException) { return null; }
        }

        // ---------------------------------------------------------------- setting up

        [Given("For the Occasion: an offering table stands at \\({int}, {int}\\)")]
        public void PlaceTable(PickleContext ctx, int x, int z)
        {
            var map = Driver.Map(ctx);
            var def = Driver.ThingDefNamed(ctx, "FTO_OfferingTable");
            var thing = Driver.Make(ctx, def);
            var spawned = GenSpawn.Spawn(thing, new IntVec3(x, 0, z), map, Rot4.North, WipeMode.VanishOrMoveAside);
            ctx.Require(spawned is Building_Storage, $"the offering table spawned as a {spawned?.GetType().Name}, not a Building_Storage");
            spawned.SetFaction(Faction.OfPlayer);
            ctx.Set(new Table { Building = (Building_Storage)spawned });
        }

        /// <summary>
        /// Puts the amount on the table one stack at a time, in the table's own cells, up to three stacks
        /// a cell as the def allows. A stack past the def's stack limit is split, as it would be in play.
        /// </summary>
        [When("For the Occasion: {int} {string} are laid on the offering table")]
        public void LayOnTable(PickleContext ctx, int count, string defName)
        {
            var table = TableBuilding(ctx);
            var map = table.Map;
            var def = Driver.ThingDefNamed(ctx, defName);
            var cells = table.OccupiedRect().Cells.ToList();
            var remaining = count;
            while (remaining > 0)
            {
                var take = System.Math.Min(remaining, def.stackLimit);
                // IntVec3 is a struct whose default is a valid cell, so "none found" needs a nullable.
                IntVec3? free = null;
                foreach (var c in cells)
                {
                    if (c.GetThingList(map).Count(t => t.def.category == ThingCategory.Item) < table.def.building.maxItemsInCell)
                    {
                        free = c;
                        break;
                    }
                }
                ctx.Require(free.HasValue,
                    $"the table has no room left for another stack of {defName} (it holds {cells.Count} cells of {table.def.building.maxItemsInCell} stacks)");
                var item = Driver.Make(ctx, def);
                item.stackCount = take;
                GenSpawn.Spawn(item, free.Value, map);
                remaining -= take;
            }
        }

        // ---------------------------------------------------------------- reading

        [Then("For the Occasion: the offering table counts {int} of {int} categories")]
        public void AssertCount(PickleContext ctx, int expected, int of)
        {
            var table = TableBuilding(ctx);
            ctx.Assert(OfferingScan.CategoryCount == of, $"the mod loaded {OfferingScan.CategoryCount} offering categories, the scenario expects {of}");
            var satisfied = OfferingScan.Satisfied(table.Position, table.Map);
            var actual = satisfied.Count;
            ctx.Assert(actual == expected,
                $"the table counts {actual} of {OfferingScan.CategoryCount} categories ("
                + string.Join(", ", satisfied.Select(p => p.Key.defName)) + "), expected " + expected);
        }

        /// <summary>
        /// The line the Begin ritual window draws, asked of the comp the mod really installed on the game's
        /// real ritual outcome defs, with the curve it really built: so this proves the comp is attached and
        /// that the 0 / 4 / 7 / 10 / 12 percent points the player is told about are the ones in use. It does
        /// not draw the window: no capture is taken of it.
        /// </summary>
        [Then("For the Occasion: the Begin ritual window shows the offerings line {string} worth {int} percent")]
        public void AssertQualityLine(PickleContext ctx, string count, int percent)
        {
            var table = TableBuilding(ctx);
            var comp = DefDatabase<RitualOutcomeEffectDef>.AllDefs
                .SelectMany(d => d.comps ?? new List<RitualOutcomeComp>())
                .OfType<RitualOutcomeComp_Offerings>()
                .FirstOrDefault();
            ctx.Require(comp != null, "no RitualOutcomeComp_Offerings is installed on any ritual outcome def: the installer at startup did not run or found nothing");
            // The offerings comp reads only the target cell and the settings, so no ritual is needed.
            var factor = comp.GetQualityFactor(null, new TargetInfo(table.Position, table.Map), null, null, null);
            ctx.Require(factor != null, "the offerings comp returned no line although offerings are enabled");
            ctx.Assert(factor.count == count, $"the offerings line reads '{factor.count}', expected '{count}'");
            var actual = (int)System.Math.Round(factor.quality * 100f);
            ctx.Assert(actual == percent, $"the offerings line is worth {factor.quality * 100f:0.##} percent, expected {percent}");
        }

        [Then("For the Occasion: the offering table accepts {string}")]
        public void AssertAccepts(PickleContext ctx, string defName)
        {
            var table = TableBuilding(ctx);
            ctx.Assert(table.GetStoreSettings().AllowedToAccept(Driver.ThingDefNamed(ctx, defName)),
                $"the offering table refuses {defName}: its storage filter is built from the categories at startup");
        }

        [Then("For the Occasion: the offering table refuses {string}")]
        public void AssertRefuses(PickleContext ctx, string defName)
        {
            var table = TableBuilding(ctx);
            ctx.Assert(!table.GetStoreSettings().AllowedToAccept(Driver.ThingDefNamed(ctx, defName)),
                $"the offering table accepts {defName}, which is no offering");
        }

        // ---------------------------------------------------------------- consuming

        /// <summary>
        /// What the ritual-end hook calls. The hook itself is a postfix on LordJob_Ritual.ApplyOutcome:
        /// its target, its parameter names and its `ended` guard are read from the game's code by the
        /// offline harness, and no step here starts a real ritual, so the consumption is exercised
        /// directly on a real map.
        /// </summary>
        [When("For the Occasion: the offerings are consumed")]
        public void Consume(PickleContext ctx)
        {
            var table = TableBuilding(ctx);
            State(ctx).LastConsumed = OfferingScan.Consume(table.Position, table.Map);
        }

        [Then("For the Occasion: {int} offerings were consumed")]
        public void AssertConsumed(PickleContext ctx, int expected) =>
            ctx.Assert(State(ctx).LastConsumed == expected, $"{State(ctx).LastConsumed} offerings were consumed, expected {expected}");

        [Then("For the Occasion: {int} {string} remain on the offering table")]
        public void AssertRemaining(PickleContext ctx, int expected, string defName)
        {
            var table = TableBuilding(ctx);
            var def = Driver.ThingDefNamed(ctx, defName);
            var actual = OfferingScan.ThingsOnTables(table.Position, table.Map).Where(t => t.def == def).Sum(t => t.stackCount);
            ctx.Assert(actual == expected, $"{actual} {defName} remain on the table, expected {expected}");
        }
    }
}

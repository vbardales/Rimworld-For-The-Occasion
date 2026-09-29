using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RimWorks.Pickle;
using RimWorld;
using Verse;
using Verse.AI;

namespace ForTheOccasion.PickleSteps
{
    /// <summary>
    /// TESTING.md scenarios 3 to 8 and 11: colonists really changing clothes. This is the code that runs
    /// in the prefix on Pawn_JobTracker.StartJob for every job of every pawn, and that fails open, so a
    /// failure looks like nothing happening. Every scenario therefore asserts something that has to be
    /// seen (a garment worn, a flag restored) and ends by asking whether a hook disabled the mod.
    /// </summary>
    [PickleSteps]
    public class DressingSteps
    {
        // ---------------------------------------------------------------- teardown

        private static Made Made(PickleContext ctx)
        {
            try { return ctx.Get<Made>(); }
            catch (InvalidOperationException)
            {
                var made = new Made();
                ctx.Set(made);
                return made;
            }
        }

        /// <summary>
        /// A scenario that fails half way leaves its garments, stand and obligation behind. The next
        /// scenario reloads the save, but the ideoligion's obligation list is part of what a reload
        /// replaces only when the save is reloaded, so it is taken back here as well.
        /// </summary>
        [AfterScenario]
        public void TakeBack(PickleContext ctx)
        {
            var made = Made(ctx);
            foreach (var pair in made.Obligations)
            {
                try { pair.Key.RemoveObligation(pair.Value, false); } catch { }
            }
            made.Obligations.Clear();
            foreach (var thing in made.Things)
            {
                try { if (thing != null && thing.Spawned) thing.Destroy(DestroyMode.Vanish); } catch { }
            }
            made.Things.Clear();
        }

        // ---------------------------------------------------------------- the announcement

        /// <summary>
        /// An obligation is what a death or a date puts on the ritual. Announcing one opens the
        /// anticipation window, in which free colonists get ready for nothing: no ritual is running.
        /// </summary>
        [Given("For the Occasion: a ritual obligation is announced")]
        public void Announce(PickleContext ctx)
        {
            var pair = Driver.RitualWithObligation(ctx);
            pair.Key.AddObligation(pair.Value);
            Made(ctx).Obligations.Add(pair);
        }

        /// <summary>A window of a few hundred ticks keeps a scenario short: the obligation is already this many ticks old when it stops counting.</summary>
        [Given("For the Occasion: the anticipation window is {int} ticks")]
        public void SetWindowTicks(PickleContext ctx, int ticks) => Driver.Settings(ctx).obligationWindowHours = ticks / 2500f;

        [Then("For the Occasion: the anticipation window is open")]
        public void AssertWindowOpen(PickleContext ctx) =>
            ctx.Assert(ObligationWatch.WindowOpen(), "the anticipation window is closed although an obligation was announced");

        [Then("For the Occasion: the anticipation window is closed")]
        public void AssertWindowClosed(PickleContext ctx) =>
            ctx.Assert(!ObligationWatch.WindowOpen(), "the anticipation window is still open");

        // ---------------------------------------------------------------- what lies around

        /// <summary>A garment on the floor, which is all the no-building path needs.</summary>
        [Given("For the Occasion: a {string} lies at \\({int}, {int}\\)")]
        public void GarmentLies(PickleContext ctx, string defName, int x, int z)
        {
            var map = Driver.Map(ctx);
            var thing = Driver.Make(ctx, Driver.ThingDefNamed(ctx, defName));
            GenSpawn.Spawn(thing, new IntVec3(x, 0, z), map);
            Made(ctx).Things.Add(thing);
        }

        /// <summary>
        /// The tag is put on the game's garments by an XML patch that runs before def inheritance, so it
        /// reaches a garment only if the patch really matched in this game and its heirs inherited it.
        /// </summary>
        [Then("For the Occasion: the garment {string} carries the ceremonial tag")]
        public void GarmentTagged(PickleContext ctx, string defName)
        {
            var def = Driver.ThingDefNamed(ctx, defName);
            ctx.Assert(def.apparel?.tags != null && def.apparel.tags.Contains(Driver.CeremonialTag),
                $"{defName} does not carry {Driver.CeremonialTag}: it has [{string.Join(", ", def.apparel?.tags ?? new List<string>())}]");
        }

        [Then("For the Occasion: the garment {string} does not carry the ceremonial tag")]
        public void GarmentNotTagged(PickleContext ctx, string defName)
        {
            var def = Driver.ThingDefNamed(ctx, defName);
            ctx.Assert(def.apparel?.tags == null || !def.apparel.tags.Contains(Driver.CeremonialTag),
                $"{defName} carries {Driver.CeremonialTag} but is an ordinary garment");
        }

        // ---------------------------------------------------------------- the outfit stand

        private static Building_OutfitStand Stand(PickleContext ctx)
        {
            var stand = Driver.Map(ctx).listerBuildings.AllBuildingsColonistOfClass<Building_OutfitStand>().FirstOrDefault();
            ctx.Require(stand != null, "no outfit stand stands on the current map");
            return stand;
        }

        [Then("For the Occasion: the stand def {string} carries exactly {int} ceremonial owner comp")]
        public void StandCompCount(PickleContext ctx, string defName, int expected)
        {
            var def = DefDatabase<ThingDef>.GetNamedSilentFail(defName);
            ctx.Require(def != null, $"{defName} is not defined: Odyssey is not active in this pass");
            var count = def.comps.Count(c => c is CompProperties_AssignableToPawn_CeremonialStand);
            ctx.Assert(count == expected, $"{defName} carries {count} ceremonial owner comps once inheritance is resolved, expected {expected}");
        }

        [Given("For the Occasion: an outfit stand stands at \\({int}, {int}\\) holding {string} and owned by {string}")]
        public void PlaceStand(PickleContext ctx, int x, int z, string garment, string owner)
        {
            var map = Driver.Map(ctx);
            var pawn = Driver.Colonist(ctx, owner);
            var thing = Driver.Make(ctx, Driver.ThingDefNamed(ctx, "Building_OutfitStand"));
            var spawned = GenSpawn.Spawn(thing, new IntVec3(x, 0, z), map, Rot4.South, WipeMode.VanishOrMoveAside);
            spawned.SetFaction(Faction.OfPlayer);
            var stand = spawned as Building_OutfitStand;
            ctx.Require(stand != null, $"the stand spawned as a {spawned?.GetType().Name}");
            Made(ctx).Things.Add(stand);

            var apparel = (Apparel)Driver.Make(ctx, Driver.ThingDefNamed(ctx, garment));
            ctx.Require(stand.AddApparel(apparel), $"the outfit stand would not take a {garment}");

            var comp = stand.TryGetComp<CompAssignableToPawn_CeremonialStand>();
            ctx.Require(comp != null, "the outfit stand has no ceremonial owner comp: the patch did not reach it in this game");
            comp.TryAssignPawn(pawn);
            ctx.Assert(comp.AssignedAnything(pawn), $"{owner} was not assigned as the ceremonial owner");
        }

        [Then("For the Occasion: the outfit stand is owned by {string}")]
        public void StandOwnedBy(PickleContext ctx, string name)
        {
            var ours = Stand(ctx).TryGetComp<CompAssignableToPawn_CeremonialStand>();
            ctx.Require(ours != null, "the outfit stand has no ceremonial owner comp");
            ctx.Assert(ours.AssignedPawnsForReading.Any(p => p.LabelShort == name),
                $"the stand is owned by [{string.Join(", ", ours.AssignedPawnsForReading.Select(p => p.LabelShort))}], not {name}");
        }

        [Then("For the Occasion: the outfit stand holds {string}")]
        public void StandHolds(PickleContext ctx, string defName) =>
            ctx.Assert(Stand(ctx).HeldItems.Any(t => t.def.defName == defName),
                $"the stand holds [{string.Join(", ", Stand(ctx).HeldItems.Select(t => t.def.defName))}], not {defName}");

        [Then("For the Occasion: the outfit stand does not hold {string}")]
        public void StandDoesNotHold(PickleContext ctx, string defName) =>
            ctx.Assert(!Stand(ctx).HeldItems.Any(t => t.def.defName == defName), $"the stand still holds {defName}");

        // ---------------------------------------------------------------- the colonist

        [Given("For the Occasion: {string} wears {string} and it is forced")]
        public void WearsForced(PickleContext ctx, string name, string defName)
        {
            var pawn = Driver.Colonist(ctx, name);
            var apparel = (Apparel)Driver.Make(ctx, Driver.ThingDefNamed(ctx, defName));
            pawn.apparel.Wear(apparel, true, false);
            pawn.outfits.forcedHandler.SetForced(apparel, true);
        }

        [Given("For the Occasion: {string} has nothing forced")]
        public void NothingForced(PickleContext ctx, string name)
        {
            var pawn = Driver.Colonist(ctx, name);
            foreach (var a in pawn.apparel.WornApparel.ToList()) pawn.outfits.forcedHandler.SetForced(a, false);
        }

        private static Apparel Worn(PickleContext ctx, string name, string defName)
        {
            var pawn = Driver.Colonist(ctx, name);
            var apparel = pawn.apparel.WornApparel.FirstOrDefault(a => a.def.defName == defName);
            ctx.Require(apparel != null,
                $"{name} does not wear {defName}; wears [{string.Join(", ", pawn.apparel.WornApparel.Select(a => a.def.defName))}]");
            return apparel;
        }

        [Then("For the Occasion: {string} has {string} forced")]
        public void IsForced(PickleContext ctx, string name, string defName) =>
            ctx.Assert(Driver.Colonist(ctx, name).outfits.forcedHandler.IsForced(Worn(ctx, name, defName)),
                $"{name} wears {defName} but it is not force-worn: the flag was lost");

        [Then("For the Occasion: {string} wears a ceremonial garment")]
        public void WearsCeremonial(PickleContext ctx, string name)
        {
            var pawn = Driver.Colonist(ctx, name);
            ctx.Assert(pawn.apparel.WornApparel.Any(a => a.def.apparel.tags != null && a.def.apparel.tags.Contains(Driver.CeremonialTag)),
                $"{name} wears no ceremonial garment: [{string.Join(", ", pawn.apparel.WornApparel.Select(a => a.def.defName))}]");
        }

        [Then("For the Occasion: {string} wears no ceremonial garment")]
        public void WearsNoCeremonial(PickleContext ctx, string name)
        {
            var pawn = Driver.Colonist(ctx, name);
            ctx.Assert(!pawn.apparel.WornApparel.Any(a => a.def.apparel.tags != null && a.def.apparel.tags.Contains(Driver.CeremonialTag)),
                $"{name} wears a ceremonial garment: [{string.Join(", ", pawn.apparel.WornApparel.Select(a => a.def.defName))}]");
        }

        [Then("For the Occasion: {string} is dressed for the occasion")]
        public void IsPrepared(PickleContext ctx, string name) =>
            ctx.Assert(PreparationTracker.IsPrepared(Driver.Colonist(ctx, name)), $"{name} has no preparation record");

        [Then("For the Occasion: {string} is not dressed for the occasion")]
        public void IsNotPrepared(PickleContext ctx, string name) =>
            ctx.Assert(!PreparationTracker.IsPrepared(Driver.Colonist(ctx, name)), $"{name} still has a preparation record");

        /// <summary>
        /// The prefix on StartJob only looks at a pawn when a job starts. A colonist mid-way through a
        /// long task will not be looked at for a while, so the scenario asks for a job boundary rather
        /// than waiting for one: it is not a player-forced order, and the gates stay in force.
        /// </summary>
        [When("For the Occasion: {string} is made to choose a new job")]
        public void ChooseNewJob(PickleContext ctx, string name)
        {
            var pawn = Driver.Colonist(ctx, name);
            pawn.jobs.EndCurrentJob(JobCondition.InterruptForced, true, true);
        }

        // ---------------------------------------------------------------- face paint

        [Given("For the Occasion: {string} has no tattoo")]
        public void NoTattoo(PickleContext ctx, string name)
        {
            var pawn = Driver.Colonist(ctx, name);
            ctx.Require(pawn.style != null, $"{name} has no style tracker: Ideology is not active");
            pawn.style.FaceTattoo = TattooDefOf.NoTattoo_Face;
        }

        [Then("For the Occasion: {string} has no face tattoo")]
        public void HasNoTattoo(PickleContext ctx, string name)
        {
            var tattoo = Driver.Colonist(ctx, name).style.FaceTattoo;
            ctx.Assert(tattoo == null || tattoo == TattooDefOf.NoTattoo_Face, $"{name} still has the face tattoo {tattoo?.defName}");
        }

        /// <summary>
        /// Whether a colonist gets paint at all is a draw from their ideoligion's style, and it can come out
        /// as no tattoo: the game's chooser returns NoTattoo for a good part of the pawns. So the scenario
        /// cannot demand a tattoo. What it can demand is that the face and the record never disagree: paint
        /// on the face means the record will take it off, and no record of paint means none was put on.
        /// </summary>
        [Then("For the Occasion: {string} has face paint exactly when the preparation record says so")]
        public void PaintFollowsRecord(PickleContext ctx, string name)
        {
            var pawn = Driver.Colonist(ctx, name);
            var record = PreparationTracker.RecordFor(pawn);
            ctx.Require(record != null, $"{name} has no preparation record to compare with");
            var tattoo = pawn.style.FaceTattoo;
            var painted = tattoo != null && tattoo != TattooDefOf.NoTattoo_Face;
            ctx.Assert(painted == record.tattooChanged,
                $"{name}'s face reads {tattoo?.defName ?? "null"} while the record says tattooChanged={record.tattooChanged}");
        }

        // ---------------------------------------------------------------- danger

        /// <summary>
        /// A real raid, and then ticks: the danger watcher recalculates only when the game has ticked past
        /// its last look, and a paused game never does.
        /// </summary>
        [When("For the Occasion: a raid arrives and the map is in danger", TimeoutSeconds = 70f)]
        public async Task RaidArrives(PickleContext ctx)
        {
            var map = Driver.Map(ctx);
            var parms = StorytellerUtility.DefaultParmsNow(IncidentCategoryDefOf.ThreatBig, map);
            parms.forced = true;
            // The default arrival mode walks the raid in from the map edge, which can take far more ticks
            // to be noticed than a scenario's window: drop the raiders in instead, so the danger watcher
            // has something to rate on the very next recalculation.
            parms.raidArrivalMode = PawnsArrivalModeDefOf.CenterDrop;
            ctx.Require(IncidentDefOf.RaidEnemy.Worker.TryExecute(parms), "the game would not run a RaidEnemy incident on this map");
            await ctx.WaitTicks(250);
            await ctx.WaitUntil(() => map.dangerWatcher.DangerRating != StoryDanger.None, 30f);
        }

        // ---------------------------------------------------------------- fail open

        /// <summary>
        /// Every hook of the mod catches, logs once and disables the mod for the session. A disabled mod
        /// looks exactly like an idle one, so this is asked at the end of every behavioural scenario.
        /// </summary>
        [Then("For the Occasion: no hook has disabled the mod")]
        public void NotDisabled(PickleContext ctx) =>
            ctx.Assert(!FtoLog.Disabled, "a hook threw and the mod disabled itself for the session: read the 'disabled for this session' line of Player.log");

        // ---------------------------------------------------------------- cohabitation

        /// <summary>
        /// Both this mod and Shift Change put an owner comp on the same stand def. Written against the
        /// class hierarchy, not against Shift Change's names: any assignable comp that is not ours.
        /// </summary>
        [Then("For the Occasion: the outfit stand def carries another mod's owner comp beside ours")]
        public void OtherOwnerComp(PickleContext ctx)
        {
            var def = DefDatabase<ThingDef>.GetNamedSilentFail("Building_OutfitStand");
            ctx.Require(def != null, "Building_OutfitStand is not defined: Odyssey is not active in this pass");
            var others = def.comps.OfType<CompProperties_AssignableToPawn>().Where(c => !(c is CompProperties_AssignableToPawn_CeremonialStand)).ToList();
            ctx.Assert(others.Count > 0, "no other mod's assignable comp is on the outfit stand: the cohabiting mod is not staged or does not use it");
        }

        [When("For the Occasion: the other owner comp of the stand assigns {string}")]
        public void OtherOwnerAssigns(PickleContext ctx, string name)
        {
            var other = Stand(ctx).AllComps.OfType<CompAssignableToPawn>().FirstOrDefault(c => !(c is CompAssignableToPawn_CeremonialStand));
            ctx.Require(other != null, "the stand has no assignable comp but ours");
            other.TryAssignPawn(Driver.Colonist(ctx, name));
        }

        [Then("For the Occasion: the stand's ceremonial owner is {string} and the other owner is {string}")]
        public void BothOwners(PickleContext ctx, string ceremonial, string other)
        {
            var stand = Stand(ctx);
            var ours = stand.TryGetComp<CompAssignableToPawn_CeremonialStand>();
            var theirs = stand.AllComps.OfType<CompAssignableToPawn>().FirstOrDefault(c => !(c is CompAssignableToPawn_CeremonialStand));
            ctx.Require(ours != null && theirs != null, "the stand lacks one of the two owner comps");
            ctx.Assert(ours.AssignedPawnsForReading.Any(p => p.LabelShort == ceremonial),
                $"the ceremonial owners are [{string.Join(", ", ours.AssignedPawnsForReading.Select(p => p.LabelShort))}], not {ceremonial}");
            ctx.Assert(theirs.AssignedPawnsForReading.Any(p => p.LabelShort == other),
                $"the other comp's owners are [{string.Join(", ", theirs.AssignedPawnsForReading.Select(p => p.LabelShort))}], not {other}");
            ctx.Assert(!ours.AssignedPawnsForReading.Any(p => p.LabelShort == other) || ceremonial == other,
                "the other comp's owner leaked into the ceremonial list: the two share a save key");
        }
    }
}

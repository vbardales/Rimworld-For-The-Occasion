using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RimWorks.Pickle;
using RimWorld;
using Verse;
using Verse.AI.Group;

namespace ForTheOccasion.PickleSteps
{
    /// <summary>
    /// A REAL ritual, through the game's own Begin ritual window, so that the postfix on
    /// LordJob_Ritual.ApplyOutcome is reached the way it is in play: the hook that consumes the offerings
    /// at the end of a rite, that takes nothing from a cancelled one, and that never consumes twice.
    /// This is the gap the offline harness cannot close: it reads the hook's target, its parameter names and
    /// the flag it guards with, and only a game can say the hook fires.
    /// </summary>
    [PickleSteps]
    public class RitualSteps
    {
        private class Chosen
        {
            public Precept_Ritual Ritual;
            public Thing Spot;
        }

        private static Chosen State(PickleContext ctx)
        {
            try { return ctx.Get<Chosen>(); }
            catch (InvalidOperationException) { return null; }
        }

        private static LordJob_Ritual Running(PickleContext ctx)
        {
            var job = Driver.Map(ctx).lordManager.lords.Select(l => l.LordJob).OfType<LordJob_Ritual>().FirstOrDefault();
            ctx.Require(job != null, "no ritual is running on the current map");
            return job;
        }

        /// <summary>
        /// A ritual spot takes many rituals. The ritual is picked, out of the player's ideoligion, as the first
        /// that accepts this spot and needs no role to be filled: a rite that cannot start without a leader or a
        /// convict would not start from a bare test colony, and that would say nothing about this mod.
        /// </summary>
        [Given("For the Occasion: a ritual spot stands at \\({int}, {int}\\)")]
        public void PlaceSpot(PickleContext ctx, int x, int z)
        {
            var map = Driver.Map(ctx);
            var def = Driver.ThingDefNamed(ctx, "RitualSpot");
            var spawned = GenSpawn.Spawn(ThingMaker.MakeThing(def), new IntVec3(x, 0, z), map, WipeMode.VanishOrMoveAside);
            spawned.SetFaction(Faction.OfPlayer);
            var target = new TargetInfo(spawned);

            var tried = new List<string>();
            Precept_Ritual pick = null;
            foreach (var ritual in Faction.OfPlayer.ideos.AllIdeos.SelectMany(i => i.PreceptsListForReading).OfType<Precept_Ritual>())
            {
                var roles = ritual.behavior?.def?.roles;
                var needsRole = roles != null && roles.Any(r => r.required);
                // A ritual built for a different kind of target (a corpse, a pawn) can throw when asked
                // about a bare RitualSpot rather than answer false: that is not a candidate either.
                bool accepts;
                try { accepts = ritual.behavior != null && ritual.CanUseTarget(target, null).canUse; }
                catch (Exception e) { accepts = false; tried.Add($"{ritual.Label}: threw asking CanUseTarget ({e.Message})"); continue; }
                tried.Add($"{ritual.Label} (needs a role: {needsRole}, accepts the spot: {accepts})");
                if (pick == null && accepts && !needsRole) pick = ritual;
            }
            ctx.Require(pick != null, "no ritual of the player's ideoligion takes a ritual spot without a required role; tried: " + string.Join("; ", tried));
            ctx.Set(new Chosen { Ritual = pick, Spot = spawned });
        }

        /// <summary>The real window, with the two quality lines the mod adds. It pauses the game: wait frames.</summary>
        [When("For the Occasion: the Begin ritual window is opened at the ritual spot")]
        public async Task OpenWindow(PickleContext ctx)
        {
            var chosen = State(ctx);
            ctx.Require(chosen != null, "no ritual spot was placed: a step must place one first");
            chosen.Ritual.ShowRitualBeginWindow(new TargetInfo(chosen.Spot), null, null, null);
            await ctx.WaitFrames(5);
            ctx.Require(Find.WindowStack.Windows.OfType<Dialog_BeginRitual>().Any(),
                $"the Begin ritual window for '{chosen.Ritual.Label}' did not open");
        }

        /// <summary>What the Begin button does. The ritual then runs as a real lord job.</summary>
        [When("For the Occasion: the ritual is begun from that window", TimeoutSeconds = 30f)]
        public async Task Begin(PickleContext ctx)
        {
            var dialog = Find.WindowStack.Windows.OfType<Dialog_BeginRitual>().FirstOrDefault();
            ctx.Require(dialog != null, "no Begin ritual window is open");
            Driver.Method(ctx, typeof(Dialog_BeginRitual), "Start", Driver.InstanceAny).Invoke(dialog, null);
            await ctx.WaitFrames(5);
            var map = Driver.Map(ctx);
            await ctx.WaitUntil(() => map.lordManager.lords.Any(l => l.LordJob is LordJob_Ritual), 20f);
        }

        /// <summary>
        /// The ritual is ended by asking its lord job to apply its outcome, which is the game's own last step
        /// and the method the mod patches. Waiting out a real ritual would take game hours.
        /// </summary>
        [When("For the Occasion: the running ritual ends")]
        public void End(PickleContext ctx) => Running(ctx).ApplyOutcome(1f, false, false, false);

        [When("For the Occasion: the running ritual is cancelled")]
        public void Cancel(PickleContext ctx) => Running(ctx).ApplyOutcome(0f, false, false, true);

        /// <summary>The game can call it twice: the second call must consume nothing more.</summary>
        [When("For the Occasion: the running ritual reports its outcome a second time")]
        public void EndAgain(PickleContext ctx) => Running(ctx).ApplyOutcome(1f, false, false, false);
    }
}

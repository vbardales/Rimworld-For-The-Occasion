using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using RimWorks.Pickle;
using RimWorld;
using Verse;

namespace ForTheOccasion.PickleSteps
{
    /// <summary>
    /// What every step class needs to reach the mod and the game, with failures that name themselves.
    /// An unguarded reflection hop or GetMod reports only "Object reference not set to an instance of
    /// an object", and a Pickle report keeps no stack, so a run could not say which hop had failed.
    /// </summary>
    public static class Driver
    {
        internal const BindingFlags StaticAny = BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic;
        internal const BindingFlags InstanceAny = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;

        /// <summary>The ceremonial tag the apparel patch applies, by criterion, to vanilla garments.</summary>
        internal const string CeremonialTag = "FTO_Ceremonial";

        public static ForTheOccasionMod Mod(PickleContext ctx)
        {
            var mod = LoadedModManager.GetMod<ForTheOccasionMod>();
            ctx.Require(mod != null,
                "LoadedModManager.GetMod<ForTheOccasionMod>() returned nothing: ForTheOccasion.dll is not loaded "
                + "in this session, so no step can reach its settings");
            return mod;
        }

        /// <summary>
        /// Always re-read, never cached: a re-read from disk replaces the object wholesale, and a step
        /// holding the old reference would change a settings object nothing reads any more.
        /// </summary>
        public static FtoSettings Settings(PickleContext ctx)
        {
            // The object the game itself writes when the settings window closes is the one the mod holds in
            // its base class. The static field must be that same object: a step that swapped it for another
            // (a re-read from disk) would change values the window never writes, and a "close the window
            // and the file has it" scenario would fail for a reason that is not the mod's.
            var value = Mod(ctx).GetSettings<FtoSettings>();
            ctx.Require(value != null, "the mod holds no settings object: it has not finished loading");
            ForTheOccasionMod.Settings = value;
            return value;
        }

        public static Map Map(PickleContext ctx)
        {
            var map = Find.CurrentMap;
            ctx.Require(map != null, "there is no current map: load a save first");
            return map;
        }

        public static ThingDef ThingDefNamed(PickleContext ctx, string defName)
        {
            var def = DefDatabase<ThingDef>.GetNamedSilentFail(defName);
            ctx.Require(def != null, $"no ThingDef named '{defName}' is loaded (is the mod that defines it staged in this pass?)");
            return def;
        }

        /// <summary>
        /// A free colonist by short name or nickname, looked up again on every call. After a save and
        /// reload every object kept from before belongs to the game that was replaced.
        /// </summary>
        public static Pawn Colonist(PickleContext ctx, string name)
        {
            var map = Map(ctx);
            var pawn = map.mapPawns.FreeColonists.FirstOrDefault(p =>
                string.Equals(p.LabelShort, name, StringComparison.OrdinalIgnoreCase)
                || string.Equals(p.Name?.ToStringShort, name, StringComparison.OrdinalIgnoreCase));
            ctx.Require(pawn != null,
                $"no free colonist named '{name}' on the current map; there are: "
                + string.Join(", ", map.mapPawns.FreeColonists.Select(p => p.LabelShort)));
            return pawn;
        }

        /// <summary>Makes a thing of a def, giving a stuffed def its default stuff.</summary>
        public static Thing Make(PickleContext ctx, ThingDef def)
        {
            var stuff = def.MadeFromStuff ? GenStuff.DefaultStuffFor(def) : null;
            ctx.Require(!def.MadeFromStuff || stuff != null, $"{def.defName} needs a stuff and the game found no default one");
            return ThingMaker.MakeThing(def, stuff);
        }

        public static FieldInfo Field(PickleContext ctx, Type owner, string name, BindingFlags flags)
        {
            var field = owner.GetField(name, flags);
            ctx.Require(field != null, $"{owner.FullName}.{name} no longer exists: the game or the mod renamed it, update the steps");
            return field;
        }

        public static MethodInfo Method(PickleContext ctx, Type owner, string name, BindingFlags flags)
        {
            var method = owner.GetMethod(name, flags);
            ctx.Require(method != null, $"{owner.FullName}.{name}() no longer exists: the game or the mod renamed it, update the steps");
            return method;
        }

        /// <summary>
        /// Every ritual precept the player's ideoligion owns that has an obligation target filter, most
        /// permissive first: a filter is not proof that building an obligation for it will not throw (one
        /// can need a corpse, a specific map state, a quest), so a caller that actually builds one must
        /// try candidates in turn rather than trust the first.
        /// </summary>
        public static List<Precept_Ritual> Rituals(PickleContext ctx)
        {
            ctx.Require(ModsConfig.IdeologyActive, "Ideology is not active: there are no rituals to announce");
            var ideos = Faction.OfPlayer?.ideos;
            ctx.Require(ideos != null, "the player's faction has no ideoligion tracker");
            // activeObligations is null until a first obligation is added (AddObligation creates the list),
            // so it cannot be part of the choice: a ritual takes obligations when it has a target filter.
            var all = ideos.AllIdeos.SelectMany(i => i.PreceptsListForReading).OfType<Precept_Ritual>()
                .Where(r => r.obligationTargetFilter != null).ToList();
            ctx.Require(all.Count > 0,
                "the player's ideoligions hold no ritual with an obligation target filter: "
                + string.Join(", ", ideos.AllIdeos.SelectMany(i => i.PreceptsListForReading).OfType<Precept_Ritual>().Select(r => r.Label)));
            return all;
        }

        /// <summary>The first ritual precept that can actually build an obligation right now.</summary>
        public static Precept_Ritual Ritual(PickleContext ctx) => RitualWithObligation(ctx).Key;

        /// <summary>Builds and returns the obligation too, since building it is the whole test.</summary>
        public static KeyValuePair<Precept_Ritual, RitualObligation> RitualWithObligation(PickleContext ctx)
        {
            var candidates = Rituals(ctx);
            var failures = new List<string>();
            foreach (var candidate in candidates)
            {
                try { return new KeyValuePair<Precept_Ritual, RitualObligation>(candidate, new RitualObligation(candidate, false)); }
                catch (Exception e) { failures.Add($"{candidate.Label}: {e.Message}"); }
            }
            ctx.Require(false,
                $"none of the {candidates.Count} candidate rituals could build an obligation: " + string.Join(" | ", failures));
            return default;
        }
    }

    /// <summary>What a scenario put on the map or in the ideoligion, remembered for its teardown.</summary>
    public class Made
    {
        public readonly List<Thing> Things = new List<Thing>();
        public readonly List<KeyValuePair<Precept_Ritual, RitualObligation>> Obligations =
            new List<KeyValuePair<Precept_Ritual, RitualObligation>>();
    }
}

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
            var value = ForTheOccasionMod.Settings;
            ctx.Require(value != null, "ForTheOccasionMod.Settings is null: the mod has not finished loading");
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

        /// <summary>The first ritual precept the player's ideoligion owns and can carry an obligation.</summary>
        public static Precept_Ritual Ritual(PickleContext ctx)
        {
            ctx.Require(ModsConfig.IdeologyActive, "Ideology is not active: there are no rituals to announce");
            var ideos = Faction.OfPlayer?.ideos;
            ctx.Require(ideos != null, "the player's faction has no ideoligion tracker");
            var ritual = ideos.AllIdeos
                .SelectMany(i => i.PreceptsListForReading)
                .OfType<Precept_Ritual>()
                .FirstOrDefault(r => r.activeObligations != null && r.obligationTargetFilter != null);
            ctx.Require(ritual != null, "the player's ideoligion has no ritual that takes an obligation");
            return ritual;
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

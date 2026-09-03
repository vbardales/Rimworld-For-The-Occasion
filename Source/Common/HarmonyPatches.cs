using System;
using System.Reflection;
using HarmonyLib;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// Entry point for the hooks. They are all declarative (<c>[HarmonyPatch]</c>) and applied in
    /// a single <c>PatchAll</c>: if one of them cannot find its method, Harmony says so in the log
    /// and the mod carries on without it.
    /// </summary>
    [StaticConstructorOnStartup]
    public static class HarmonyPatches
    {
        static HarmonyPatches()
        {
            try
            {
                Patch_ConsumeOfferings.Init();
                new Harmony("nelim.fortheoccasion").PatchAll(Assembly.GetExecutingAssembly());
                FtoLog.Message("Harmony patches applied.");
            }
            catch (Exception e)
            {
                FtoLog.Fail("HarmonyPatches", e);
            }
        }
    }
}

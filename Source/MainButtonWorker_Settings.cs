using RimWorld;
using Verse;

namespace ForTheOccasion
{
    // Standard MainButtonDef visibility is left to the game and customization tools.
    // Both entry points use the native dialog and the same loaded Mod instance.
    public class MainButtonWorker_Settings : MainButtonWorker
    {
        internal static Dialog_ModSettings CreateDialog()
        {
            return new Dialog_ModSettings(LoadedModManager.GetMod<ForTheOccasionMod>());
        }

        public override void Activate()
        {
            Find.WindowStack.Add(CreateDialog());
        }
    }
}

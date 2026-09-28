using System;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using System.Xml.Linq;
using RimWorks.Pickle;
using RimWorld;
using Verse;

namespace ForTheOccasion.PickleSteps
{
    /// <summary>
    /// The settings window and the settings file: TESTING.md scenarios 10 and 12 as far as one process
    /// takes them, plus the sandbox that keeps a scenario's changes off the owner's own configuration.
    /// </summary>
    [PickleSteps]
    public class SettingsSteps
    {
        // ---------------------------------------------------------------- sandbox

        private static string SettingsPath(PickleContext ctx)
        {
            var mod = Driver.Mod(ctx);
            var method = Driver.Method(ctx, typeof(LoadedModManager), "GetSettingsFilename", Driver.StaticAny);
            return (string)method.Invoke(null, new object[] { mod.Content.FolderName, mod.GetType().Name });
        }

        private static string BackupPath(PickleContext ctx) => SettingsPath(ctx) + ".pickle-backup";

        private static void ToDefaults(PickleContext ctx)
        {
            // Field by field into the live object, which is the one the comps and the patches read.
            var defaults = new FtoSettings();
            var live = Driver.Settings(ctx);
            foreach (var f in typeof(FtoSettings).GetFields(BindingFlags.Public | BindingFlags.Instance))
                f.SetValue(live, f.GetValue(defaults));
            OutcomeCompInstaller.RescaleCurves();
        }

        /// <summary>
        /// A backup left by a run that never finished is the owner's real file: put it back first. Then
        /// the current file, if any, is copied aside, and the scenario starts on the documented defaults.
        /// </summary>
        [BeforeScenario]
        public void IsolateSettings(PickleContext ctx)
        {
            if (File.Exists(BackupPath(ctx)))
            {
                File.Copy(BackupPath(ctx), SettingsPath(ctx), overwrite: true);
                File.Delete(BackupPath(ctx));
            }
            if (File.Exists(SettingsPath(ctx)))
                File.Copy(SettingsPath(ctx), BackupPath(ctx), overwrite: false);
            ToDefaults(ctx);
        }

        /// <summary>
        /// Restores the file, the in-memory settings, the shortcut's visibility and the windows, even when
        /// the scenario failed half way. A shortcut left revealed would draw in every scenario after it.
        /// </summary>
        [AfterScenario]
        public void RestoreSettings(PickleContext ctx)
        {
            try { Find.WindowStack?.Windows?.OfType<Dialog_ModSettings>().ToList().ForEach(w => w.Close(false)); } catch { }
            var def = DefDatabase<MainButtonDef>.GetNamedSilentFail("FTO_Settings");
            if (def != null) def.buttonVisible = false;

            var path = SettingsPath(ctx);
            if (keepForNextProcess)
            {
                // Consumed here rather than reset at the start of the next scenario, so it cannot leak
                // into a scenario that never asked for it. The backup goes too: left in place, the next
                // process would read it as a run that never finished and restore it over this file.
                keepForNextProcess = false;
                if (File.Exists(BackupPath(ctx))) File.Delete(BackupPath(ctx));
            }
            else if (discardKept)
            {
                discardKept = false;
                if (File.Exists(BackupPath(ctx))) File.Delete(BackupPath(ctx));
                if (File.Exists(path)) File.Delete(path);
            }
            else if (File.Exists(BackupPath(ctx)))
            {
                File.Copy(BackupPath(ctx), path, overwrite: true);
                File.Delete(BackupPath(ctx));
            }
            else if (File.Exists(path))
            {
                File.Delete(path);
            }
            ToDefaults(ctx);
        }

        /// <summary>
        /// Set by a step, never by a hook: Pickle runs an untagged hook for every scenario and a tagged
        /// one on top of it, in an order .NET does not guarantee, so a tagged hook cannot silence the
        /// general one. Steps always run after the before-hooks and before the after-hooks.
        /// </summary>
        private static bool keepForNextProcess;
        private static bool discardKept;

        /// <summary>For the restart pair: what this scenario leaves on disk is what the NEXT process starts from.</summary>
        [Given("For the Occasion: the settings file is kept for the next launch")]
        public void KeepSettings(PickleContext ctx) => keepForNextProcess = true;

        /// <summary>The reader of the pair puts nothing back: it removes what the writer left.</summary>
        [Given("For the Occasion: the settings file the previous launch kept is discarded at the end")]
        public void DiscardKept(PickleContext ctx) => discardKept = true;

        // ---------------------------------------------------------------- the window

        /// <summary>
        /// Waits for its own frames rather than leaving that to the scenario. Dialog_ModSettings
        /// force-pauses the game, so a tick wait written in the scenario can never be satisfied.
        /// </summary>
        [When("For the Occasion: I open the settings dialog")]
        public async Task OpenDialog(PickleContext ctx)
        {
            Find.WindowStack.Add(new Dialog_ModSettings(Driver.Mod(ctx)));
            await ctx.WaitFrames(3);
        }

        /// <summary>
        /// The claim of the shortcut is not "it opens a settings window" but "it opens THIS mod's": a
        /// dialog opened for another mod would look the same in a capture.
        /// </summary>
        [Then("For the Occasion: a settings dialog is open for this mod")]
        public void AssertDialogForThisMod(PickleContext ctx)
        {
            var mod = Driver.Mod(ctx);
            var windows = Find.WindowStack.Windows.OfType<Dialog_ModSettings>().ToList();
            ctx.Require(windows.Count > 0, "no Dialog_ModSettings is open");
            var modField = typeof(Dialog_ModSettings).GetFields(Driver.InstanceAny).FirstOrDefault(f => typeof(Mod).IsAssignableFrom(f.FieldType));
            ctx.Require(modField != null, "Dialog_ModSettings no longer holds a Mod field: update the steps");
            var owners = windows.Select(w => (modField.GetValue(w) as Mod)?.GetType().Name ?? "(none)").ToList();
            ctx.Assert(windows.Any(w => ReferenceEquals(modField.GetValue(w), mod)),
                $"a settings dialog is open, but for {string.Join(", ", owners)} and not for {mod.GetType().Name}");
        }

        // ---------------------------------------------------------------- the values

        [Given("For the Occasion: settings are at their documented defaults")]
        public void ResetToDefaults(PickleContext ctx) => ToDefaults(ctx);

        [When("For the Occasion: setting {string} is set to {string}")]
        public void SetSetting(PickleContext ctx, string field, string value)
        {
            var f = typeof(FtoSettings).GetField(field, BindingFlags.Public | BindingFlags.Instance);
            ctx.Require(f != null, $"FtoSettings has no public field '{field}': {string.Join(", ", typeof(FtoSettings).GetFields().Select(x => x.Name))}");
            object parsed;
            if (f.FieldType == typeof(bool))
            {
                ctx.Require(bool.TryParse(value, out var b), $"'{value}' is not true or false");
                parsed = b;
            }
            else if (f.FieldType == typeof(float))
            {
                ctx.Require(float.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out var n), $"'{value}' is not a number");
                parsed = n;
            }
            else
            {
                throw new ArgumentException($"FtoSettings.{field} is a {f.FieldType.Name}, which this step does not set");
            }
            f.SetValue(Driver.Settings(ctx), parsed);
        }

        [Then("For the Occasion: setting {string} reads {string}")]
        public void AssertSetting(PickleContext ctx, string field, string expected)
        {
            var f = typeof(FtoSettings).GetField(field, BindingFlags.Public | BindingFlags.Instance);
            ctx.Require(f != null, $"FtoSettings has no public field '{field}'");
            var actual = Convert.ToString(f.GetValue(Driver.Settings(ctx)), CultureInfo.InvariantCulture);
            ctx.Assert(string.Equals(actual, expected, StringComparison.OrdinalIgnoreCase),
                $"FtoSettings.{field} reads '{actual}', expected '{expected}'");
        }

        // ---------------------------------------------------------------- the file

        /// <summary>WriteSettings is also what the native dialog calls when it closes.</summary>
        [When("For the Occasion: settings are written to disk")]
        public void WriteToDisk(PickleContext ctx) => Driver.Mod(ctx).WriteSettings();

        /// <summary>
        /// Scribe leaves a value out when it equals the default, so only a value changed from its default
        /// can be looked for by name.
        /// </summary>
        [Then("For the Occasion: the settings file records {string} as {string}")]
        public void AssertFileRecords(PickleContext ctx, string field, string expected)
        {
            var path = SettingsPath(ctx);
            ctx.Require(File.Exists(path), $"no settings file at {path}: nothing was written");
            var element = XDocument.Load(path).Descendants(field).FirstOrDefault();
            ctx.Require(element != null, $"{path} has no <{field}>: a value equal to its default is not written");
            ctx.Assert(string.Equals(element.Value, expected, StringComparison.OrdinalIgnoreCase),
                $"the file records {field} as '{element.Value}', expected '{expected}'");
        }

        /// <summary>The object -> file -> object round trip, through the game's own reader.</summary>
        [When("For the Occasion: settings are re-read from disk")]
        public void ReadBack(PickleContext ctx)
        {
            var mod = Driver.Mod(ctx);
            var fresh = LoadedModManager.ReadModSettings<FtoSettings>(mod.Content.FolderName, mod.GetType().Name);
            // Into the live object, field by field, never in its place: see Driver.Settings.
            var live = Driver.Settings(ctx);
            foreach (var f in typeof(FtoSettings).GetFields(BindingFlags.Public | BindingFlags.Instance))
                f.SetValue(live, f.GetValue(fresh));
            OutcomeCompInstaller.RescaleCurves();
        }

        // ---------------------------------------------------------------- the shortcut

        private static MainButtonDef Button(PickleContext ctx)
        {
            var def = DefDatabase<MainButtonDef>.GetNamedSilentFail("FTO_Settings");
            ctx.Require(def != null, "no MainButtonDef named FTO_Settings");
            return def;
        }

        [Then("For the Occasion: the settings shortcut is hidden on a clean configuration")]
        public void ShortcutHidden(PickleContext ctx)
        {
            var def = Button(ctx);
            ctx.Assert(!def.buttonVisible, "FTO_Settings ships with buttonVisible true: it would show without being revealed");
            ctx.Assert(!def.Worker.Visible, "FTO_Settings worker reports Visible true on a clean configuration");
        }

        /// <summary>
        /// What a customization mod does when a player reveals the button is move this same field. What
        /// this mod owes is the other side of the contract: drawn and live once revealed, not greyed.
        /// </summary>
        [When("For the Occasion: the settings shortcut is revealed, as a customization mod would")]
        public async Task Reveal(PickleContext ctx)
        {
            Button(ctx).buttonVisible = true;
            await ctx.WaitFrames(10);
        }

        [When("For the Occasion: the settings shortcut is hidden again")]
        public void Hide(PickleContext ctx) => Button(ctx).buttonVisible = false;

        [Then("For the Occasion: the settings shortcut is drawn and enabled")]
        public void ShortcutDrawn(PickleContext ctx)
        {
            var def = Button(ctx);
            ctx.Assert(def.Worker.Visible, "FTO_Settings is revealed but its worker reports Visible false");
            ctx.Assert(!def.Worker.Disabled, "FTO_Settings is drawn but greyed out, which MOD_SETTINGS.md forbids");
        }

        [Then("For the Occasion: the settings shortcut is not drawn")]
        public void ShortcutNotDrawn(PickleContext ctx) =>
            ctx.Assert(!Button(ctx).Worker.Visible, "FTO_Settings reports Visible true while it should be hidden");

        /// <summary>What the bar's own click ends up calling.</summary>
        [When("For the Occasion: the settings shortcut is activated")]
        public async Task Activate(PickleContext ctx)
        {
            Button(ctx).Worker.Activate();
            await ctx.WaitFrames(3);
        }

        /// <summary>
        /// French: the text must be the DefInjected one and differ from the English source, otherwise the
        /// def was never injected. Any other language: non-empty, and not the French text.
        /// </summary>
        [Then("For the Occasion: the settings shortcut carries its description for the active language")]
        public void ShortcutDescription(PickleContext ctx)
        {
            var def = Button(ctx);
            var root = Driver.Mod(ctx).Content.RootDir;
            var file = Path.Combine(root, "Languages", "French", "DefInjected", "MainButtonDef", "MainButtons.xml");
            ctx.Require(File.Exists(file), $"no DefInjected file at {file}");
            var element = XDocument.Load(file).Descendants("FTO_Settings.description").FirstOrDefault();
            ctx.Require(element != null, $"{file} has no <FTO_Settings.description>");
            var active = LanguageDatabase.activeLanguage?.folderName ?? "";
            ctx.Require(!string.IsNullOrWhiteSpace(def.description), $"FTO_Settings has an empty description in '{active}'");
            if (active.StartsWith("French"))
                ctx.Assert(def.description == element.Value,
                    $"FTO_Settings.description reads '{def.description}' in a French game, expected '{element.Value}'");
            else
                ctx.Assert(def.description != element.Value, $"FTO_Settings.description reads the French text in '{active}'");
        }
    }
}

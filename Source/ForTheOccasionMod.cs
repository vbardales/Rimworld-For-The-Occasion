using System;
using UnityEngine;
using Verse;

namespace ForTheOccasion
{
    public class FtoSettings : ModSettings
    {
        /// <summary>
        /// Multiplier applied to both quality curves. At 1.0 the mod is worth +0.25 in total
        /// (offerings +0.12, preparation +0.13) against a vanilla budget capped at 1.0
        /// (<c>RitualOutcomeEffectDef.maxQuality</c>). Adjustable rather than fixed: it is the one
        /// number that can compete with other ritual mods.
        /// </summary>
        public float qualityBudget = 1f;

        public bool offeringsEnabled = true;
        public bool preparationEnabled = true;

        /// <summary>Getting ready as soon as an obligation is announced: free, this is anticipation.</summary>
        public bool prepareOnObligation = true;

        /// <summary>Getting ready at launch: the detour costs ritual progress.</summary>
        public bool prepareOnLaunch = true;

        /// <summary>Length of the anticipation window, in game hours after the announcement.</summary>
        public float obligationWindowHours = 12f;

        /// <summary>Past this, the last-minute detour costs more ritual than the outfit is worth.</summary>
        public float maxDetourDistance = 40f;

        public bool tattooEnabled = true;

        // Old or externally edited settings can bypass sliders. Keep their values finite
        // and within the same limits before either the UI or gameplay reads them.
        public void Normalize()
        {
            qualityBudget = Bounded(qualityBudget, 0f, 2f, 1f);
            obligationWindowHours = (float)Math.Round(Bounded(obligationWindowHours, 1f, 48f, 12f));
            maxDetourDistance = (float)Math.Round(Bounded(maxDetourDistance, 5f, 120f, 40f));
        }

        static float Bounded(float value, float min, float max, float fallback)
        {
            if (float.IsNaN(value) || float.IsInfinity(value)) return fallback;
            return Math.Max(min, Math.Min(max, value));
        }

        public override void ExposeData()
        {
            base.ExposeData();
            Scribe_Values.Look(ref qualityBudget, "qualityBudget", 1f);
            Scribe_Values.Look(ref offeringsEnabled, "offeringsEnabled", true);
            Scribe_Values.Look(ref preparationEnabled, "preparationEnabled", true);
            Scribe_Values.Look(ref prepareOnObligation, "prepareOnObligation", true);
            Scribe_Values.Look(ref prepareOnLaunch, "prepareOnLaunch", true);
            Scribe_Values.Look(ref obligationWindowHours, "obligationWindowHours", 12f);
            Scribe_Values.Look(ref maxDetourDistance, "maxDetourDistance", 40f);
            Scribe_Values.Look(ref tattooEnabled, "tattooEnabled", true);
            if (Scribe.mode == LoadSaveMode.LoadingVars) Normalize();
        }
    }

    public class ForTheOccasionMod : Mod
    {
        /// <summary>
        /// Initialised empty rather than null. The offerings comp reads the settings from
        /// <c>Applies</c>, which the game calls during its quality calculation: a null field would
        /// throw in the middle of vanilla ritual code, before the mod constructor had a chance to
        /// run under an unexpected load order.
        /// </summary>
        public static FtoSettings Settings = new FtoSettings();

        public ForTheOccasionMod(ModContentPack content) : base(content)
        {
            Settings = GetSettings<FtoSettings>();
            Settings.Normalize();
        }

        public override string SettingsCategory() => "FTO_ModTitle".Translate();

        public override void DoSettingsWindowContents(Rect inRect)
        {
            Listing_Standard listing = new Listing_Standard();
            listing.Begin(inRect);

            listing.Label("FTO_SettingsScope".Translate());
            listing.Gap();

            listing.Label("FTO_QualityBudget".Translate((Settings.qualityBudget * 0.25f).ToStringPercent("0.#")),
                -1f, "FTO_QualityBudgetDesc".Translate());
            Settings.qualityBudget = listing.Slider(Settings.qualityBudget, 0f, 2f);

            listing.GapLine();

            listing.CheckboxLabeled("FTO_Offerings".Translate(), ref Settings.offeringsEnabled,
                "FTO_OfferingsDesc".Translate());

            listing.GapLine();

            listing.CheckboxLabeled("FTO_Preparation".Translate(), ref Settings.preparationEnabled,
                "FTO_PreparationDesc".Translate());

            if (Settings.preparationEnabled)
            {
                listing.CheckboxLabeled("FTO_PrepareOnObligation".Translate(), ref Settings.prepareOnObligation,
                    "FTO_PrepareOnObligationDesc".Translate());

                if (Settings.prepareOnObligation)
                {
                    listing.Label("FTO_ObligationWindow".Translate(Settings.obligationWindowHours.ToString("0")),
                        -1f, "FTO_ObligationWindowDesc".Translate());
                    Settings.obligationWindowHours = Mathf.Round(listing.Slider(Settings.obligationWindowHours, 1f, 48f));
                }

                listing.CheckboxLabeled("FTO_PrepareOnLaunch".Translate(), ref Settings.prepareOnLaunch,
                    "FTO_PrepareOnLaunchDesc".Translate());

                if (Settings.prepareOnLaunch)
                {
                    listing.Label("FTO_MaxDetour".Translate(Settings.maxDetourDistance.ToString("0")),
                        -1f, "FTO_MaxDetourDesc".Translate());
                    Settings.maxDetourDistance = Mathf.Round(listing.Slider(Settings.maxDetourDistance, 5f, 120f));
                }

                listing.CheckboxLabeled("FTO_Tattoo".Translate(), ref Settings.tattooEnabled,
                    "FTO_TattooDesc".Translate());
            }

            listing.End();
        }

        /// <summary>
        /// The curves live on the comps attached at startup, so rescale them here: otherwise the
        /// slider would only take effect the next time the game is launched.
        /// </summary>
        public override void WriteSettings()
        {
            Settings.Normalize();
            base.WriteSettings();
            ObligationWatch.Invalidate();
            OutcomeCompInstaller.RescaleCurves();
        }
    }
}

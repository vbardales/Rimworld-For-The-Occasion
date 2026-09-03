using System.Collections.Generic;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// One family of offerings: scent, food, drink, treasure. What a ritual rewards is not
    /// quantity but **variety** — three hundred beers are not a feast. The quality comp therefore
    /// counts distinct categories, and this def is the unit of account.
    ///
    /// Categories are filled from XML through <c>filter</c>, with one <c>MayRequire</c> per
    /// <c>li</c> for modded items: a category whose items are all absent still loads, it simply
    /// never gets satisfied.
    /// </summary>
    public class OfferingCategoryDef : Def
    {
        /// <summary>What counts towards this category.</summary>
        public ThingFilter filter;

        /// <summary>How many units make the category count, and how many are consumed at the end.</summary>
        public int countRequired = 1;

        /// <summary>Display order in the launch window's tooltip.</summary>
        public int uiOrder;

        public override void ResolveReferences()
        {
            base.ResolveReferences();
            // Without this call the filter stays empty: ThingFilter does not resolve itself.
            filter?.ResolveReferences();
        }

        public override IEnumerable<string> ConfigErrors()
        {
            foreach (string err in base.ConfigErrors()) yield return err;
            if (filter == null) yield return "OfferingCategoryDef without a filter";
            if (countRequired < 1) yield return "OfferingCategoryDef with countRequired < 1";
        }
    }
}

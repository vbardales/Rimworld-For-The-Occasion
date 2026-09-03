using System.Collections.Generic;
using RimWorld;
using Verse;
using Verse.AI;

namespace ForTheOccasion
{
    /// <summary>What a pawn is about to do to get into ceremonial clothes.</summary>
    public class PrepPlan
    {
        /// <summary>The stand to walk to, or null when the outfit is a garment lying on the floor.</summary>
        public Building stand;

        /// <summary>The garment to put on, on the no-building path.</summary>
        public Apparel apparel;

        public LocalTargetInfo Target => stand != null ? (LocalTargetInfo)stand : (LocalTargetInfo)apparel;
        public bool UsesStand => stand != null;
    }

    /// <summary>
    /// The two ways into ceremonial clothes: the outfit stand first, a loose garment second.
    ///
    /// The stand is the Odyssey <c>Building_OutfitStand</c>. That type lives in
    /// <c>Assembly-CSharp</c> like all DLC code: naming it breaks nothing when Odyssey is absent,
    /// only its def is missing. That is what makes Odyssey a soft dependency.
    /// </summary>
    public static class CeremonialWardrobe
    {
        /// <summary>Tag applied by patch to the ceremonial garments of the game, and open to mods.</summary>
        public const string CeremonialTag = "FTO_Ceremonial";

        // ------------------------------------------------------------------ choosing

        public static PrepPlan TryPlan(Pawn pawn, float maxDistance)
        {
            if (pawn == null || !pawn.Spawned || pawn.Map == null || pawn.apparel == null) return null;

            PrepPlan viaStand = TryPlanStand(pawn, maxDistance);
            if (viaStand != null) return viaStand;

            return TryPlanLooseApparel(pawn, maxDistance);
        }

        /// <summary>
        /// A stand assigned to the pawn, holding something they can wear. The stand comes first:
        /// it returns their clothes exactly as they were, force-worn flags included, whereas the
        /// no-building path drops the displaced clothes on the floor.
        /// </summary>
        static PrepPlan TryPlanStand(Pawn pawn, float maxDistance)
        {
            foreach (Building_OutfitStand stand in pawn.Map.listerBuildings
                         .AllBuildingsColonistOfClass<Building_OutfitStand>())
            {
                CompAssignableToPawn_CeremonialStand comp =
                    stand.TryGetComp<CompAssignableToPawn_CeremonialStand>();
                if (comp == null || !comp.AssignedAnything(pawn)) continue;
                if (PreparationTracker.StandInUse(stand, pawn)) continue;
                if (maxDistance > 0f && !stand.Position.InHorDistOf(pawn.Position, maxDistance)) continue;
                if (stand.IsForbidden(pawn)) continue;
                if (!pawn.CanReserveAndReach(stand, PathEndMode.InteractionCell, Danger.Deadly)) continue;
                if (!AnythingWearable(stand, pawn)) continue;

                return new PrepPlan { stand = stand };
            }
            return null;
        }

        /// <summary><c>HeldItems</c> is an <c>IReadOnlyList</c>: there is no <c>Contains</c> on it.</summary>
        static bool ContainedIn(Building_OutfitStand stand, Thing t)
        {
            IReadOnlyList<Thing> held = stand.HeldItems;
            for (int i = 0; i < held.Count; i++) if (held[i] == t) return true;
            return false;
        }

        static bool AnythingWearable(Building_OutfitStand stand, Pawn pawn)
        {
            foreach (Thing t in stand.HeldItems)
                if (t is Apparel a && CanWear(pawn, a)) return true;
            return false;
        }

        /// <summary>
        /// The most valuable ceremonial garment the pawn can reach. Market value stands in for
        /// splendour: it is what separates a thrumbofur robe from a cloth one, without inventing
        /// a stat.
        /// </summary>
        static PrepPlan TryPlanLooseApparel(Pawn pawn, float maxDistance)
        {
            Apparel best = null;
            float bestScore = 0f;

            foreach (Thing t in pawn.Map.listerThings.ThingsInGroup(ThingRequestGroup.Apparel))
            {
                if (!(t is Apparel a) || !a.Spawned) continue;
                if (a.def.apparel?.tags == null || !a.def.apparel.tags.Contains(CeremonialTag)) continue;
                if (maxDistance > 0f && !a.Position.InHorDistOf(pawn.Position, maxDistance)) continue;
                if (a.IsForbidden(pawn) || !CanWear(pawn, a)) continue;
                if (!pawn.CanReserveAndReach(a, PathEndMode.ClosestTouch, Danger.Deadly)) continue;

                float score = a.MarketValue;
                if (score > bestScore)
                {
                    bestScore = score;
                    best = a;
                }
            }

            return best == null ? null : new PrepPlan { apparel = best };
        }

        static bool CanWear(Pawn pawn, Apparel a)
        {
            if (a == null || a.Destroyed) return false;
            if (!a.PawnCanWear(pawn) || !ApparelUtility.HasPartsToWear(pawn, a.def)) return false;
            if (CompBiocodable.IsBiocoded(a) && !CompBiocodable.IsBiocodedFor(a, pawn)) return false;
            if (pawn.apparel.WornApparel.Contains(a)) return false;
            // A locked garment (ideology role, royal title) cannot make way.
            foreach (Apparel worn in pawn.apparel.WornApparel)
                if (!ApparelUtility.CanWearTogether(a.def, worn.def, pawn.RaceProps.body)
                    && pawn.apparel.IsLocked(worn)) return false;
            return true;
        }

        // ------------------------------------------------------------------ dressing

        /// <summary>
        /// Dresses the pawn and returns what it takes to undo it. Returns null when nothing moved:
        /// an empty record would make the pawn count as prepared without having changed at all.
        /// </summary>
        public static PreparationRecord Dress(Pawn pawn, PrepPlan plan)
        {
            PreparationRecord record = plan.UsesStand
                ? DressFromStand(pawn, (Building_OutfitStand)plan.stand)
                : DressFromFloor(pawn, plan.apparel);

            if (record == null) return null;
            ApplyTattoo(pawn, record);
            return record;
        }

        static PreparationRecord DressFromStand(Pawn pawn, Building_OutfitStand stand)
        {
            List<Apparel> toTake = new List<Apparel>();
            List<Apparel> toPark = new List<Apparel>();

            foreach (Thing t in stand.HeldItems)
            {
                if (!(t is Apparel a) || !CanWear(pawn, a)) continue;
                toTake.Add(a);
                foreach (Apparel worn in pawn.apparel.WornApparel)
                    if (!ApparelUtility.CanWearTogether(a.def, worn.def, pawn.RaceProps.body)
                        && !toPark.Contains(worn)) toPark.Add(worn);
            }
            if (toTake.Count == 0) return null;

            PreparationRecord record = new PreparationRecord { stand = stand };

            // The force-worn flag does not survive removal: capturing it here is the last moment
            // at which the information still exists.
            foreach (Apparel worn in toPark)
                if (pawn.outfits != null && pawn.outfits.forcedHandler.IsForced(worn))
                    record.forcedAtCheckIn.Add(worn);

            // Order copied from vanilla (JobDriver_UseOutfitStand.DoTransfer): strip the pawn
            // first, then take and wear, and only then deposit. Depositing first would fill the
            // stand up.
            foreach (Apparel worn in toPark) pawn.apparel.Remove(worn);

            foreach (Apparel a in toTake)
            {
                stand.RemoveApparel(a);
                pawn.apparel.Wear(a);
                pawn.outfits?.forcedHandler.SetForced(a, true);
                record.taken.Add(a);
            }

            foreach (Apparel worn in toPark)
            {
                if (stand.AddApparel(worn)) record.parked.Add(worn);
                else GenPlace.TryPlaceThing(worn, pawn.Position, pawn.Map, ThingPlaceMode.Near);
            }

            return record;
        }

        static PreparationRecord DressFromFloor(Pawn pawn, Apparel apparel)
        {
            if (apparel == null || apparel.Destroyed || !CanWear(pawn, apparel)) return null;

            // dropReplacedApparel: the displaced clothes fall on the floor, exactly as they do
            // when the player changes an apparel policy by hand. Nothing to remember to give back.
            pawn.apparel.Wear(apparel, true);
            pawn.outfits?.forcedHandler.SetForced(apparel, true);

            PreparationRecord record = new PreparationRecord();
            record.taken.Add(apparel);
            return record;
        }

        // ------------------------------------------------------------------ the return trip

        /// <summary>
        /// Undoes what <see cref="Dress"/> did. The no-building path undoes itself on the spot and
        /// for free: dropping the force-worn flag is enough, and <c>JobGiver_OptimizeApparel</c>
        /// re-dresses the pawn on its own. Only the stand path needs a return trip.
        /// </summary>
        public static void Undress(Pawn pawn, PreparationRecord record)
        {
            if (pawn == null || record == null) return;

            if (record.stand is Building_OutfitStand stand && !stand.Destroyed && stand.Spawned
                && pawn.apparel != null)
            {
                foreach (Apparel a in record.taken)
                {
                    if (a == null || a.Destroyed || !pawn.apparel.WornApparel.Contains(a)) continue;
                    pawn.apparel.Remove(a);
                    if (!stand.AddApparel(a))
                        GenPlace.TryPlaceThing(a, pawn.Position, pawn.Map, ThingPlaceMode.Near);
                }

                foreach (Apparel a in record.parked)
                {
                    if (a == null || a.Destroyed) continue;
                    if (!ContainedIn(stand, a)) continue;
                    stand.RemoveApparel(a);
                    pawn.apparel.Wear(a);
                    // Restored after Wear, never before: Notify_ApparelRemoved clears the flag.
                    if (record.forcedAtCheckIn.Contains(a)) pawn.outfits?.forcedHandler.SetForced(a, true);
                }
            }
            else
            {
                // No-building path, or a stand that disappeared meanwhile: the outfit simply goes
                // back under the apparel policy.
                foreach (Apparel a in record.taken)
                    if (a != null && !a.Destroyed) pawn.outfits?.forcedHandler.SetForced(a, false);
            }

            RestoreTattoo(pawn, record);
            PreparationTracker.Forget(pawn);
        }

        // ------------------------------------------------------------------ adornment

        /// <summary>
        /// A tattoo has no permanence in the engine at all: setting and clearing a
        /// <c>TattooDef</c> is instant and free. On a pawn who normally wears none it reads
        /// exactly like face paint for the occasion - and that is why a pawn who already has one
        /// is left alone. You do not erase somebody else's mark for an evening.
        /// </summary>
        static void ApplyTattoo(Pawn pawn, PreparationRecord record)
        {
            if (!ForTheOccasionMod.Settings.tattooEnabled) return;
            if (pawn.style == null || !ModsConfig.IdeologyActive) return;
            if (pawn.story == null || !pawn.RaceProps.Humanlike) return;
            if (pawn.style.FaceTattoo != null && pawn.style.FaceTattoo != TattooDefOf.NoTattoo_Face) return;

            TattooDef chosen = PawnStyleItemChooser.RandomTattooFor(pawn, TattooType.Face);
            if (chosen == null || chosen == TattooDefOf.NoTattoo_Face) return;

            record.previousFaceTattoo = pawn.style.FaceTattoo;
            record.previousBodyTattoo = pawn.style.BodyTattoo;
            record.tattooChanged = true;

            pawn.style.FaceTattoo = chosen;
            pawn.style.Notify_StyleItemChanged();
        }

        static void RestoreTattoo(Pawn pawn, PreparationRecord record)
        {
            if (!record.tattooChanged || pawn.style == null) return;
            pawn.style.FaceTattoo = record.previousFaceTattoo ?? TattooDefOf.NoTattoo_Face;
            pawn.style.BodyTattoo = record.previousBodyTattoo ?? TattooDefOf.NoTattoo_Body;
            pawn.style.Notify_StyleItemChanged();
        }
    }
}

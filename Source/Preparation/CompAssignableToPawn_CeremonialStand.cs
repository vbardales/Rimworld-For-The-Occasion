using System.Collections.Generic;
using System.Linq;
using RimWorld;
using UnityEngine;
using Verse;

namespace ForTheOccasion
{
    public class CompProperties_AssignableToPawn_CeremonialStand : CompProperties_AssignableToPawn
    {
        public CompProperties_AssignableToPawn_CeremonialStand()
        {
            compClass = typeof(CompAssignableToPawn_CeremonialStand);
            // The vanilla stand displays no owner name at all, and Shift Change draws its own
            // label on the same building. Two comps that draw mean two labels on top of each
            // other, so we leave that one to it.
            drawAssignmentOverlay = false;
            drawUnownedAssignmentOverlay = false;
        }
    }

    /// <summary>
    /// Marks an outfit stand as a colonist's ceremonial wardrobe.
    ///
    /// Two precautions, both forced by the fact that this comp is attached to a **shared** def
    /// that other mods patch too:
    ///
    /// - <c>CompAssignableToPawn</c> scribes <c>assignedPawns</c> **flat** into the thing's save
    ///   node. Two subclasses on the same def would read each other's owners on load.
    ///   <c>PostExposeData</c> is therefore overridden **without calling base**, with prefixed keys.
    /// - The base gizmo is hardcoded to <c>KeyBindingDefOf.Misc4</c>, which is **N**, and that is
    ///   also the shortcut of the storage settings clipboard
    ///   (<c>StorageSettingsClipboard</c>) - and an outfit stand is a storage building. The gizmo
    ///   is therefore rebuilt here without a hotkey.
    /// </summary>
    public class CompAssignableToPawn_CeremonialStand : CompAssignableToPawn
    {
        public override IEnumerable<Pawn> AssigningCandidates
        {
            get
            {
                if (!parent.Spawned) return Enumerable.Empty<Pawn>();
                return parent.Map.mapPawns.FreeColonists;
            }
        }

        public override IEnumerable<Gizmo> CompGetGizmosExtra()
        {
            if (parent.Faction != Faction.OfPlayer) yield break;

            Command_Action command = new Command_Action
            {
                defaultLabel = "FTO_SetCeremonialOwner".Translate(),
                defaultDesc = "FTO_SetCeremonialOwnerDesc".Translate(),
                icon = ContentFinder<Texture2D>.Get("UI/Commands/AssignOwner"),
                action = delegate { Find.WindowStack.Add(new Dialog_AssignBuildingOwner(this)); }
                // No hotKey: Misc4 is already taken by the storage settings clipboard.
            };
            yield return command;
        }

        /// <summary>
        /// **Do not call base.** It would write <c>assignedPawns</c>, the same key as any other
        /// <c>CompAssignableToPawn</c> attached to this stand.
        /// </summary>
        public override void PostExposeData()
        {
            Scribe_Collections.Look(ref assignedPawns, "FTO_assignedPawns", LookMode.Reference);
            Scribe_Collections.Look(ref uninstalledAssignedPawns, "FTO_uninstalledAssignedPawns", LookMode.Reference);

            if (Scribe.mode == LoadSaveMode.PostLoadInit)
            {
                if (assignedPawns == null) assignedPawns = new List<Pawn>();
                if (uninstalledAssignedPawns == null) uninstalledAssignedPawns = new List<Pawn>();
                assignedPawns.RemoveAll(x => x == null);
                uninstalledAssignedPawns.RemoveAll(x => x == null);
            }
        }

        public override string CompInspectStringExtra()
        {
            if (AssignedPawnsForReading.Count == 0) return null;
            return "FTO_CeremonialWardrobeOf".Translate(AssignedPawnsForReading[0].LabelShort);
        }
    }
}

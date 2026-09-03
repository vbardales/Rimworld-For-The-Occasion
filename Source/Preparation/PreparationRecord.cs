using System.Collections.Generic;
using RimWorld;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// What it takes to undo a preparation. A prepared pawn is wearing an outfit that is not
    /// theirs: without this record, they would wear it forever.
    /// </summary>
    public class PreparationRecord : IExposable
    {
        /// <summary>The stand used, or null when the pawn dressed without a building.</summary>
        public Building stand;

        /// <summary>What the pawn left in the stand. Empty on the no-building path.</summary>
        public List<Apparel> parked = new List<Apparel>();

        /// <summary>What the pawn put on, and will have to give back.</summary>
        public List<Apparel> taken = new List<Apparel>();

        /// <summary>
        /// The parked garments that were flagged force-worn at check-in. Every removal destroys
        /// that flag - <c>Pawn_ApparelTracker.Notify_ApparelRemoved</c> calls
        /// <c>SetForced(ap, false)</c> unconditionally - so check-in is the last moment at which
        /// the fact still exists anywhere in the game.
        /// </summary>
        public List<Apparel> forcedAtCheckIn = new List<Apparel>();

        public TattooDef previousFaceTattoo;
        public TattooDef previousBodyTattoo;
        public bool tattooChanged;

        /// <summary>Tick at which the pawn got ready: used to expire a forgotten preparation.</summary>
        public int preparedTick;

        public void ExposeData()
        {
            Scribe_References.Look(ref stand, "stand");
            Scribe_Collections.Look(ref parked, "parked", LookMode.Reference);
            Scribe_Collections.Look(ref taken, "taken", LookMode.Reference);
            Scribe_Collections.Look(ref forcedAtCheckIn, "forcedAtCheckIn", LookMode.Reference);
            Scribe_Defs.Look(ref previousFaceTattoo, "previousFaceTattoo");
            Scribe_Defs.Look(ref previousBodyTattoo, "previousBodyTattoo");
            Scribe_Values.Look(ref tattooChanged, "tattooChanged", false);
            Scribe_Values.Look(ref preparedTick, "preparedTick", 0);

            if (Scribe.mode == LoadSaveMode.PostLoadInit)
            {
                if (parked == null) parked = new List<Apparel>();
                if (taken == null) taken = new List<Apparel>();
                if (forcedAtCheckIn == null) forcedAtCheckIn = new List<Apparel>();
                parked.RemoveAll(a => a == null);
                taken.RemoveAll(a => a == null);
                forcedAtCheckIn.RemoveAll(a => a == null);
            }
        }
    }
}

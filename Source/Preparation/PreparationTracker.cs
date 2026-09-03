using System.Collections.Generic;
using System.Linq;
using RimWorld;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// The register of preparations in progress.
    ///
    /// A <c>GameComponent</c> rather than a comp patched onto the <c>Human</c> def: patching the
    /// comps of <c>Human</c> would miss every modded race, and there are whole colonies without a
    /// single pawn of the vanilla def.
    /// </summary>
    public class PreparationTracker : GameComponent
    {
        /// <summary>Pawns currently in ceremonial clothes, and how to put them back.</summary>
        Dictionary<Pawn, PreparationRecord> records = new Dictionary<Pawn, PreparationRecord>();

        /// <summary>
        /// Pawns invited to get ready, and until when. Deliberately not scribed: this is an
        /// intention lasting a few thousand ticks, not game state, and a save that loses it simply
        /// falls back on vanilla behaviour.
        /// </summary>
        readonly Dictionary<Pawn, int> pending = new Dictionary<Pawn, int>();

        List<Pawn> tmpPawns;
        List<PreparationRecord> tmpRecords;

        static PreparationTracker Instance => Verse.Current.Game?.GetComponent<PreparationTracker>();

        public PreparationTracker(Game game) { }

        // ---------------------------------------------------------------- reading

        public static bool IsPrepared(Pawn p)
        {
            PreparationTracker t = Instance;
            return p != null && t != null && t.records.ContainsKey(p);
        }

        public static PreparationRecord RecordFor(Pawn p)
        {
            PreparationTracker t = Instance;
            if (p == null || t == null) return null;
            return t.records.TryGetValue(p, out PreparationRecord r) ? r : null;
        }

        public static bool IsPending(Pawn p)
        {
            PreparationTracker t = Instance;
            if (p == null || t == null) return false;
            return t.pending.TryGetValue(p, out int until) && Find.TickManager.TicksGame <= until;
        }

        /// <summary>A stand already taken by somebody else is not available.</summary>
        public static bool StandInUse(Building stand, Pawn except)
        {
            PreparationTracker t = Instance;
            if (t == null || stand == null) return false;
            foreach (KeyValuePair<Pawn, PreparationRecord> pair in t.records)
                if (pair.Value.stand == stand && pair.Key != except) return true;
            return false;
        }

        // ---------------------------------------------------------------- writing

        public static void MarkPending(Pawn p, int untilTick)
        {
            PreparationTracker t = Instance;
            if (t == null || p == null) return;
            t.pending[p] = untilTick;
        }

        public static void ClearPending(Pawn p)
        {
            Instance?.pending.Remove(p);
        }

        public static void Register(Pawn p, PreparationRecord record)
        {
            PreparationTracker t = Instance;
            if (t == null || p == null || record == null) return;
            record.preparedTick = Find.TickManager.TicksGame;
            t.records[p] = record;
            t.pending.Remove(p);
        }

        public static void Forget(Pawn p)
        {
            Instance?.records.Remove(p);
        }

        /// <summary>
        /// Plain forgetting, giving nothing back: the pawn is no longer there to be given anything.
        /// Called when vanilla considers ownership to have ended - death, trade, kidnapping,
        /// leaving the map, banishment.
        /// </summary>
        public static void Reap(Pawn p)
        {
            PreparationTracker t = Instance;
            if (t == null || p == null) return;
            t.records.Remove(p);
            t.pending.Remove(p);
        }

        // ---------------------------------------------------------------- housekeeping

        public override void GameComponentTick()
        {
            if (FtoLog.Disabled) return;
            if (Find.TickManager.TicksGame % 600 != 0) return;

            // Purge expired intentions, and records whose pawn left the map without going through
            // a path we reap (loading a save older than the mod, a third-party mod destroying a
            // pawn, and so on).
            List<Pawn> stale = null;
            int now = Find.TickManager.TicksGame;

            foreach (KeyValuePair<Pawn, int> pair in pending)
                if (pair.Key == null || pair.Key.Destroyed || now > pair.Value)
                    (stale ?? (stale = new List<Pawn>())).Add(pair.Key);
            if (stale != null) { foreach (Pawn p in stale) pending.Remove(p); stale = null; }

            foreach (KeyValuePair<Pawn, PreparationRecord> pair in records)
                if (pair.Key == null || pair.Key.Destroyed || pair.Key.Dead)
                    (stale ?? (stale = new List<Pawn>())).Add(pair.Key);
            if (stale != null) foreach (Pawn p in stale) records.Remove(p);
        }

        public override void ExposeData()
        {
            base.ExposeData();
            Scribe_Collections.Look(ref records, "records", LookMode.Reference, LookMode.Deep,
                ref tmpPawns, ref tmpRecords);

            if (Scribe.mode == LoadSaveMode.PostLoadInit)
            {
                if (records == null) records = new Dictionary<Pawn, PreparationRecord>();
                // A null key after loading means the pawn no longer exists: without this purge the
                // dictionary would keep an entry nothing can ever give back.
                foreach (Pawn key in records.Where(kv => kv.Key == null || kv.Value == null)
                                            .Select(kv => kv.Key).ToList())
                    records.Remove(key);
            }
        }
    }
}

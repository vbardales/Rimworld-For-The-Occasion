using System.Collections.Generic;
using RimWorld;
using Verse;
using Verse.AI.Group;

namespace ForTheOccasion
{
    /// <summary>
    /// The two reasons a colonist can have to dress up, and the only question the
    /// <c>StartJob</c> prefix asks: should this pawn be dressed for the occasion, right now?
    ///
    /// The rule is **symmetric**. What makes a pawn dress also makes them change back: when the
    /// reason goes away, they change at the next job boundary. Nothing else has to decide the
    /// return trip.
    /// </summary>
    public static class PreparationReason
    {
        /// <summary>
        /// True if the pawn should go and get dressed now. <paramref name="maxDistance"/> is 0
        /// when distance is not limited (anticipation: nothing is running yet) and the settings
        /// value when the detour costs ritual progress.
        /// </summary>
        public static bool WantsToDress(Pawn pawn, out float maxDistance)
        {
            maxDistance = 0f;
            FtoSettings s = ForTheOccasionMod.Settings;
            if (!s.preparationEnabled || pawn == null) return false;

            // Ritual launched: the pawn was marked when the lord was created. The detour leaves at
            // the moment of departure, so it costs progress - hence the distance limit.
            if (s.prepareOnLaunch && PreparationTracker.IsPending(pawn))
            {
                maxDistance = s.maxDetourDistance;
                return true;
            }

            // Anticipation: an obligation has just been announced and the colony gets ready. Free,
            // and the real meaning of a pawn anticipating - nothing is running yet.
            return s.prepareOnObligation && pawn.IsFreeColonist && ObligationWatch.WindowOpen();
        }

        /// <summary>
        /// True as long as the pawn should **stay** dressed. Being in a running ritual retains but
        /// does not trigger: without that distinction, switching off "get ready at launch" would
        /// have no effect at all, since every participant would have dressed merely by taking part.
        /// </summary>
        public static bool ShouldStayDressed(Pawn pawn)
        {
            if (!ForTheOccasionMod.Settings.preparationEnabled) return false;
            if (InRitual(pawn)) return true;
            return WantsToDress(pawn, out _);
        }

        public static bool InRitual(Pawn pawn)
        {
            return pawn?.GetLord()?.LordJob is LordJob_Ritual;
        }
    }

    /// <summary>
    /// The anticipation window. A ritual obligation lives for up to nine days
    /// (<c>RitualObligation.StageDays</c>), but nobody stands around in evening dress for nine
    /// days: the window opens on the announcement and closes after the configured number of
    /// hours. Past it, colonists change back, and a ritual launched later pays for a last-minute
    /// detour instead.
    ///
    /// Recomputed at most once per 250 ticks: the <c>StartJob</c> prefix asks it dozens of times
    /// a second.
    /// </summary>
    public static class ObligationWatch
    {
        static int lastCheckTick = -99999;
        static bool cachedOpen;

        public static void Invalidate()
        {
            lastCheckTick = -99999;
            cachedOpen = false;
        }

        public static bool WindowOpen()
        {
            int now = Find.TickManager?.TicksGame ?? 0;
            // now < lastCheckTick means an older save was loaded in the same session, and the
            // cache would be pinned to a future that no longer exists. Recompute.
            if (now >= lastCheckTick && now - lastCheckTick < 250) return cachedOpen;
            lastCheckTick = now;
            cachedOpen = Compute(now);
            return cachedOpen;
        }

        static bool Compute(int now)
        {
            if (!ModsConfig.IdeologyActive) return false;
            Faction player = Faction.OfPlayerSilentFail;
            if (player?.ideos == null) return false;

            int window = (int)(ForTheOccasionMod.Settings.obligationWindowHours * 2500f);

            foreach (Ideo ideo in player.ideos.AllIdeos)
            {
                List<Precept> precepts = ideo.PreceptsListForReading;
                for (int i = 0; i < precepts.Count; i++)
                {
                    if (!(precepts[i] is Precept_Ritual ritual)) continue;
                    if (ritual.activeObligations == null) continue;
                    for (int j = 0; j < ritual.activeObligations.Count; j++)
                    {
                        RitualObligation ob = ritual.activeObligations[j];
                        if (ob != null && ob.ActiveForTicks <= window) return true;
                    }
                }
            }
            return false;
        }
    }
}

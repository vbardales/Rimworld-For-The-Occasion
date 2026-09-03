using System;
using System.Collections.Generic;
using Verse;

namespace ForTheOccasion
{
    /// <summary>
    /// The mod's log, and its safety switch.
    ///
    /// The prefix on <c>Pawn_JobTracker.StartJob</c> runs when **every** job of **every** pawn
    /// starts. An unhandled exception there bricks the whole colony. So every hook catches, logs
    /// once, disables the mod for the session, and lets vanilla carry on as if it were not
    /// installed.
    /// </summary>
    public static class FtoLog
    {
        public const string Prefix = "[For the Occasion] ";

        static readonly HashSet<string> alreadySaid = new HashSet<string>();

        /// <summary>True as soon as a hook has thrown: nothing else is inserted until restart.</summary>
        public static bool Disabled { get; private set; }

        public static void Message(string msg)
        {
            Log.Message(Prefix + msg);
        }

        /// <summary>The same warning never repeats: it would land on every tick.</summary>
        public static void WarnOnce(string key, string msg)
        {
            if (!alreadySaid.Add(key)) return;
            Log.Warning(Prefix + msg);
        }

        /// <summary>
        /// Last line of defence. Cuts the mod off for the session: a silent mod beats a frozen
        /// colony.
        /// </summary>
        public static void Fail(string where, Exception e)
        {
            Disabled = true;
            if (alreadySaid.Add("fail:" + where))
                Log.Error(Prefix + "disabled for this session after an exception in " + where + ": " + e);
        }
    }
}

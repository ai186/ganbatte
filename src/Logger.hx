package;

import haxe.Log;

class Logger {

    // Taken from hx-color-trace
    inline public static var RED="\033[0;31m";
	inline public static var GREEN="\033[0;32m";
	inline public static var YELLOW="\033[0;33m";
	inline public static var BLUE="\033[0;34m";
	inline public static var MAGENTA="\033[0;35m";
	inline public static var CYAN="\033[0;36m";
	inline public static var NO_COLOR="\033[0m";

    public static var saveLogs:Bool = false;
    public static var historyMessageLimit:Int = 50;
    public static var history(default, null):Array<String> = [];

    public static function log(message:String, ?category:String = "General") {
        if (saveLogs) {
            history.push('[LOG - ${category}] $message');
            deleteOldLogs();
        }
        Log.trace('$NO_COLOR[LOG - ${category}] $message');
    }

    public static function warn(message:String, ?category:String = "General") {
        if (saveLogs) {
            history.push('[WARN - ${category}] $message');
            deleteOldLogs();
        }
        Log.trace('$YELLOW[WARN - ${category}] $message$NO_COLOR');
    }

    public static function error(message:String, ?category:String = "General") {
        if (saveLogs) {
            history.push('[ERROR - ${category}] $message');
            deleteOldLogs();
        }
        Log.trace('$RED[ERROR - ${category}] $message$NO_COLOR');
    }

    public static function suggest(message:String, ?category:String = "General") {
        if (saveLogs) {
            history.push('[SUGGESTION - ${category}] $message');
            deleteOldLogs();
        }

        Log.trace('$BLUE[SUGGESTION - ${category}] $message$NO_COLOR');
    }

    private inline static function deleteOldLogs() {
        if (historyMessageLimit == -1)
            return;
        while (history.length > historyMessageLimit)
            history.shift();
    }
}
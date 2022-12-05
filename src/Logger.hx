package;

import haxe.Log;
import openfl.globalization.DateTimeFormatter;

class Logger {
    public static function log(message:String, ?category:String = "General") {
        var t = Date.now();
        var formattedT = '${t.getHours()}:${t.getMinutes()}:${t.getSeconds()}';

        Log.trace('[${formattedT} - ${category}] $message');
    }
}
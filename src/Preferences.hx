import sys.io.File;
import haxe.Json;
import sys.FileSystem;

class Preferences {

    public static var preferences:Dynamic;

    public static function loadPrefs() {
        var f = "assets/data/preferences.json";
        if (!FileSystem.exists(f)) {
            Logger.error("Could not find \"assets/data/preferences.json\" Using default preferences!", "data/save");
        }

        preferences = cast Json.parse(File.getContent(f));
        return preferences;
    }

    public static inline function savePrefs() {
        File.saveContent("assets/data/preferences.json", Json.stringify(preferences));
    }
}
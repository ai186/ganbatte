package parsers;

import sys.io.File;
import haxe.Json;
import sys.FileSystem;

/**
 * * Lesson File Structures
 * * root/
 * * * pages/...
 * * * images/...
 * * * audios/...
 * * * scripts/...
 * * lesson.json
 */

class ScriptParser {
    public static function parse(lessonName:String) {
        var path = "assets/lessons/" + lessonName + "/";
        var lessonFilePath = path + "lesson.json";
        var pagesDir = path + "pages/";
        var imagesDir = path + "images/";
        var audiosDir = path + "audios/";
        var scriptsDir = path + "scripts/";

        var lessonFile:Dynamic;

        if (!FileSystem.exists(lessonFilePath)) {
            Logger.error("Could not find " + lessonFilePath + "!", "lua/parsing");
            return;
        } else {
            lessonFile = Json.parse(File.getContent(lessonFilePath));
        }
        if (!FileSystem.exists(pagesDir)) {
            Logger.error(pagesDir + " is not a valid directory!", "lua/parsing");
            return;
        }
        if (!FileSystem.exists(scriptsDir)) {
            Logger.log(scriptsDir + " is not a valid directory!", "lua/parsing");
            return;
        }
        if (!FileSystem.exists(imagesDir)) {
            Logger.log(imagesDir + " is not a valid directory!", "lua/parsing");
            if (lessonFile.usesImages)
                return;
        }
        if (!FileSystem.exists(audiosDir)) {
            Logger.log(audiosDir + " is not a valud directory!", "lua/parsing");
            if (lessonFile.usesAudios)
                return;
        }
    }
}

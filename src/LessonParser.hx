package;

import haxe.zip.Writer;
import haxe.zip.Reader;
import haxe.zip.Entry;
import screens.Screen;
import luaimpl.LuaScript;
import lime.utils.Log;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

using StringTools;
typedef PageFile = {
    var script:String;
    var nextPage:String;
};

typedef DirLessonInfo = Array<{script:String}>;
typedef ZipLessonInfo = {
    var lessonFile:Array<{script:String}>;
    var scripts:Array<Entry>;
}

class LessonParser {

    public static function loadLessonFromZipFile(name:String):ZipLessonInfo {
        
        var lessonInfo:ZipLessonInfo = {lessonFile: null, scripts: []};
        var lessonZipFile = 'assets/lessons/$name';

        if (FileSystem.exists(lessonZipFile)) {
            var entries = ZipTools.getZipEntries(lessonZipFile);
            for (e in entries) {
                if (e.fileName != 'scripts/' && e.fileName.startsWith('scripts/')) {
                    lessonInfo.scripts.push(e);
                } else if (e.fileName == 'lesson.json') {
                    lessonInfo.lessonFile = Json.parse(e.data.toString());
                }
            }
        }

        return lessonInfo;
    }

    public static function loadLessonFromFolder(name:String):DirLessonInfo {
        var lessonFolder = 'assets/lessons/$name/';

        if (FileSystem.exists(lessonFolder) && FileSystem.isDirectory(lessonFolder) && FileSystem.exists(lessonFolder + 'pages.json')) {
            return cast Json.parse(File.getContent(lessonFolder + 'pages.json'));
        }

        return null;
    }
}
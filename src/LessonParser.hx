package;

import screens.Screen;
import luaimpl.LuaScript;
import lime.utils.Log;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

typedef PageFile = {
    var script:String;
    var nextPage:String;
};

class LessonParser {
    public static function loadLessonFromFolder(name:String, screen:Screen) {
        var LESSON_FOLDER = 'assets/lessons/';
        trace(LESSON_FOLDER + name);
        if (FileSystem.exists(LESSON_FOLDER + name) && FileSystem.isDirectory(LESSON_FOLDER + name)) {
            var dirContents = FileSystem.readDirectory(LESSON_FOLDER + name);
            LESSON_FOLDER += name;
            var lessonFile:Dynamic;
            var pages:Array<String>;
            var scripts:Array<String>;

            if (FileSystem.exists(LESSON_FOLDER + 'lessonfile')) {
                lessonFile = cast Json.parse(File.getContent(LESSON_FOLDER + 'lesson.json'));
            } else {
                Log.error("Lessonfile for " + name + " not found");
                return null;
            }

            if (FileSystem.exists(LESSON_FOLDER + 'pages/') && FileSystem.isDirectory(LESSON_FOLDER + 'pages/')) {
                pages = FileSystem.readDirectory(LESSON_FOLDER + 'pages/');
            } else {
                Log.error("Pages folder for " + name + " not found");
                return null;
            }
            if (FileSystem.exists(LESSON_FOLDER + 'scripts/') && FileSystem.isDirectory(LESSON_FOLDER + 'scripts/')) {
                scripts = FileSystem.readDirectory(LESSON_FOLDER + 'pages/');
            } else {
                Log.error("Pages folder for " + name + " not found");
                return null;
            }

            if (lessonFile.start == null || !FileSystem.exists(LESSON_FOLDER + 'pages/' +  lessonFile.start)) {
                Log.error("Lesson file \"start\" value is invalid");
                return null;
            }

            var scriptToRun = Json.parse(File.getContent(LESSON_FOLDER + 'pages/' + lessonFile.start)).script;
            trace(LESSON_FOLDER + 'scripts/' + scriptToRun);
            if (FileSystem.exists(LESSON_FOLDER + 'scripts/' + scriptToRun)) {
                return new LuaScript(LESSON_FOLDER + 'scripts/' + scriptToRun, screen);
            }
        }

        return null;
    }
}
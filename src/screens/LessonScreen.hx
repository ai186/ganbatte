package screens;

import luaimpl.LuaScript;
import cpp.UInt8;
import LessonParser.DirLessonInfo;
import LessonParser.ZipLessonInfo;

class LessonScreen extends Screen {

    public static var zipLessonInfo:ZipLessonInfo;
    public static var dirLessonInfo:DirLessonInfo;

    public static inline final ZIP:UInt8 = 0;
    public static inline final DIR:UInt8 = 1;
    public static var lessonFileType:UInt8;

    public static var scriptIndex:Int = 0;
    public static var lessonInstance:LessonScreen;

    public var lessonScript:LuaScript;

    public function new(?lessonName:String) {

        super();

        lessonInstance = this;

        if (zipLessonInfo == null)
            zipLessonInfo = LessonParser.loadLessonFromZipFile('test/test.zip');

        trace(scriptIndex);

        var scriptToLoad = zipLessonInfo.lessonFile[scriptIndex].script;

        for (i in zipLessonInfo.scripts) {
            trace(i.fileName, 'scripts/' + scriptToLoad);
            if (i.fileName == 'scripts/' + scriptToLoad) 
                lessonScript = new LuaScript(i.data.toString(), this);
        }

        trace(lessonScript);
        
    }

    public var gotoNextLesson:Bool = false;

    public override function update(dt:Float) {
        if (gotoNextLesson) {
            lessonScript.close();
            trace('next');
            nextLesson();
            gotoNextLesson = false;
        }
    }

    public static function nextLesson() {
        
        scriptIndex++;

        var scriptToLoad = zipLessonInfo.lessonFile[scriptIndex].script;

        while (lessonInstance.items.length != 0) {
            lessonInstance.items.remove(lessonInstance.items.members[0]);
        }

        for (i in zipLessonInfo.scripts) {
            if (i.fileName == 'scripts/' + scriptToLoad)
                lessonInstance.lessonScript = new LuaScript(i.data.toString(), lessonInstance);
        }
    }
}
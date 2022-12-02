package screens;

import haxe.Json;
import lime.utils.Log;
import sys.io.File;
import sys.FileSystem;
import lime.utils.Assets;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import feathers.controls.Label;
import haxe.Timer;
import luaimpl.LuaScript;
import openfl.display.DisplayObject;

class Screen {
    public var items:Group<DisplayObject> = new Group<DisplayObject>();
    public var luaScript:LuaScript;

    public function new() {
        luaScript = LessonParser.loadLessonFromFolder('test/', this);
    };
    
    public function update(dt:Float) {
        if (luaScript.get("update") != null) {
            luaScript.call("update", dt);
        }
    }

    public function onKeyDown(keyCode:Int) {
        if (luaScript.get("onKeyDown") != null) {
            luaScript.call("onKeyDown", keyCode);
        }
    }

    public function onKeyUp(keyCode:Int) {
        if (luaScript.get("onKeyUp") != null) {
            luaScript.call("onKeyUp", keyCode);
        }
    }

    public function switchScreen(s:Screen) {
        while (items.length != 0)
            items.remove(items.members[0]);

        Main.currentScreen = s;
    }
}
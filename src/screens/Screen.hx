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

    public var items:Group<DisplayObject>;
    public var scripts:Array<LuaScript> = [];

    public function new() {
        items = new Group<DisplayObject>();
    }

    public inline function add(item:DisplayObject) {
        items.add(item);
    }

    public inline function remove(item:DisplayObject) {
        items.remove(item);
    }

    public function update(dt:Float) {
        for (script in scripts) {
            if (script.get("update") != null)
                script.call("update", dt);
        }
    }

    public function onKeyDown(keyCode:Int) {
        for (script in scripts) {
            if (script.get("onKeyDown") != null)
                script.call("onKeyDown", keyCode);
        }
    }

    public function onKeyUp(keyCode:Int) {
        for (script in scripts) {
            if (script.get("onKeyUp") != null)
                script.call("onKeyUp", keyCode);
        }
    }

    public function switchScreen(s:Screen) {
        while (items.length != 0)
            items.remove(items.members[0]);

        Main.currentScreen = s;
    }
}

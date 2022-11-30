package screens;

import feathers.controls.Label;
import haxe.Timer;
import luaimpl.LuaScript;
import openfl.display.DisplayObject;

class Screen {
    public var items:Group<DisplayObject>;
    public var luaScript:LuaScript;

    public function new() {
        items = new Group<DisplayObject>();


        Timer.delay(() -> {		
			luaScript = new LuaScript("assets/scripts/test.lua", this);
		}, 1000);
    };

    public function update(dt:Float) {
        
    }

    public function switchScreen(s:Screen) {

    }
}
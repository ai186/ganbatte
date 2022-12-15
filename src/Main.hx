import openfl.display.Graphics;
import openfl.geom.Point;
import screens.LessonScreen;
import openfl.events.KeyboardEvent;
import openfl.utils.Object;
import openfl.text.StyleSheet;
import haxe.Timer;
import luaimpl.LuaScript;
import feathers.controls.Button;
import feathers.layout.VerticalLayout;
import feathers.controls.ScrollContainer;
import openfl.events.Event;
import screens.Screen;
import feathers.controls.Application;
import feathers.controls.Label;

/*
 * Format of lesson files
 * - directory
 * 	- pages.json // shows where to find lesson pages, orders them
 * 	- 	page_directory
 * 		- .. pages ()
*/

class Main extends Application {

	public static var currentScreen:Screen;
	public static var instance:Main;
	var s:LuaScript;

	var t:Float;
	
	public function new() {
		super();

		instance = this;

		currentScreen = new LessonScreen();

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	var draw = true;

	function onEnterFrame(e:Event) {
		if (currentScreen != null)
		currentScreen.update(1 / 60);
	}

	function onKeyDown(e:KeyboardEvent) {
		currentScreen.onKeyDown(e.keyCode);
	}

	function onKeyUp(e:KeyboardEvent) {
		currentScreen.onKeyUp(e.keyCode);
	}
}
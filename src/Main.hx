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

	public function new() {
		super();

		trace(new Label().textFormat, new Label().backgroundSkin);
		instance = this; //new Label().styleSheet.

		// StyleSheet
		currentScreen = new Screen();

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function switchScreen(s:Screen) {
		// for (m in currentScreen.m)
		currentScreen = s;
	}

	function onEnterFrame(e:Event) {
		if (currentScreen != null)
		currentScreen.update(1 / 60);
	}
}
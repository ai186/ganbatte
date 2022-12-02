package luaimpl;

import lime.text.Font;
import feathers.controls.TextArea;
import openfl.text.TextFormat;
import lime.app.Application;
import feathers.events.TriggerEvent;
import openfl.display.Bitmap;
import haxe.macro.Type.Ref;
import screens.Screen;
import feathers.controls.Button;
import feathers.controls.Label;
import sys.io.File;
import openfl.display.DisplayObject;
import llua.Convert;
import llua.LuaL;
import llua.State;
import llua.Lua;
import sys.FileSystem;

using StringTools;

class LuaScript
{
	public var l:State;

	public var screen:Screen;

	private var references:Map<Int, Dynamic> = [];
	public var buttons:Map<Button, Int> = [];

	private var REFERENCE_NUMBER:UInt = 0;
	private var fns:CoreFunctionsLua;

	public function new(?path:String, ?screen:Screen)
	{
		l = LuaL.newstate();
		LuaL.openlibs(l);
		Lua.init_callbacks(l);

		this.screen = screen;

		if (path == null)
			return;

		fns = new CoreFunctionsLua(this);

		set("lua_version", Lua.version());
		set("luaJIT_version", Lua.versionJIT());
		set("haxe_version", haxe.macro.Compiler.getDefine("haxe_ver"));

		set("WIDTH", Main.instance.stage.stageWidth);
		set("HEIGHT", Main.instance.stage.stageHeight);

		// BASE FUNCTIONS
		set("instantiate", Lua_Instantiate);
		set("add", Lua_Add);
		set("remove", Lua_Remove);
		set("getProperty", Lua_GetProperty);
		set("setProperty", Lua_SetProperty);
		set("setField", Lua_SetFieldUsingID);
		set("setReference", Lua_SetReference);
		set("delReference", Lua_DelReference);

	// COOL functions

		set("getX", (id:Int) -> {
			return Lua_GetProperty(id, "x");
		});

		set("getY", (id:Int) -> {
			return Lua_GetProperty(id, "y");
		});

		set("createLabel", fns.createLabel);
		set("createButton", fns.createButton);

        run(path);
	}

	public function run(path:String)
	{
		if (FileSystem.exists(path))
		{
			try
			{
				LuaL.dofile(l, path);
			}
			catch (e)
			{
				trace('[luaimpl] could not run ' + path + '!');
			}
		}
	}

	public function set<T>(key:String, value:T)
	{
		if (Type.typeof(value) == Type.ValueType.TFunction)
		{
			Lua_helper.add_callback(l, key, value);
			return;
		}
		Convert.toLua(l, value);
		Lua.setglobal(l, key);
	}

	public function unset(key:String)
	{
		var item = get(key);
		if (Lua.type(item, -1) == Lua.LUA_TFUNCTION)
		{
			Lua_helper.remove_callback(l, key);
			return;
		}

		set(key, null);
	}

	public function get(key:String)
	{
		Lua.getglobal(l, key);
		var result = Convert.fromLua(l, -1);
		Lua.pop(l, 1);

		return result;
	}

	public function call(name:String, args:haxe.Rest<Any>)
	{
		try
		{
			Lua.getglobal(l, name);
			var type = Lua.type(l, -1);

			if (type != Lua.LUA_TFUNCTION)
			{
				trace("[luaimpl] could not call " + name + "! it is not a function! (type: " + type + ")");
				Lua.pop(l, 1);
				return null;
			}

			for (arg in args)
				Convert.toLua(l, arg);

			var status = Lua.pcall(l, args.length, 1, 0);

			if (status != Lua.LUA_OK)
			{
				trace("[luaimpl] error calling function " + name + "! (status: " + status + ")");
				return null;
			}

			var result = Convert.fromLua(l, -1);

            Lua.pop(l, 1);
			return result;
		}
		catch (e)
		{
			trace("[luaimpl] error calling function " + name + "!" + "error: " + e.toString());
			return null;
		}
	}

	public function close()
	{
		Lua.close(l);
	}

	// Functions to be used in lua

	// BASE FUNCTIONS

	function Lua_Instantiate(name:String, args:Array<Dynamic>) {

		REFERENCE_NUMBER++;

		switch (name.toLowerCase()) {
			case 'label':
				trace("im making lable");
				var l = new Label();
				references.set(REFERENCE_NUMBER, l);
			case 'button':
				var b:Button;
				b = new Button();
				b.addEventListener(TriggerEvent.TRIGGER, (e:TriggerEvent) -> {
					var button = cast (e.target, Button);
					var id = buttons.get(button);
					call("onButtonPress", id);
				});
				references.set(REFERENCE_NUMBER, b);
				buttons.set(b, REFERENCE_NUMBER);
			case 'bitmap':
				var i = new Bitmap(references.get(args[0]), null, args[1]);
				references.set(REFERENCE_NUMBER, i);
			default:
				var resolvedClass = Type.resolveClass(name);
				if (resolvedClass != null && Type.getSuperClass(resolvedClass) == DisplayObject) {
					var object = Type.createInstance(resolvedClass, args);
					references.set(REFERENCE_NUMBER, object);
				} else {
					REFERENCE_NUMBER--;
				}
		}
		
		return REFERENCE_NUMBER;
	}

	public function update(dt:Float) {
	}

	function Lua_Add(id:Int) {
		screen.items.add(references.get(id));
	}

	function Lua_Remove(id:Int) {
		screen.items.remove(references.get(id));
	}

	function Lua_GetProperty(id:Int, property:String) {
		if (!property.contains('.'))
			return Reflect.getProperty(references.get(id), property);

		var object = references.get(id);
		var splitted = property.split('.');
		
		for (i in 0...splitted.length - 1) {
			object = Reflect.field(object, splitted[i]);
		}

		return Reflect.getProperty(object, splitted[splitted.length-1]);
	}

	function Lua_SetProperty(id:Int, property:String, value:Any)  {
		if (!property.contains('.'))
			return Reflect.setProperty(references.get(id), property, value);
		

		var object = references.get(id);
		var splitted = property.split('.');
		
		for (i in 0...splitted.length - 1) {
			object = Reflect.field(object, splitted[i]);
		}

		Reflect.setProperty(object, splitted[splitted.length - 1], value);
	}

	function Lua_SetField(id:Int, field:String, value:Dynamic) {
		if (!field.contains('.'))
			Reflect.setField(references.get(id), field, value);

		var object = references.get(id);
		var splitted = field.split('.');

		for (i in 0...splitted.length - 1) {
			object = Reflect.field(object, splitted[i]);
		}

		Reflect.setField(object, splitted[splitted.length - 1], value);
	}

	function Lua_SetFieldUsingID(id:Int, field:String, id2:Int) {
		if (!field.contains('.'))
			Reflect.setField(references.get(id), field, references.get(id2));

		var object = references.get(id);
		var splitted = field.split('.');

		for (i in 0...splitted.length - 1) {
			object = Reflect.field(object, splitted[i]);
		}

		Reflect.setField(object, splitted[splitted.length - 1], references.get(id2));
	}

	function Lua_SetReference(id:Int, value:Dynamic) {
		references.set(id, value);
		return id;
	}

	function Lua_DelReference(id:Int, value:Dynamic) {
		references.remove(id);
		return id;
	}
}
class CoreFunctionsLua {

	private var script:LuaScript;

	public function new(script:LuaScript) {
		this.script = script;
	}

	public function createLabel(x:Float, y:Float, text:String, size:Int) {
		incrID();
		trace("mkeing lable");
		var l = new Label(text);
		l.x = x;
		l.y = y;
		l.textFormat = new TextFormat("assets/fonts/IBMPlexSans.ttf", size, 0xff000000);
		setRef(getID(), l);
		return getID();
	}

	public function createButton(x:Float, y:Float, text:String, size:Int) {
		incrID();
		var b:Button;
		b = new Button(text);
		b.addEventListener(TriggerEvent.TRIGGER, (e:TriggerEvent) -> {
			var button = cast (e.target, Button);
			script.call("onButtonPress", script.buttons.get(button));
		});


		b.x = x;
		b.y = y;
		b.textFormat = new TextFormat("assets/fonts/IBMPlexSans.ttf", size, 0xff000000);

		@:privateAccess
		script.buttons.set(b, getID());

		setRef(getID(), b);
		return getID();
	}

	inline function setRef(id:Int, v:Dynamic) {
		@:privateAccess
		script.references.set(id, v);
	}

	inline function getID() {
		@:privateAccess
		return script.REFERENCE_NUMBER;
	}

	inline function incrID() {
		@:privateAccess
		script.REFERENCE_NUMBER++;
	}
}
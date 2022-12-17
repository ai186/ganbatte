package luaimpl;

import openfl.display.BitmapData;
import feathers.events.ButtonBarEvent;
import feathers.data.ArrayCollection;
import feathers.controls.ButtonBar;
import feathers.controls.IToggle;
import feathers.core.ToggleGroup;
import feathers.controls.Alert;
import haxe.Timer;
import screens.LessonScreen;
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

class LuaScript {
	public var l:State;
	public var screen:Screen;
	public var file:String;
	// References
	public var refs:Map<String, Dynamic> = [];

	public function new(file:String, screen:Screen, refs:Map<String, Dynamic>) {
		
		l = LuaL.newstate();
		LuaL.openlibs(l);
		Lua.init_callbacks(l);
		
		this.file = file;
		this.screen = screen;
		this.refs = refs;

		set("getProperty", lGetProperty);
		set("setProperty", lSetProperty);
		set("callMethod", lCallMethod);
		set("setField", lSetField);
		set("__setReference", l__SetReference); // Unsafe function
		set("__getReference", l__GetReference); // Unsafe function
		
		run(file);
	}

	public function run(path:String) {
		try {
			if (FileSystem.exists(path))
				LuaL.dofile(l, path);
			else Logger.log("Could not find file " + path, "lua");
		} catch (e) {
			Logger.error("Could not run Lua file " + path + "! (error: " + e + ")", "lua");
			Logger.suggest("Check if you have input the path correctly!", "lua");
		}
	}

	public function runString(code:String) {
		try {
			LuaL.dostring(l, code);
		} catch (e) {
			Logger.error("Could not run Lua code! (error: " + e + ")", "lua");
			Logger.suggest("Check if you have input the path correctly!", "lua");
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
				Logger.error("Could not call function \"" + name + "\"! It is not a function (type: " + type + ")", "lua");
				Lua.pop(l, 1);
				return null;
			}

			for (arg in args)
				Convert.toLua(l, arg);

			var status = Lua.pcall(l, args.length, 1, 0);

			if (status != Lua.LUA_OK)
			{
				Logger.error("Error calling function \"" + name + "\"! (status: " + status + ")", "lua");
				return null;
			}

			var result = Convert.fromLua(l, -1);

            Lua.pop(l, 1);
			return result;
		}
		catch (e)
		{
			Logger.log("Could not call function \"" + name + "\"! (error: " + e + ")", "lua");
			return null;
		}
	}

	public function close()
	{
		Lua.close(l);
	}

	function lGetProperty(id:String, property:String) {
	if (!property.contains('.'))
		return Reflect.getProperty(refs.get(id), property);

		var object = refs.get(id);
		var splitted = property.split('.');
		
		for (i in 0...splitted.length - 1) {
			object = Reflect.field(object, splitted[i]);
		}

		trace("ZDZDZD");
		trace(Type.typeof(Reflect.getProperty(object, splitted[splitted.length-1])));
		trace("ZDZDZD");
		return Reflect.getProperty(object, splitted[splitted.length-1]);
	}

	function lSetProperty(id:String, property:String, value:Any)  {
		if (!property.contains('.'))
			return Reflect.setProperty(refs.get(id), property, value);
		

		var object = refs.get(id);
		var splitted = property.split('.');
		
		for (i in 0...splitted.length - 1) {
			object = Reflect.field(object, splitted[i]);
		}

		Reflect.setProperty(object, splitted[splitted.length - 1], value);
	}

	function lCallMethod(id:String, fn:String, args:Array<Any>) {
		if (!fn.contains('.'))
			return Reflect.callMethod(refs.get(id), Reflect.field(refs.get(id), fn), args);

		var object = refs.get(id);
		var splitted = fn.split('.');
		for (i in 0...splitted.length - 1)
			object = Reflect.field(object, splitted[i]);

		return Reflect.callMethod(object, Reflect.field(object, splitted[splitted.length -1]), args);
	}

	function lSetField(id:String, field:String, id2:String) {
		if (!field.contains('.'))
			Reflect.setField(refs.get(id), field, refs.get(id2));

		var object = refs.get(id);
		var splitted = field.split('.');

		for (i in 0...splitted.length - 1) {
			object = Reflect.field(object, splitted[i]);
		}

		Reflect.setField(object, splitted[splitted.length - 1], refs.get(id2));
	}

	function l__SetReference(id:String, value:Dynamic) {
		refs.set(id, value);
		return id;
	}

	function l__GetReference(id:String) {
		return refs.get(id);
	}

	function lInstantiate(component:String, args:Array<Dynamic>, id:String) {
		switch (component.toLowerCase()) {
			
		}
	}

	function lGetText(id:String){
		return refs.get(id).text;
	}

	function lAddToDataProvider(id:String, v:Dynamic) {
		refs.get(id).dataProvider.add(v);
	}

	function lRemoveFromDataProvider(id:String, v:Dynamic) {
		refs.get(id).dataProvider.remove(v);
	}

	function lRemoveAtFromDataProvider(id:String, idx:Int) {
		refs.get(id).dataProvider.removeAt(idx);
	}

	function lGetFromDataProvider(id:String, idx:Int) {
		return refs.get(id).dataProvider.get(idx);
	}

	function lLoadImage(id:String, path:String) {
		var img:Bitmap = refs.get(id);
		img.bitmapData = BitmapData.fromFile(path);
	}
}
package luaimpl;

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

	public function new(?path:String, ?screen:Screen)
	{
		l = LuaL.newstate();
		LuaL.openlibs(l);
		Lua.init_callbacks(l);

		this.screen = screen;

		if (path == null)
			return;

		set("lua_version", Lua.version());
		set("luaJIT_version", Lua.versionJIT());
		set("haxe_version", haxe.macro.Compiler.getDefine("haxe_ver"));

		set("instantiate", Lua_Instantiate);
		set("add", Lua_Add);
		set("remove", Lua_Remove);
		set("getProperty", Lua_GetProperty);
		set("setProperty", Lua_SetProperty);

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

	function Lua_Instantiate(name:String, id:Int) {
		switch (name.toLowerCase()) {
			case 'label':
				var l = new Label();
				references.set(id, l);
			case 'button':
				var b = new Button();
				references.set(id, b);
			case 'test':
				var z = {xz: {x: 10}};
				references.set(id, z);
		}
		
		return id;
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
			trace(object, splitted[i]);
			object = Reflect.getProperty(object, splitted[i]);
		}

		return Reflect.getProperty(object, splitted[splitted.length-1]);
	}

	function Lua_SetProperty(id:Int, property:String, value:Any)  {
		if (!property.contains('.'))
			Reflect.setProperty(references.get(id), property, value);

		var object = references.get(id);
		var splitted = property.split('.');
		
		for (i in 0...splitted.length - 1) {
			trace(object, splitted[i]);
			object = Reflect.getProperty(object, splitted[i]);
		}

		Reflect.setProperty(object, splitted[splitted.length - 1], value);
	}
}

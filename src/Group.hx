package;

import openfl.display.DisplayObject;

class Group<T:DisplayObject> {
    public var members:Array<T>;
    public var length(get, never):Int;

    public function new() {
        members = [];   
    }

    public function add(object:T) {
        members.push(object);
        return Main.instance.addChild(object);
    }

    public function remove(object:T) {
        members.remove(object);
        return Main.instance.removeChild(object);
    }

    function get_length()
        return members.length;
}
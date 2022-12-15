package;

import openfl.display.DisplayObject;

class Group<T:DisplayObject> {
    public var members:Array<T>;
    public var length(get, never):Int;

    public function new() {
        members = [];
    }

    public inline function filter(f:T->Bool) {
        return members.filter(f);
    }
    
    public inline function map<R>(f:T->R) {
        return members.map(f);
    }

    public function add(object:T) {
        members.push(object);
        return Main.instance.addChild(object);
    }

    public function remove(object:T) {
        members.remove(object);
        return Main.instance.removeChild(object);
    }

    public function clear() {
        while (length != 0)
            members.pop();
    }

    public function fill(from:Int, to:Int, value:T) {
        for (i in from...to) {
            members[i] = value;
        }

        return members;
    }

    public function free() {
        clear();
        members = null;
    }

    function toString() {
        return 'members: $members | length: $length' ;
    }

    function get_length()
        return members.length;
}
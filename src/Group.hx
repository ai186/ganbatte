package;

import openfl.display.DisplayObject;

class Group<T:DisplayObject> {
    public var members:Array<T>;

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
}
package screens;

import components.Video;
import feathers.events.ButtonBarEvent;
import feathers.events.TriggerEvent;
import feathers.controls.PopUpListView;
import feathers.controls.Check;
import feathers.controls.Drawer;
import openfl.Assets;
import haxe.io.Bytes;
import sys.FileSystem;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import parsers.PageParser;
import feathers.style.IDarkModeTheme;
import feathers.style.Theme;
import feathers.controls.TextInput;
import feathers.controls.TextArea;
import feathers.data.ArrayCollection;
import feathers.controls.ButtonBar;
import openfl.text.Font;
import feathers.text.TextFormat;
import openfl.display.DisplayObject;
import feathers.controls.Label;
import feathers.controls.Button;
import parsers.PageParser.PageElement;
import sys.io.File;
import luaimpl.LuaScript;
import cpp.UInt8;
class LessonScreen extends Screen {

    public var drawer:Drawer;
    public var lessonPageElements:Map<String, DisplayObject> = [];
    static inline final GLOBAL_DEFAULT_FONT = "assets/fonts/IBMPlexSans.ttf";

    public var lessonFolder:String;

    public function new(?lessonName:String, ?type:UInt8 = 1) {
        super();
        Preferences.loadPrefs();
        items.clear();
        lessonPageElements.clear();
        buildPage(PageParser.parse(Xml.parse(File.getContent("assets/pages/test.xml"))));
        cast (Theme.fallbackTheme, IDarkModeTheme).darkMode = Preferences.preferences.darkMode;
        addScript("assets/scripts/test.lua");
    }

    static inline var DEFAULT_FONT_SIZE = 16;
    static inline final DEFAULT_COLOR = 0xFF000000;

    public function buildPage(pageContents:Array<PageElement>) {
        for (el in pageContents) {

            if (el.data["fontSize"] == null)
                el.data["fontSize"] = DEFAULT_FONT_SIZE;
            else
                el.data["fontSize"] = Std.parseInt(el.data["fontSize"]);

            if (el.data["font"] == null)
                el.data["font"] = GLOBAL_DEFAULT_FONT;

            if (el.data["colour"] != null && el.data["color"] == null)
                el.data["color"] = el.data["colour"];

            if (el.data["color"] == null)
                el.data["color"] = DEFAULT_COLOR;
            else
                el.data["color"] = Std.parseInt(el.data["color"]);

            el.data["x"] = Std.parseFloat(el.data["x"]);
            el.data["y"] = Std.parseFloat(el.data["y"]);
            el.data["width"] = Std.parseFloat(el.data["width"]);
            el.data["height"] = Std.parseFloat(el.data["height"]);
            
            switch (el.elementType.toLowerCase()) {
                case 'button':
                    Logger.log("Making button with ID " + el.id, "page/building");
                    var d = el.data;
                    var b = new Button(el.value, (e:TriggerEvent) -> {
                        for (s in scripts)
                            if (s.get("onButtonPress") != null)
                                s.call("onButtonTrigger", el.id);
                    });
                    b.x = d["x"];
                    b.y = d["y"];
                    b.textFormat = new TextFormat(d["font"], Std.parseInt(d["fontSize"]), Std.parseInt(d["color"]));
                    lessonPageElements.set(el.id, b);
                    add(b);
                case 'label':
                    Logger.log("Making Label with ID " + el.id, "page/building");
                    var d = el.data;
                    var l = new Label(el.value);
                    l.x = Std.parseFloat(d["x"]);
                    l.y = Std.parseFloat(d["y"]);
                    l.textFormat = new TextFormat(d["font"], d["fontSize"], d["color"]);
                    lessonPageElements.set(el.id, l);
                    add(l);
                case 'buttonbar':
                    Logger.log("Making Button Bar with ID " + el.id, "page/building");    
                    var d = el.data;
                    var buttonBar = new ButtonBar(new ArrayCollection([]), (e:ButtonBarEvent) -> {
                        for (s in scripts)
                            if (s.get("onButtonBarTrigger") != null)
                                s.call("onButtonBarTrigger", el.id, e.state.index);
                    });
                    buttonBar.itemToText = (item:Dynamic) -> {
                        return item.text;
                    }
                    buttonBar.x = d["x"];
                    buttonBar.y = d["y"];

                    lessonPageElements.set(el.id, buttonBar);
                    add(buttonBar);
                case 'dataitem' | 'data':
                    Logger.log("Processing a DataItem with parent's ID " + el.instance.parent.get("id"), "page/building");
                    var p = el.instance.parent;
                    switch (p.nodeName.toLowerCase()) {
                        case 'buttonbar':
                            var buttonBar:ButtonBar = cast lessonPageElements.get(p.get("id"));
                            buttonBar.dataProvider.add({text: el.value});   
                    }
                case 'textarea':
                    Logger.log("Making Text Area with ID " + el.id, "page/building");
                    var d = el.data;
                    var textArea = new TextArea(el.value, d["prompt"]);
                    textArea.x = d["x"];
                    textArea.y = d["y"];
                    textArea.textFormat = new TextFormat(d["font"], d["fontSize"], d["color"]);
                    textArea.width = d["width"];
                    textArea.height = d["height"];
                    lessonPageElements.set(el.id, textArea);
                    add(textArea);
                case 'textinput':
                    Logger.log("Making Text Input with ID " + el.id, "page/building");
                    var d = el.data;
                    var textInput = new TextInput(el.value, d["prompt"]);
                    textInput.x = d["x"];
                    textInput.y = d["y"];
                    textInput.textFormat = new TextFormat(d["font"], d["fontSize"], d["color"]);
                    textInput.width = d["width"];
                    textInput.height = d["height"];
                    lessonPageElements.set(el.id, textInput);
                    add(textInput);
                case 'image':
                    Logger.log("Making Image with ID " + el.id, "page/building");
                    var d = el.data;
                    if (d["dontUseLessonPath"] != "true")
                        d["path"] = 'assets/lessons/${lessonFolder}images/' + d["path"];
                    else
                        d["path"] = 'assets/images/' + d["path"];
                    if (!FileSystem.exists(d["path"]))
                        Logger.error("Could not find image at path " + d["path"] + " for image with ID " + el.id, "page/building/errors");
                    var bitmap = new Bitmap(openfl.utils.Assets.getBitmapData(d["path"]));
                    bitmap.x = d["x"];
                    bitmap.y = d["y"];
                    if (el.instance.get("width") != null)
                        bitmap.scaleX = (d["width"] / bitmap.width);
                    if (el.instance.get("height") != null)
                        bitmap.scaleY = (d["height"] / bitmap.height);
                    trace(bitmap.bitmapData.image.data.length);
                    lessonPageElements.set(el.id, bitmap);
                    add(bitmap);
                case 'checkbox':
                    Logger.log("Making Check with ID " + el.id, "page/building");
                    var d = el.data;
                    var check = new Check(el.value, d["checked"] == "true");
                    check.x = d["x"];
                    check.y = d["y"];
                    lessonPageElements.set(el.id, check);
                    add(check);
                case 'dropdown':
                    Logger.log("Making Dropdown with ID " + el.id, "page/building");
                    var d = el.data;
                    var dropdown = new PopUpListView(new ArrayCollection([for (x in el.instance.elements()) x.nodeName == 'DataItem' ? {text: x.firstChild().nodeValue} : continue]));
                    dropdown.x = d["x"];
                    dropdown.y = d["y"];
                    dropdown.itemToText = (item:Dynamic) -> {return item.text;}
                    lessonPageElements.set(el.id, dropdown);
                    add(dropdown);
                default:
                    Logger.error(el.elementType + " is not a valid component!", "page/building");
                    Logger.suggest("Make sure there are no typos or misspellings!", "page/building");
            }
        }
    }

    public inline function addScript(path:String) {
        return scripts.push(new LuaScript(path, this, lessonPageElements));
    }
}
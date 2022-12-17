package components;

import sys.FileSystem;
import vlc.VLCBitmap;

class Video extends VLCBitmap {
    public var playing:Bool;
    public var finished:Bool;
    public var looping:Bool = false;
    public var haccel:Bool = true;

    public function new(x:Float = 0, y:Float = 0, ?path:String) {
        super();
        onPlay = () -> {playing = true; finished = false;}
        onComplete = () -> {playing = false; finished = true;}
        onStop = () -> {playing = false; finished = true;}
        onPause = () -> {playing = false;}
        onResume = () -> {playing = true;}
        onError = (e) -> {
            Logger.error("An error occured while playing video " + path + "(error: " + e + ")", "vlc");
        }


        if (FileSystem.exists(path))
            play(path, looping, haccel);
        else Logger.error("Could not find video file " + path, "vlc");

        onPositionChanged = (x) -> {
            if (bitmapData != null)
            bitmapData.draw(bitmapData);
        }
    }
}
package;

import haxe.zip.Entry;
import haxe.zip.Reader;
import haxe.io.BytesInput;
import sys.io.File;
import sys.FileSystem;

class ZipTools {
    public static function getZipEntries(path:String)
    {
        if (!FileSystem.exists(path))
        {
            trace("[ziptools] can't find " + path + "!");
            return null;
         }
        var bytes = File.getBytes(path);
        var input = new BytesInput(bytes);
        var reader = new Reader(input);
    
        var entries:List<Entry> = reader.read();
        return [for (e in entries) e];
    }
}
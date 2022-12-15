package parsers;

import feathers.style.Theme;
import Xml.XmlType;
import cpp.UInt8;

typedef PageElement = {
    var elementType:String;
    var id:String;
    var value:String;
    var data:Map<String, Dynamic>;
    var instance:Xml;
}

class PageParser {
    public static inline function parse(xml:Xml) {
        var autoID:Int = 0;
        return recurseAdd(xml.firstElement(), autoID);
    }

    private static function recurseAdd(el:Xml, autoID:Int) {
        var retarr:Array<PageElement> = [];

        var child;
        for (v in el.elements()) {
            autoID++;
            var id = null;
            var data:Map<String, Dynamic> = [];
            if (v.get("id") != null) {
                id = (v.get("id"));
            }

            for (a in v.attributes()) {
                data.set(a, v.get(a));
            }

            if (id != null) {
                retarr.push({
                    elementType: v.nodeName,
                    id: id,
                    value: v.firstChild() != null ? v.firstChild().nodeValue : null,
                    data: data,
                    instance: v
                });
            } else {
                retarr.push({
                    elementType: v.nodeName,
                    id: Std.string(autoID),
                    value: v.firstChild() != null ? v.firstChild().nodeValue : null,
                    data: data,
                    instance: v
                });
            }

            if (v.firstElement() != null) {
                retarr = retarr.concat(recurseAdd(v, autoID));
             }
        }

        return retarr;
    }
}
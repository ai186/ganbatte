package;

import cpp.Float32;

class MathTools {
    public static function lerp(start:Float, end:Float, t:Float) {
        return start * (1 - t) + end * t;
    }

    public static function midpoint(start:Float, end:Float32) {
        return (start+end) / 2;
    }
}

import flash.display.DisplayObject;

interface Game
{
	public dynamic function onGameOver(winner:Bool):Void;
	public function destroy():Void;
	public function getDisplayObject():DisplayObject;
}


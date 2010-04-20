
import flash.display.DisplayObject;

interface Game
{
	public dynamic function onGameOver():Void;
	public function destroy():Void;
	public function getDisplayObject():DisplayObject;
}



import flash.display.Stage;
import flash.display.StageScaleMode;

class Main
{

	public static var stage:Stage;
	var frame:Frame;
	
    static public function main()
    {

		haxe.Log.trace = function(v,?pos) { untyped __global__["trace"](v); } 

		Main.stage=flash.Lib.current.stage;

		Main.stage.scaleMode=StageScaleMode.NO_SCALE;

		//new BoardView(null,null,0);
		
		stage.addChild(new Lobby(BoardView));
		
    }
    
}

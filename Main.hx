
import flash.display.Stage;
import flash.display.StageScaleMode;

class Main
{

	public static var stage:Stage;
	var frame:Frame;
	public static var kongregate;
	
    static public function main()
    {

		haxe.Log.trace = function(v,?pos) { untyped __global__["trace"](v); } 

		Main.stage=flash.Lib.current.stage;

		Main.stage.scaleMode=StageScaleMode.NO_SCALE;

		//new BoardView(null,null,0);
		
		kongregate=new Kongregate();
		
		var lobby=new Lobby(BoardView);
		
		lobby.updateBackground();
		
		stage.addChild(lobby);
		
		
    }
    
}

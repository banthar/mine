
import flash.display.Sprite;
import flash.display.DisplayObject;

import flash.net.NetStream;

class BoardView extends Sprite, implements Game
{
	
	public var board:Board;
	
	public var fields:Array2D<FieldView>;
	
	var input:NetStream;
	var output:NetStream;
	
	var myPlayer:UInt;
	public var miner:Bool;
	
	var seed:UInt;
	
	var start_time:Float;
	
	public dynamic function onGameOver(winner:Bool):Void;
	
	public function new(input:NetStream,output:NetStream, myPlayer:UInt)
	{

		super();
		
		this.input=input;
		this.output=output;
		this.myPlayer=myPlayer;

		input.client.startGame=startGame;

		seed=Std.random(2000000000);

		output.send("startGame",seed);

	}
	
	private function startGame(seed:UInt)
	{

		start_time=haxe.Timer.stamp();

		miner=seed>this.seed;
		
		if(miner)
		{
			input.client.flag=flag;
		}
		else
		{
			input.client.mine=mine;
		}
		
		this.seed^=seed;
		
		input.client.startGame=null;
		
		board=new Board(30,20,20*4,this.seed);
		redraw();
		
		height=Main.stage.stageHeight;
		scaleX=scaleY;

		x=(Main.stage.stageWidth-width)/2.0;
		y=(Main.stage.stageHeight-height)/2.0;
		
	}
	
	public function onClick(x:Int,y:Int)
	{
		mine(x,y);
		
		output.send("mine",x,y);
		
	}
	
	public function onFlagClick(x:Int,y:Int)
	{
		flag(x,y);
		
		output.send("flag",x,y);
		
	}
	
	public function flag(x:Int,y:Int)
	{
		fields.get(x,y).flag();
	}
	
	public function mine(x:Int,y:Int)
	{
			
		var stack=new Array<FieldView>();
		
		stack.push(fields.get(x,y));
		
		while(stack.length>0)
		{
			
			var p=stack.pop();

			if(p!=null && !p.field.flag && !p.field.clicked)
			{
				
				p.click();
				
				if(p.field.neighbours==0 && p.field.bomb==false)
				{
					
					for(ix in p.xpos-1...p.xpos+2)
					for(iy in p.ypos-1...p.ypos+2)
						if((ix!=p.xpos || iy!=p.ypos) && fields.get(ix,iy)!=null)
							stack.push(fields.get(ix,iy));
					
				}
					
			}

		}
	
	}
	
	public function redraw()
	{
		
		fields=new Array2D(board.width,board.height);
		
		for(x in 0...board.width)
		for(y in 0...board.height)
		{
			
			var field=new FieldView(this,x,y);

			fields.set(x,y,field);

			field.x=x*32;
			field.y=y*32;

			addChild(field);
			
		}
	
		
	}

	public function getDisplayObject():DisplayObject
	{
		return this;
	}

	public function win()
	{
		mouseChildren=false;
		onGameOver(true);
		
		Main.kongregate.submitStat("time",Std.int(haxe.Timer.stamp()-start_time));
		Main.kongregate.submitStat("cleared_boards",1);
		
	}

	public function die()
	{
		mouseChildren=false;
		onGameOver(false);
	}

	public function destroy()
	{
		input.client={};
		
		if(parent!=null)
			parent.removeChild(this);
			
	}
	
}


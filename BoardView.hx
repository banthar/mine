
import flash.display.Sprite;
import flash.net.NetStream;

class BoardView extends Sprite, implements Game
{
	
	public var board:Board;
	
	public var fields:Array2D<FieldView>;
	
	var input:NetStream;
	var output:NetStream;
	
	var myPlayer:UInt;
	
	var seed:UInt;
	
	public function new(input:NetStream,output:NetStream, myPlayer:UInt)
	{

		super();
		
		this.input=input;
		this.output=output;
		this.myPlayer=myPlayer;

		input.client.startGame=startGame;
		input.client.flag=flag;
		input.client.mine=mine;

		seed=Std.random(2000000000);

		output.send("startGame",seed);

		Main.stage.addChild(this);



	}
	
	private function startGame(seed:UInt)
	{
		
		trace([seed,this.seed]);
		
		this.seed^=seed;
		
		input.client.startGame=null;
		
		board=new Board(30,20,20*2,this.seed);
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

	public function destroy()
	{
		parent.removeChild(this);
	}
	
}


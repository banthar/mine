
import flash.display.Sprite;

import flash.Vector;

class Board
{
	
	public var width:Int;
	public var height:Int;
	public var mines:Int;
	public var mines_left:Int;
	
	var board:Vector<Field>;
	
	public function new(w:Int, h:Int, mines:Int, seed:UInt)
	{
		
		var random=new Random(seed);
		
		this.width=w;
		this.height=h;
		this.mines=mines;
		this.mines_left=mines;
		
		board=new Vector<Field>(w*h);
		
		for(i in 0...board.length)
			board[i]=new Field();
		
		var n=mines;
		
		while(n>0)
		{
			var i=random.nextInt(board.length);
			
			if(board[i].bomb == false)
			{
				board[i].bomb=true;
				n--;
			}
			
		}
		
		for(x in 0...width)
		for(y in 0...height)
		{
			getField(x,y).neighbours=neighbours(x,y);
		}
		
	}
	
	public function getField(x:Int,y:Int):Field
	{
		
		if(x<0 || y<0 || x>=width || y>=height)
			return null
		else
			return board[y*width+x];
			
	}
	
	public function neighbours(sx:Int,sy:Int):Int
	{
		
		var n=0;
		
		for(x in sx-1...sx+2)
		for(y in sy-1...sy+2)
		{
			if(x!=sx || y!=sy)
			{

				var f=getField(x,y);

				if(f!=null && f.bomb)
					n++;
					
			}
		}
		
		return n;
		
	}
	
}


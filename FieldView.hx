
import flash.display.Sprite;
import flash.display.DisplayObject;

import flash.events.MouseEvent;
import flash.events.Event;

class FieldView extends Sprite
{

	public var field:Field;
	var board_view:BoardView;
	public var xpos:Int;
	public var ypos:Int;

	private var flag_sprite:DisplayObject;
	private var flag_over_sprite:DisplayObject;

	public function new(board_view:BoardView,x:Int,y:Int)
	{
		super();
		
		this.board_view=board_view;
		this.xpos=x;
		this.ypos=y;
		
		field=board_view.board.getField(x,y);

		addChild(Utils.load("full"));

		doubleClickEnabled=true;
		mouseChildren=false;
		buttonMode=true;

		if(board_view.miner)
		{
			addEventListener(MouseEvent.CLICK,onClick);
			addEventListener(MouseEvent.DOUBLE_CLICK,onDoubleClick);
		}
		else
		{
			addEventListener(MouseEvent.CLICK,onFlag);

			addEventListener(MouseEvent.MOUSE_OVER,onFlagOver);
			addEventListener(MouseEvent.MOUSE_OUT,onFlagOut);

		}



	}

	public function clear()
	{
		while(numChildren > 0)
		{
			removeChildAt(0);
		}
	}

	public function onFlagOver(e:MouseEvent)
	{
		
		onFlagOut(null);

		if(field.flag || field.clicked)
			return;
		
		
		flag_over_sprite=Utils.load("flag");
		
		flag_over_sprite.alpha=0.25;
		
		addChild(flag_over_sprite);
		
	}

	public function onFlagOut(e:MouseEvent)
	{
		if(flag_over_sprite!=null)
		{
			removeChild(flag_over_sprite);
			flag_over_sprite=null;
		}
	}

	public function onFlag(e:MouseEvent)
	{
		board_view.onFlagClick(xpos,ypos);
	}

	public function onClick(_)
	{
		
		board_view.onClick(xpos,ypos);
		
	}


	public function onDoubleClick(_)
	{
		
		var n=field.neighbours;
		
		for(ix in xpos-1...xpos+2)
		for(iy in ypos-1...ypos+2)
			if( (ix!=xpos || iy!=ypos) && board_view.fields.get(ix,iy)!=null)
			{
				var f=board_view.fields.get(ix,iy).field;
				
				if(f.flag || (f.clicked && f.bomb))
					n--;
				
			}
			
		if(n == 0)
		{
			for(ix in xpos-1...xpos+2)
			for(iy in ypos-1...ypos+2)
				if( (ix!=xpos || iy!=ypos) )
				{
					board_view.onClick(ix,iy);
				}
		}
			
	}

	public function flag(?flag:Bool)
	{
		
		if(flag==null)
			flag=!field.flag;
		
		if(flag && !field.flag && !field.clicked)
		{
			field.flag=true;
			flag_sprite=Utils.load("flag");
			addChild(flag_sprite);

			if(field.bomb)
			{
				board_view.board.mines_left--;
				
				if(board_view.board.mines_left<=0)
					board_view.win();
				
			}
			
		}
		else if(!flag && field.flag)
		{
			field.flag=false;
			removeChild(flag_sprite);
			
			if(field.bomb)
			{
				board_view.board.mines_left++;
			}
			
		}
		
	}

	public function click()
	{
		
		clear();
		
		field.clicked=true;
		
		addChild(Utils.load("empty"));
		
		if(field.bomb)
		{
			addChild(Utils.load("mine"));
			board_view.die();
		}
		else if(field.neighbours!=0)
		{
			addChild(Utils.load("num"+field.neighbours));
		}
		
		buttonMode=false;
		removeEventListener(MouseEvent.CLICK,onClick);
	}


}


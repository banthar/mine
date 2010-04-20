
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

		addEventListener(MouseEvent.CLICK,onClick);
		addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWhell);
		addEventListener(MouseEvent.DOUBLE_CLICK,onDoubleClick);



	}

	public function clear()
	{
		while(numChildren > 0)
		{
			removeChildAt(0);
		}
	}

	public function onMouseWhell(e:MouseEvent)
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
			
		}
		else if(!flag && field.flag)
		{
			field.flag=false;
			removeChild(flag_sprite);
		}
		
	}

	public function click()
	{
		
		clear();
		
		field.clicked=true;
		
		addChild(Utils.load("empty"));
		
		if(field.bomb)
		{
			Main.notify.add("Boom !!!");
			addChild(Utils.load("mine"));
		}
		else if(field.neighbours!=0)
		{
			addChild(Utils.load("num"+field.neighbours));
		}
		
		buttonMode=false;
		removeEventListener(MouseEvent.CLICK,onClick);
	}


}


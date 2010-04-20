
import flash.display.Sprite;
import flash.display.DisplayObject;

import flash.text.TextFormat;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

class Notify extends Sprite
{
	
	public var defaultTextFormat:TextFormat;
	
	public function new()
	{
		super();
		
		defaultTextFormat=new TextFormat("Arial",16);
		
	}
	
	override public function addChild(object:DisplayObject)
	{
		
		var log=this;
		
		haxe.Timer.delay(function(){if(object.parent!=null)log.removeChild(object);},5000);
		
		var tmp=super.addChild(object);
		
		sort();
		
		return tmp;
		
	}

	override public function removeChild(object:DisplayObject)
	{
		var tmp=super.removeChild(object);
		sort();
		return tmp;
	}
	
	private function sort()
	{
		
		var pos=0.0;
		
		for(i in 0...numChildren)
		{
			
			var child=getChildAt(numChildren-1-i);
			
			pos-=child.height+4;
			child.y=pos;
			child.x=4;
			
		}

	}
	
	public function add(text:String)
	{
		
		var margin=16.0;
		
		var field=new TextField();
		field.autoSize=TextFieldAutoSize.LEFT;
		field.defaultTextFormat=defaultTextFormat;
		field.textColor=0xffffff;
		field.text=text;
		
		var box=new Sprite();
		box.addChild(field);
		
		box.graphics.beginFill(0x000000,0.4);
		box.graphics.drawRoundRect(0,0,box.width+margin*2,box.height+margin*2/2,margin,margin);
		box.mouseChildren=false;
		field.x=margin;
		field.y=margin/2;
		
		addChild(box);
		
	}
	
}


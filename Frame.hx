
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;

import flash.filters.BlurFilter;

class Frame extends Sprite
{

	var previousFrame:Frame;
	
	public function new()
	{
		
		super();
		
	}
	
	public function show(frame:Frame)
	{
		
		var parent=parent;
		
		parent.removeChild(this);
		parent.addChild(frame);

	}
	
	public function showDialog(frame:Frame)
	{

		frame.previousFrame=this;
		show(frame);
		
	}

	public function close()
	{
		
		var parent=this.parent;
		
		parent.removeChild(this);
		
		if(previousFrame!=null)
			parent.addChild(previousFrame);
		
		destroy();
		
	}

	override public function addEventListener(type, listener, useCapture=false, priority=0, useWeakReference=true)
	{
		return super.addEventListener(type,listener,useCapture,priority,useWeakReference);
	}

	private function organise()
	{
		var h=0.0;
		
		for(i in 0...numChildren)
		{
			
			if(getChildAt(i).z<0.0)
				continue;
		
			h+=4;
			h+=getChildAt(i).height;
		}
		
		var ypos=(Main.stage.stageHeight-h)/2.0;
		
		for(i in 0...numChildren)
		{
			var c=getChildAt(i);
			
			if(c.z<0.0)
				continue;
			
			c.x=(Main.stage.stageWidth-c.width)/2;
			c.y=ypos;
			ypos+=c.height+4;
			
		}
		
	}

	private function addLabel(text:String,size:Float)
	{
		
		var text_field=new TextField();
		addChild(text_field);
		text_field.defaultTextFormat=new TextFormat("Arial",size);
		text_field.autoSize=flash.text.TextFieldAutoSize.CENTER;
		text_field.text=text;
		text_field.name=text;
		
		return text_field;
		
	}

	private function addButton(text:String,size:Float,?c:Dynamic->Void)
	{
	
		var margin=8;
		
		var text_field=new TextField();
		text_field.defaultTextFormat=new TextFormat("Arial",size);
		text_field.autoSize=flash.text.TextFieldAutoSize.CENTER;
		text_field.text=text;
		text_field.name=text;
		
		//text_field.border=true;

		var box=new Sprite();
		box.addChild(text_field);
		
		box.graphics.beginFill(0x000000,0.4);
		box.graphics.drawRoundRect(0,0,box.width+margin*4,box.height+margin,margin*3,margin*3);
		box.mouseChildren=false;
		box.name=text;
		box.buttonMode=true;
		
		box.addEventListener(MouseEvent.MOUSE_OVER,function(e:MouseEvent){box.alpha=box.mouseEnabled?0.7:0.5;});
		box.addEventListener(MouseEvent.MOUSE_OUT ,function(e:MouseEvent){box.alpha=box.mouseEnabled?1.0:0.5;});
		
		text_field.x=margin*2;
		text_field.y=margin/2;
		
		addChild(box);
		
		box.addEventListener(MouseEvent.CLICK,c);
		
		return box;
		
	}

	public function showMessageBox(text:String)
	{

		var message_box=new Frame();

		message_box.addLabel(text,24);
		message_box.addButton("Ok",24,function(_){message_box.close();});
		
		message_box.organise();
		
		showDialog(message_box);

	}

	public function clear()
	{
		
		graphics.clear();
		
		while(numChildren>0)
		{
			removeChildAt(numChildren-1);
		}
		
	}

	public function destroy()
	{

	}

}


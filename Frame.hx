
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.geom.Rectangle;

class Frame extends Sprite
{

	var previousFrame:Frame;
	
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

	public function destroy()
	{

	}

}


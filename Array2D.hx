
import flash.Vector;

class Array2D<T>
{

	public var width:Int;
	public var height:Int;
	var data:Vector<T>;

	public function new(width:Int, height:Int)
	{
		this.width=width;
		this.height=height;
		
		data=new Vector<T>(width*height,true);
	}

	public function get(x:Int, y:Int):T
	{
		if(x<0 || y<0 || x>=width || y>=height)
			return null
		else
			return data[y*width+x];
	}

	public function set(x:Int, y:Int, v:T):T
	{
		if(x<0 || y<0 || x>=width || y>=width)
			throw "index out of bounds";
		else
			return data[y*width+x]=v;
	}

}


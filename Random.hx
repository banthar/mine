
class Random
{
	
	var seed:UInt;
	
	public function new(?seed:UInt)
	{
		if(seed==null)
			seed=Std.random(2000000000);
			
		this.seed=seed;
			
	}
	
	private function next():UInt
	{

		seed=seed*1719898171+13;
		
		var v=seed>>>16;
		
		seed=seed*1719898171+13;

		return v^seed<<16;
		
	}
	
	public function nextInt(max:Int)
	{

		if(max<=0)
			throw "max <= 0";

		return next()%max;

	}
	
}


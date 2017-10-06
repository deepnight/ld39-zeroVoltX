import mt.MLib;
import mt.deepnight.Lib;

typedef WaveInstruction = {
	var nextCursor : Int;
	var cmd:String;
	var a : Float;
	var b : Float;
}

class Plan {
	static var DELIMITERS = [
		" "=>true,
		"["=>true,
		"]"=>true,
		"{"=>true,
		"}"=>true,
		"("=>true,
		")"=>true,
	];

	var plan : String;
	var lastStart : CPoint;
	var loopCpt : Int;
	public var inst : Null<WaveInstruction>;
	public var speed : Float;
	var flipX : Bool;

	public function new(p:String, flipX:Bool) {
		plan = p;
		this.flipX = flipX;
		loopCpt = 0;
		speed = 1;

		plan = StringTools.trim(plan);
		while( plan.indexOf("  ")>=0 )
			plan = StringTools.replace(plan,"  "," ");

		nextInstruction();
	}

	inline function isDelimiter(c:String) {
		return DELIMITERS.exists(c);
	}

	function getInstructionAt(cursor:Int) : Null<WaveInstruction> {
		while( cursor<plan.length && isDelimiter(plan.charAt(cursor)) )
			cursor++;

		if( cursor>=plan.length )
			return null;

		var len = 1;
		while( cursor+len<plan.length && !isDelimiter(plan.charAt(cursor+len)) )
			len++;
		var s = plan.substr(cursor,len);
		//trace(cursor+" "+len+" => "+s);
		if( reg.match(s) ) {
			var a = 0.;
			var b = 0.;
			var rawVal : String = reg.matched(2);
			if( rawVal!=null && rawVal!="" ) {
				if( rawVal.indexOf("/")>0 ) {
					a = Std.parseFloat( rawVal.split("/")[0] );
					b = Std.parseFloat( rawVal.split("/")[1] );
				}
				else
					a = Std.parseFloat( rawVal );
			}
			var cmd = reg.matched(1);
			cursor+=len+1;

			if( flipX )
				switch( cmd ) {
					case "RD" : cmd="LD";
					case "LD" : cmd="RD";
					case "RU" : cmd="LU";
					case "LU" : cmd="RU";
					case "L" : cmd="R";
					case "R" : cmd="L";
					case "sinL" : cmd="sinR";
					case "sinR" : cmd="sinL";
				}

			//trace(cmd+" => "+a+" / "+b);
			return { cmd:cmd, a:a, b:b, nextCursor:cursor };
		}
		else
			return null;
	}


	//public function getMinY() : Int {
		//var minY = 0.;
		////var maxY = 0;
		//var y = 0.;
		//var i = getInstructionAt(0);
		//while( i!=null ) {
			//switch( i.cmd ) {
				//case "U" : y-=i.a;
				//case "D" : y+=i.a;
			//}
			//minY = MLib.fmin(minY, y);
			//i = getInstructionAt(i.nextCursor);
		//}
//
		//return Std.int(minY);
	//}



	var reg = ~/([A-Za-z_]+)([\-0-9\/.]*)/g;
	public function nextInstruction() {
		if( inst==null )
			inst = getInstructionAt(0);
		else {
			var i = getInstructionAt(inst.nextCursor);
			if( i!=null )
				inst = i;
		}

		if( inst!=null ) {
			switch( inst.cmd ) {
				case "x" :
					// Loop
					if( loopCpt<=0 )
						loopCpt = Std.int(inst.a);
					loopCpt--;
					if( loopCpt>0 )
						inst.nextCursor = plan.lastIndexOf("(", inst.nextCursor);
					nextInstruction();
					return;

				case "s","spd" :
					speed = inst.a;
					nextInstruction();
					return;
			}
		}
	}

}
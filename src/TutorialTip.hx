import mt.MLib;
import mt.deepnight.Tweenie;
import hxd.Key;

class TutorialTip extends mt.Process {
	static var CUR : TutorialTip;
	//var x : Float;
	//var y : Float;
	var win : h2d.Sprite;
	var pointer : h2d.Graphics;
	var waitKeys : Array<Int>;
	var locking : Bool;

	public function new(?x:Float,?y:Float, txt:mt.data.GetText.LocaleString, ?wk:Array<Int>) {
		super(Main.ME);

		CUR = this;

		var sx = x==null ? 0 : Std.int( x+Game.ME.scroller.x );
		var sy = y==null ? 0 : Std.int( y+Game.ME.scroller.y );

		txt = cast mt.deepnight.Lib.replaceTag(txt,"*","<font color='#FFBF00'>","</font>");
		txt = cast StringTools.replace(txt,"\n","<br>");
		waitKeys = wk;
		createRootInLayers(Game.ME.root, Const.DP_TOP);

		pointer = new h2d.Graphics(root);
		pointer.lineStyle(1, 0xD7CA97);
		pointer.drawCircle(0,0,16);
		pointer.visible = x!=null;
		if( pointer.visible )
			pointer.setPos(sx,sy);

		win = new h2d.Sprite(root);
		var px = 6;
		var py = 3;

		var bg = new h2d.ScaleGrid(Assets.tiles.getTile("win"), 16,16, win);

		var f = new h2d.Flow(win);
		f.isVertical = true;
		f.verticalSpacing = py*2;
		f.minHeight = 16;
		f.verticalAlign = Middle;
		f.paddingVertical = py;

		var tf = new h2d.HtmlText(Assets.font, f);
		tf.text = txt;
		tf.maxWidth = 115;

		if( Game.ME.paused && waitKeys==null ) {
			var tf = new h2d.HtmlText(Assets.font, f);
			tf.textColor = 0x93A3B7;
			tf.text = "Press SPACE to continue";
		}

		bg.x = -px;
		bg.y = -py;
		bg.width = f.outerWidth + px*2;
		bg.height = f.outerHeight + py*2;

		if( x!=null ) {
			win.x = sx+22;
			if( win.x+bg.width>=Game.ME.lvl.wid*Const.GRID )
				win.x = sx-22-bg.width;
			win.y = sy-bg.height*0.4;
		}
		else {
			win.x = Game.ME.lvl.wid*Const.GRID - bg.width - 10;
			win.y = 10;
		}
		tw.createS(win.x, win.x+200>win.x, 0.2);
		tw.createS(pointer.alpha, 0>1, 0.2);
	}

	public static function clear() {
		if( CUR!=null ) {
			CUR.close();
			CUR = null;
		}
	}

	override function onDispose() {
		super.onDispose();
		if( CUR==this ) CUR = null;
	}

	function close() {
		if( CUR==this ) CUR = null;
		if( !cd.hasSetS("lock",Const.INFINITE) ) {
			tw.createS(pointer.alpha, 0, TEaseIn, 0.3);
			tw.createS(win.y, win.y+Game.ME.vp.hei*Const.GRID, TEaseIn, 0.3).end( destroy );
			Game.ME.resume();
			Tutorial.ME.completeCurrent();
		}
	}

	override function update() {
		super.update();

		if( cd.has("lock") )
			return;

		pointer.scaleX = 0.6 + MLib.fabs(0.4*Math.cos(ftime*0.1));
		pointer.scaleY = pointer.scaleX;

		if( waitKeys==null && Key.isDown(Key.SPACE) )
			close();

		if( waitKeys!=null )
			for(k in waitKeys)
				if( Key.isDown(k) )
					close();
	}
}
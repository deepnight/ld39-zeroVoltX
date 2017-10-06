import mt.MLib;
import mt.deepnight.Tweenie;
import hxd.Key;

class Notif extends mt.Process {
	var win : h2d.Sprite;

	public function new(?short=false, txt:mt.data.GetText.LocaleString) {
		super(Main.ME);

		txt = cast mt.deepnight.Lib.replaceTag(txt,"*","<font color='#FFBF00'>","</font>");
		txt = cast StringTools.replace(txt,"\n","<br>");
		createRootInLayers(Game.ME.root, Const.DP_TOP);

		win = new h2d.Sprite(root);
		var px = 6;
		var py = 3;

		var bg = new h2d.ScaleGrid(Assets.tiles.getTile("win"), 16,16, win);

		var tf = new h2d.HtmlText(Assets.font, win);
		tf.text = txt;
		tf.maxWidth = 115;

		bg.x = -px;
		bg.y = -py;
		bg.width = tf.textWidth + px*2;
		bg.height = tf.textHeight + py*2;

		win.x = Std.int( Boot.ME.cached.width*0.5 - bg.width*0.5 );
		win.y = Std.int( Boot.ME.cached.height - bg.height - 10 );
		tw.createS(win.x, win.x+200>win.x, 0.2);
		cd.setS("alive", short?2:4.3);
	}

	override function update() {
		super.update();

		if( !cd.has("alive") && !cd.hasSetS("closing",Const.INFINITE) ) {
			tw.createS(win.y, win.y+Game.ME.vp.hei*Const.GRID, TEaseIn, 0.3).end( destroy );
		}
	}
}
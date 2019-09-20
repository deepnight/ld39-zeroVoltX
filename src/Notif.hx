class Notif extends dn.Process {
	var win : h2d.Object;

	public function new(?short=false, txt:dn.data.GetText.LocaleString) {
		super(Main.ME);

		txt = cast dn.Lib.replaceTag(txt,"*","<font color='#FFBF00'>","</font>");
		txt = cast StringTools.replace(txt,"\n","<br>");
		createRootInLayers(Game.ME.root, Const.DP_TOP);

		win = new h2d.Object(root);
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

		win.x = Std.int( w()/Const.SCALE*0.5 - bg.width*0.5 );
		win.y = Std.int( h()/Const.SCALE - bg.height - 10 );
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
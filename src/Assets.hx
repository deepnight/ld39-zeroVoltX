import mt.deepnight.Sfx;
import mt.heaps.slib.*;

class Assets {
	public static var SBANK = Sfx.importDirectory("sfx");
	public static var font : h2d.Font;
	public static var tiles : SpriteLib;
	public static var music : mt.deepnight.Sfx;

	public static function init() {
		font = hxd.Res.minecraftiaOutline.toFont();
		tiles = mt.heaps.slib.assets.Atlas.load("tiles.atlas");

		Sfx.setGroupVolume(0,1);
		Sfx.setGroupVolume(1,0.2);
		music = Assets.SBANK.music();
		music.playOnGroup(1,true);
		#if js
		Sfx.muteGroup(0);
		Sfx.muteGroup(1);
		#end
	}
}
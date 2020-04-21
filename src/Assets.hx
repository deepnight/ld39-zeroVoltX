import dn.heaps.Sfx;

class Assets {
	public static var SBANK = dn.heaps.assets.SfxDirectory.load("sfx");
	public static var font : h2d.Font;
	public static var tiles : SpriteLib;
	public static var music : dn.heaps.Sfx;

	public static function init() {
		font = hxd.Res.minecraftiaOutline.toFont();
		tiles = dn.heaps.assets.Atlas.load("tiles.atlas");

		Sfx.setGroupVolume(0,1);
		Sfx.setGroupVolume(1,0.55);
		music = Assets.SBANK.music();
	}
}
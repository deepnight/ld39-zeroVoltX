package mt.heaps.slib.assets;

import mt.heaps.slib.SpriteLib;

class Atlas {
	static inline function trim(s:String, c:String) {
		while( s.charAt(0)==c )
			s = s.substr(1);
		while( s.charAt(s.length-1)==c )
			s = s.substr(0, s.length-1);
		return s;
	}

	public static function load(atlasPath:String, ?onReload:Void->Void, ?notZeroBaseds:Array<String>, ?properties : Array<String>) : SpriteLib {
		var notZeroMap = new Map();
		if( notZeroBaseds!=null )
			for(id in notZeroBaseds) notZeroMap.set(id, true);

		var propertiesMap = new Map<String, Int>();
		if (properties != null)
			for (i in 0...properties.length) propertiesMap.set(properties[i], properties.length - 1 - i);

		var res = hxd.Res.load(atlasPath);
		var basePath = atlasPath.indexOf("/")<0 ? "" : atlasPath.substr(0, atlasPath.lastIndexOf("/")+1);

		// Load source image separately
		/*
		var r = ~/^([a-z0-9_\-]+)\.((png)|(jpg)|(jpeg)|(gif))/igm;
		var raw = res.toText();
		var bd : hxd.BitmapData = null;
		if( r.match(raw) ) {
			bd = hxd.Res.load(basePath + r.matched(0)).toBitmap();
		}
		*/

		// Create SLib
		var atlas = res.to(hxd.res.Atlas);
		var lib = convertToSlib(atlas, notZeroMap, propertiesMap);
		res.watch( function() {
			#if debug
			trace("Reloaded atlas.");
			#end
			convertToSlib(atlas, notZeroMap, propertiesMap);
			if( onReload!=null )
				onReload();
		});

		return lib;
	}

	static function convertToSlib(atlas:hxd.res.Atlas, notZeroBaseds:Map<String,Bool>, properties : Map<String, Int>) {
		var contents = atlas.getContents();

		var bestVariants = new Map<String, { rawName : String, score : Int }>();

		var propertiesReg = ~/(.*)((\.[a-z_\-]+)+)$/gi;
		for (rawName in contents.keys()) {
			var groupName  = rawName;
			var groupProps = new Array<String>();
			if (propertiesReg.match(rawName)) {
				var str    = propertiesReg.matched(2).substr(1);
				groupProps = str.split(".");
				groupName  = propertiesReg.matched(1);
			}

			var score = 0;
			if (groupProps.length > 0) {
				for (i in 0...groupProps.length) {
					var prio = properties.get(groupProps[i]);
					if (prio != null) score |= 1 << prio;
				}
				if (score == 0) continue;
			}

			var e = bestVariants.get(groupName);
			if (e == null) {
				bestVariants.set(groupName, { rawName : rawName, score : score });
			} else if (score > e.score) {
				e.rawName = rawName;
				e.score = score;
			}
		}

		var pageMap = new Map<h3d.mat.Texture, Int>();
		var pages   = new Array<h2d.Tile>();

		for (group in contents)
		for (frame in group) {
			var tex  = frame.t.getTexture();
			var page = pageMap.get(tex);
			if (page == null) {
				pageMap.set(tex, pages.length);
				pages.push(h2d.Tile.fromTexture(tex));
			}
		}

		// load normals
		var nrmPages = [];
		for (i in 0...pages.length) {
			var name = pages[i].getTexture().name;
			var nrmName = name.substr(0, name.length - 4) + "_n.png";
			nrmPages[i] = hxd.res.Loader.currentInstance.exists(nrmName)
				? h2d.Tile.fromTexture(hxd.Res.load(nrmName).toTexture())
				: null;
		}

		var lib = new mt.heaps.slib.SpriteLib(pages, nrmPages);

		var ids = new Map();
		var frameReg = ~/[a-z_\-]+([0-9]+)$/gi;
		for( groupName in bestVariants.keys() ) {
			var rawName = bestVariants.get(groupName).rawName;

			var content = contents.get(rawName);
			if (content.length == 1) {
				var e = content[0];
				var page = pageMap.get(e.t.getTexture());

				// Original ID
				lib.sliceCustom(
					groupName, page, 0,
					e.t.x, e.t.y, e.t.width, e.t.height,
					{ x:-e.t.dx, y:-e.t.dy, realWid:e.width, realHei:e.height }
				);
				ids.set(groupName,groupName);

				// Original ID but parse terminal number
				var k = groupName;
				var f = 0;
				if( frameReg.match(k) ) {
					var s = frameReg.matched(1);
					f = Std.parseInt(s);
					k = trim( k.substr(0, k.lastIndexOf(s)), "_" );
					if( notZeroBaseds.exists(k) )
						f--;
				}
				lib.sliceCustom(
					k, page, f,
					e.t.x, e.t.y, e.t.width, e.t.height,
					{ x:-e.t.dx, y:-e.t.dy, realWid:e.width, realHei:e.height }
				);
				ids.set(k,k);

				// Remove folders and parse terminal number
				var k = groupName;
				if( k.indexOf("/")>=0 )
					k = k.substr( k.lastIndexOf("/")+1 );
				if( frameReg.match(k) ) {
					var s = frameReg.matched(1);
					k = trim( k.substr(0, k.lastIndexOf(s)), "_" );
				}
				lib.sliceCustom(
					k, page, f,
					e.t.x, e.t.y, e.t.width, e.t.height,
					{ x:-e.t.dx, y:-e.t.dy, realWid:e.width, realHei:e.height }
				);
				ids.set(k,k);
			} else {
				var k = groupName;
				if( k.indexOf("/")>=0 ) k = k.substr( k.lastIndexOf("/")+1 );
				for (i in 0...content.length) {
					var e = content[i];
					var page = pageMap.get(e.t.getTexture());
					lib.sliceCustom(
						k, page, i,
						e.t.x, e.t.y, e.t.width, e.t.height,
						{ x:-e.t.dx, y:-e.t.dy, realWid:e.width, realHei:e.height }
					);
					ids.set(k,k);
				}
			}

		}

		for( id in ids.keys() ) {
			var frames = [];
			for(i in 0...lib.countFrames(id))
				frames.push(i);
			@:privateAccess lib.__defineAnim(id, frames);
		}

		return lib;
	}
}

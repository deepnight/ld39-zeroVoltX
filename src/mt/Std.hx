package mt;

/**
 * Cette librairie a pour but d'améliorer et uniformiser les api de List et Array pour éviter entre autre, les erreurs de nature FIFO/LIFO.
 *
 * @author Thomas
 * @usage Librairie à utiliser en mixin avec using mt.Std;
 * En cas d'ajout de fonctionnalités, merci de mettre à jour les tests unitaires.
 * Tests unitaires disponibles ici : https://www.dropbox.com/sh/6f288be3uzsliow/Q_w9_F8Tqg
 */

class ArrayStd
{
	inline public static function isEmpty<T>(ar:Array<T>):Bool 
	{
		return size(ar) == 0;
	}
	
	inline public static function size<T>( ar:Array<T> ):Int
	{
		return ar.length;
	}
	
	inline public static function first<T>( ar:Array<T> ) : T
	{
		return ar[0];
	}
	
	inline public static function last<T>( ar:Array<T> ) : T
	{
		return ar[ar.length-1];
	}
	
	inline public static function clear<T>( ar:Array<T> ) : Array<T>
	{
		ar.splice(0, size(ar));
		return ar;
	}
	
	inline public static function set<T>(ar:Array<T>, index:Int, v:T):Array<T>
	{
		ar[index] = v;
		return ar;
	}
	
	inline public static function get<T>( ar:Array<T>, index:Int ) : T
	{
		return ar[index];
	}
	
	/**
	 * Modifies the Array
	 */
	/*
	inline public static function removeAt<T>( ar:Array<T>, index:Int ) : T
	{
		return ar.splice(index, 1);
	}
	*/
	
	inline public static function exists<T>( ar:Array<T>, index:Int ):Bool {
		return index >= 0 && index < size(ar) && get(ar, index) != null;
	}
	
	inline public static function has<T>( ar:Array<T>, elt:T ):Bool {
		return indexOf( ar, elt ) >= 0;// >=0 is faster than > constant
	}
	
	inline public static function indexOf<T>( ar:Array<T>, elt:T ) : Int
	{
		var id = -1, i = -1;
		for( e in ar )
		{
			++i;
			if( e == elt )
			{
				id = i;
				break;
			}
		}
		return id;
	}
	
	inline public static function addFirst<T>( ar : Array<T>, e : T ) : Array<T>
	{
		ar.unshift(e); return ar;
	}
	
	inline public static function addLast<T>( ar : Array<T>, e : T ) : Array<T>
	{
		ar.push(e); return ar;
	}
	
	inline public static function removeFirst<T>( ar:Array<T> ) : T
	{
		return ar.shift();
	}
	
	inline public static function removeLast<T>( ar:Array<T> ) : T
	{
		return ar.pop();
	}
	
	inline public static function map<A, B>( ar : Array<A>, f:A->B ):Array<B>
	{
		var output = [];
		for ( e in ar )
		{
			output.push( f(e) );
		}
		return output;
	}
	
	inline public static function stripNull<T>( ar : Array<T> ):Array<T>
	{
		while( ar.remove(null) ) { }
		return ar;
	}
	
	/**
	 * Retourne un nouveau tableau !
	 */
	inline public static function flatten<T>( ar : Array<Iterable<T>> ) : Array<T>
	{
		var out = new Array<T>();
		for( i in 0...ar.length )
		{
			append(out, get(ar, i));
		}
		return out;
	}
	
	/**
	 * Attention : cette méthode modifie le tableau d'origine !
	 */
	inline public static function append<T>( ar : Array<T>,  it : Iterable<T> ) : Array<T>
	{
		for( x in it )
			addLast(ar, x);
		return ar;
	}
	
	/**
	 * Attention : cette méthode modifie le tableau d'origine !
	 */
	inline public static function prepend<T>( ar : Array<T>,  it : Iterable<T> ) : Array<T>
	{
		var a = Lambda.array(it);
		a.reverse();
		for( x in a )
			addFirst(ar, x);
		return ar;
	}
	
	/**
	 * Attention : cette methode modifie le tableau d'origine !
	 */
	public static function shuffle<T>( ar : Array<T>, ?rand : Int->Int ) : Array<T>
	{
		var rnd = (rand != null) ? rand : Std.random;
		var size = ar.length;
		//
		for( i in 0...(size<<1) )
		{
			var id0 = rnd(size), id1 = rnd(size);
			var tmp = ar[id0];
			ar[id0] = ar[id1];
			ar[id1] = tmp;
		}
		//
		return ar;
	}
	
	public static function getRandom<T>( ar:Array<T>, ?rnd:Int->Int ) : T
	{
		var random = (rnd != null ) ? rnd : Std.random;
		var id = random(size(ar));
		return get(ar, id);
	}
	
	static public function usort<T>(t : Array<T>, f:T->T->Int) : Array<T> 
	{
		var a = t, i = 0, l = t.length;
		while ( i < l ) 
		{
			var swap = false;
			var j = 0,  max = l - i - 1;
			while ( j < max )
			{
				if ( f(a[j], a[j + 1]) > 0 ) 
				{
					var tmp = a[j+1];
					a[j+1] = a[j];
					a[j] = tmp;
					swap = true;
				}
				j += 1;
			}
			if( !swap )
				break;
			i += 1;
		}
		return a;
	}
	
	
}

//TODO optimize with next hxcpp impl
class ArrayFloatStd {
	static public function zero(t : Array<Float>) {
		for ( i in 0...t.length) t[i] = 0.0;
	}
}

class ArrayIntStd {
	static public function zero(t : Array<Int>) {
		for ( i in 0...t.length) t[i] = 0;
	}
}

class ArrayNullStd {
	static public function zero<T>(t : Array<Null<T>>) {
		for ( i in 0...t.length) t[i] = null;
	}
}

class ListStd
{
	inline public static function size<T>( l:List<T> ):Int
	{
		return l.length;
	}
	
	inline public static function get<T>( l:List<T>, index:Int ) : Null<T>
	{
		var ite = l.iterator();
		while(--index > -1 && ite.hasNext() ) ite.next();
		return index == -1 ? ite.next() : null;
	}
	
	inline public static function exists<T>( l:List<T>, index:Int ):Bool {
		return index >= 0 && index < size(l) && get(l,index) != null;
	}
	
	inline public static function has<T>( l:List<T>, elt:T ):Bool {
		return indexOf( l, elt ) > -1;
	}
	
	inline public static function indexOf<T>( l:List<T>, elt:T ) : Int
	{
		var id = -1, i = -1;
		for( e in l )
		{
			++i;
			if( e == elt )
			{
				id = i;
				break;
			}
		}
		return id;
	}
	
	inline public static function addFirst<T>( l : List<T>, e : T ) : List<T>
	{
		l.push(e); return l;
	}
	
	inline public static function addLast<T>( l : List<T>, e : T ) : List<T>
	{
		l.add(e); return l;
	}
	
	inline public static function removeFirst<T>( l : List<T> ) : T
	{
		return l.pop();
	}
	
	inline public static function removeLast<T>( l : List<T> ) : T
	{
		var cpy = Lambda.list(l);
		var ite = cpy.iterator();
		var last = l.last();
		//
		l.clear();
		for( i in 0...cpy.length-1 )
			l.add( ite.next() );
		//
		return last;
	}
	
	/**
	 * Modifies the Array
	 */
	/*
	inline public static function removeAt<T>( l : List<T>, index : Int ) : Null<T>
	{
		var e = null;
		var cpy = Lambda.list(l);
		l.clear();
		for ( i in 0...cpy.length )
		{
			var v = ite.next();
			if ( i != index ) l.add( v );
			else e = v;
		}
		return e;
	}
	*/
	
	inline public static function copy<T>( l : List<T> ) : List<T>
	{
		return Lambda.list( l );
	}
	
	/**
	 * Retourne un nouveau tableau !
	 */
	inline public static function flatten<T>( l : List<Iterable<T>> ) : List<T>
	{
		var out = new List<T>();
		for( i in 0...l.length )
		{
			append(out, get(l, i));
		}
		return out;
	}
	
	/**
	 * Attention : cette méthode modifie la liste d'origine !
	 */
	inline public static function append<T>( l : List<T>,  it : Iterable<T> ) : List<T>
	{
		for(x in it)
			l.add( x);
		return l;
	}
	
	/**
	 * Attention : cette méthode modifie la liste d'origine !
	 */
	inline public static function prepend<T>( l : List<T>,  it : Iterable<T> ) : List<T>
	{
		var a = Lambda.array(it);
		a.reverse();
		for(x in a)
			addFirst(l, x);
		return l;
	}

	/**
	 * Attention : cette methode modifie la liste d'origine !
	 */
	inline public static function reverse<T>( l : List<T> ) : List<T>
	{
		var cpy = [];
		while( l.length > 0 )
		{
			ArrayStd.addFirst(cpy, removeFirst(l) );
		}
		//
		while( cpy.length > 0 )
		{
			addFirst( l, ArrayStd.removeLast(cpy) );
		}
		return l;
	}
	
	/**
	 * Attention : cette methode modifie le tableau d'origine !
	 */
	public static function shuffle<T>( l : List<T>, ?rand : Int->Int ) : List<T>
	{
		var ar : Array<T> = Lambda.array(l);
		ArrayStd.shuffle(ar, rand);
		//
		l.clear();
		for( i in 0...ar.length )
		{
			addLast( l, ar[i] );
		}
		//
		ar = null;
		return l;
	}
	
	/**
	 * Copie la portion de l'Array en commençant par la position de départ "pos", jusqu'à "end" (non inclu).
	 */
	public static function slice<T>( l:List<T>, pos : Int, ?end : Int ) : List<T>
	{
		var out = new List<T>();
		if( end == null ) end = size(l);
		for( i in pos...end )
		{
			addLast( out, get(l, i) );
		}
		return out;
	}
	
	/**
	 * Supprime les "n" éléments à partir de pos et les retourne.
	 */
	public static function splice<T>( l:List<T>, pos : Int, len : Int ) : List<T>
	{
		var out = new List<T>();
		var copy = copy(l);
		l.clear();
		var i = 0;
		for( e in copy )
		{
			if( i < pos ) addLast(l, e);
			else if( i >= (pos + len) ) addLast(l, e);
			else addLast(out, e);
			i++;
		}
		return out;
	}
	
	inline public static function stripNull<T>( l : List<T> ):List<T>
	{
		while( l.remove(null) ) { }
		return l;
	}
	
	public static function getRandom<T>( l:List<T>, ?rnd:Int->Int ) : T
	{
		var random = (rnd != null ) ? rnd : Std.random;
		var id = random(size(l));
		return get(l, id);
	}
	
	static public function usort<T>(l : List<T>, f:T->T->Int) : List<T> 
	{
		var a = Lambda.array(l);
		a = ArrayStd.usort(a, f);
		
		l.clear();
		for ( e in a )
		{
			ListStd.addLast(l, e);
		}
		
		return l;
	}
	
	static public inline function inject( dst:Dynamic,src:Dynamic){
		for ( f in Reflect.fields( src ) )
			Reflect.setProperty( dst, f, Reflect.getProperty( src, f ));
	}
	
}


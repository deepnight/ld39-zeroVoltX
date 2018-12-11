
package mt;


typedef IntHash<T> = haxe.ds.IntMap<T>;
typedef Hash<T> = haxe.ds.StringMap<T>; 
typedef Stack = haxe.CallStack;
typedef Md5 = haxe.crypto.Md5;


#if dbadmin
typedef DbAdmin = sys.db.Admin;
#elseif spadm
typedef DbAdmin = spadm.Admin;
#end



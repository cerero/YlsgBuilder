package utils
{
	import flash.utils.ByteArray;

	/** 自定义AMF结构读取 */
	public class CAmfUtil
	{
		/** 自定义优化zlib+amf格式二进制版本字符串 */
		private static const VER_STR:String = "czlib_1.0";
		
		public static function isCAmf(bytes:ByteArray):Boolean
		{
			var tpos:uint = bytes.position;
			bytes.position = 0;
			if( bytes.length >= VER_STR.length
				&& bytes.readMultiByte(VER_STR.length, "utf-8") == VER_STR){
				//
				bytes.position = tpos;
				return true;
			}
			//
			bytes.position = tpos;
			return false;
		}
		
		/** 写入obj至自定义amf格式中 */
		public static function write(obj:*):ByteArray
		{
			var tba:ByteArray = new ByteArray();
			tba.writeMultiByte(VER_STR, "utf-8");
			
			var tamf:ByteArray = new ByteArray();
			tamf.writeObject(obj);
			tamf.compress();
			
			tba.writeUnsignedInt(tamf.length);
			tba.writeBytes(tamf);
			tamf.clear();
			
			return tba;
		}
		
		/** 
		 * 从ByteArray中读取Object对象 
		 * 
		 * @param	bytes	内容ByteArray 或  String 或 XML
		 * @param	type	格式，xml或json（当bytes为非自定义压缩格式时有效）
		 */
		public static function read(bytes:*, type:String="json"):*
		{
			return XmlUtil.readObjectFrom(bytes, type);
		}
		
		/** 得到to接口返回的XML对象对应Object实例的children */
		public static function children(dp:Object):Object
		{
			return firstObject(firstObject(dp));
		}
		
		private static var types:Array = ["object", "array"];
		private static function firstObject(dp:*):Object
		{
			var tobj:Object;
			for(var e0:* in dp){
				if(types.indexOf(typeof(dp[e0])) != -1){
					if(tobj == null) 
						if(dp[e0] != null && dp[e0].hasOwnProperty("id")){
							tobj = dp;
						}
						else{
							tobj = dp[e0];
						}
						else {
							tobj = dp;
							break;
						}
				}
			}
			return tobj == null ? dp : tobj;
		}
	}
}
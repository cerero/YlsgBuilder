package utils
{
	import com.adobe.serialization.json.JSON;
	
	import flash.utils.ByteArray;
	
	public class XmlUtil
	{
		/** 自定义优化zlib+amf格式二进制版本字符串 */
		private static const VER_STR:String = "czlib_1.0";
		
		/** 
		 * 从ByteArray中读取Object对象 
		 * 
		 * @param	bytes	内容ByteArray 或  String
		 * @param	type	格式，xml或json（当bytes为非自定义压缩格式时有效）
		 */
		public static function readObjectFrom(bytes:*, type:String="json"):*
		{
			//String对象
			if(bytes is String)
			{
				if(type == "json")
				{
					//JSON
					return com.adobe.serialization.json.JSON.decode(bytes.toString());
				}
				else
				{
					//XML
					return to(bytes);
				}
			}
			//XML
			else if(bytes is XML)
			{
				return to(bytes);
			}
			//ByteArray
			else if(bytes is ByteArray)
			{
				bytes.position = 0;
				if( bytes.length >= VER_STR.length
					&& bytes.readMultiByte(VER_STR.length, "utf-8") == VER_STR){
					//自定义压缩格式
					var tlen:uint = bytes.readUnsignedInt();
					var tba:ByteArray = new ByteArray();
					bytes.readBytes(tba, 0, tlen);
					
					tba.uncompress();
					var tret:* = tba.readObject();
					tba.clear();
					return tret;
				}
				else
				{
					bytes.position -= VER_STR.length;
					try{ bytes.uncompress(); bytes.position = 0; }catch(e1:*){};
					try
					{
						//AMF
						return bytes.readObject();
					}
					catch(e2:*)
					{
						if(type == "json")
						{
							//JSON
							return com.adobe.serialization.json.JSON.decode(bytes.toString());
						}
						else
						{
							//XML
							return to(bytes);
						}
					}
				}
			}
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
		
		/** 把XML、ByteArray、xml String对象置换成Object */
		private static function to(dp:*,ignoreNamespace:Boolean=false):Object  
		{  
			if(dp is ByteArray || dp is String){
				dp = new XML(dp);
			}
			if(dp is XML){  
				var tobj:Object = {};  
				dp.ignoreWhitespace = true;  
				pNode(dp, tobj, ignoreNamespace);
				return tobj;
			}  
			return null;
		}
		
		/** XML节点解析 */
		private static function pNode(node:XML,obj:Object,ignoreNamespace:Boolean):void  
		{  
			if(ignoreNamespace){
				node.setNamespace("");
			}
			
			var tnodeName:String = node.name().toString();  
			var tobj:Object = {};
			
			if(node.attributes().length() > 0){
				var tattrs:XMLList = node.attributes();
				for(var j:* in tattrs){  
					tobj[tattrs[j].name()["toString"]()] = StringUtil.toProperType(tattrs[j], false);  
				}
				
				if(node.children().length()<=1&&tobj["value"]==undefined){  
					tobj["value"] = StringUtil.toProperType(node, false);//node.toString();  
				}
			}
			else{  
				if(node.children().length()<=1&&!node.hasComplexContent()){  
					tobj = StringUtil.toProperType(node, false);//node.toString();
				}
			}
			
			if(obj[tnodeName] == undefined){
				obj[tnodeName] = tobj;
			}
			else{
				if(obj[tnodeName] is Array){ 
					obj[tnodeName].push(tobj);
				}
				else{
					obj[tnodeName] = [obj[tnodeName], tobj];
				}
			}
			
			try{
				toObj(node,obj[tnodeName],ignoreNamespace);  
			}
			catch(e:Error){};
		} 
		
		/** 解析对象 */
		private static function toObj(dp:XML, obj:*, ignoreNamespace:Boolean):void  
		{  
			var nl:int = dp.children().length();  
			for(var i:int = 0; i < nl; i++) {  
				var tnode:XML = dp.children()[i];
				if(obj is Array){  
					pNode(tnode,obj[obj.length-1],ignoreNamespace);  
				}
				else{
					pNode(tnode,obj,ignoreNamespace);
				}
			} 
		}
		
		/** 比较两个ByteArray是否相等 */
		public static function compareObject(byte1:ByteArray, byte2:ByteArray):Boolean 
		{ 
			var size:uint = byte1.length; 
			if(size == byte2.length) { 
				for(var i:int = 0; i < size; i++){
					if(byte1[i] != byte2[i]) return false;
				}
				return true;                         
			}
			return false; 
		}  
	}
}
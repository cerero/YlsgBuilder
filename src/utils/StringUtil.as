package utils
{
	/**
	 * The StringUtil class is an utility class for string operation.
	 * StringUtil class can not instanciate directly.
	 * When call the new StringUtil() constructor, the ArgumentError exception will be thrown.
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 9.0.45.0
	 */
	public class StringUtil {
		
		/**
		 * 查找行结束符正则表达式
		 */
		private static const _COLLECTBREAK_REGEXP:RegExp = new RegExp( "(\r\n|\n|\r)", "g" );
		
		/**
		 * Convert the specified string to the proper object type and returns.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 9.0.45.0
		 * 
		 * @param str The string to convert.
		 * @param priority Whether it gives priority to expressing numerically or not?
		 * @return The converted object.
		 * 
		 * @example <listing version="3.0" >
		 * trace( StringUtil.toProperType( "true" ) == true ); // true
		 * trace( StringUtil.toProperType( "false" ) == false ); // true
		 * trace( StringUtil.toProperType( "null" ) == null ); // true
		 * trace( StringUtil.toProperType( "ABCDE" ) == "ABCDE" ); // true
		 * trace( StringUtil.toProperType( "100" ) == 100 ); // true
		 * trace( StringUtil.toProperType( "010" ) == 10 ); // true
		 * trace( StringUtil.toProperType( "010", false ) == "010" ); // true
		 * trace( StringUtil.toProperType( "10.0", false ) == "10.0" ); // true
		 * </listing>
		 */
		public static function toProperType(str:String, priority:Boolean = true):* 
		{
			var num:Number = parseFloat(str);
			if(priority) {
				if(!isNaN( num )) { return num; }
			}
			else {
				if (num.toString() == str) { return num; }
			}
			
			switch (str) {
				case "true"			: { return true; }
				case "TRUE"			: { return true; }
				case "FALSE"		: { return false; }
				case "false"		: { return false; }
				case ""				:
				case "null"			: { return null; }
				case "undefined"	: { return undefined; }
				case "Infinity"		: { return Infinity; }
				case "-Infinity"	: { return -Infinity; }
				case "NaN"			: { return NaN; }
			}
			
			return str;
		}
		
		/**
		 * <p>Returns the string which repeats the specified string with specified times.</p>
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 9.0.45.0
		 * 
		 * @param str
		 * 	<p>The string to repeat.</p>
		 * @param count
		 * 	<p>Repeat time.</p>
		 * @return
		 * 	<p>Repeated string.</p>
		 * 
		 * @example <listing version="3.0" >
		 * trace( StringUtil.repeat( "A", 0 ) == "" ); // true
		 * trace( StringUtil.repeat( "A", 1 ) == "A" ); // true
		 * trace( StringUtil.repeat( "A", 2 ) == "AA" ); // true
		 * trace( StringUtil.repeat( "ABC", 3 ) == "ABCABCABC" ); // true
		 * </listing>
		 */
		public static function repeat(str:String, count:int = 0):String 
		{
			var result:String = "";
			count = Math.max( 0, count );
			for ( var i:int = 0; i < count; i++ ) {
				result += str;
			}
			return result;
		}
		
		/**
		 * <p>Convert the first character to upper case and remain character to lower case of the specified string.</p>
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 9.0.45.0
		 * 
		 * @param str
		 * 	<p>The string to convert.</p>
		 * @return
		 * 	<p>The converted string.</p>
		 * 
		 * @example <listing version="3.0" >
		 * trace( StringUtil.toUpperCaseFirstLetter( "ABCDE" ) == "Abcde" );
		 * trace( StringUtil.toUpperCaseFirstLetter( "abcde" ) == "Abcde" );
		 * trace( StringUtil.toUpperCaseFirstLetter( "aBCDE" ) == "Abcde" );
		 * </listing>
		 */
		public static function toUpperCaseFirstLetter( str:String ):String 
		{
			return str.charAt( 0 ).toUpperCase() + str.slice( 1 ).toLowerCase();
		}
		
		/**
		 * <p>Convert the line feed code of the specified string and returns.</p>
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 9.0.45.0
		 * 
		 * @param str
		 * 	<p>The string to convert.</p>
		 * @param newLine
		 * 	<p>The line feed code to convert to.</p>
		 * @return
		 * 	<p>The converted string.</p>
		 * 
		 * @example <listing version="3.0" >
		 * </listing>
		 */
		public static function collectBreak( str:String, newLine:String = null ):String 
		{
			newLine ||= "\n";
			switch ( newLine ) {
				case "\r"		:
				case "\n"		:
				case "\r\n"		: { return str.replace( _COLLECTBREAK_REGEXP, newLine ); }
			}
			
			throw new ArgumentError("ERROR_8006");
		}
		
		/**
		 * <p>Convert the specified query form string to the Object and returns.</p>
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 9.0.45.0
		 * 
		 * @param query
		 * 	<p>The query form string.</p>
		 * @return
		 * 	<p>The converted Object.</p>
		 * 
		 * @example <listing version="3.0" >
		 * var o:Object = StringUtil.queryToObject( "a=A&b=B&c=C" );
		 * trace( o.a ); // A
		 * trace( o.b ); // B
		 * trace( o.c ); // C
		 * </listing>
		 */
		public static function queryToObject( query:String ):Object 
		{
			var o:Object = {};
			var queries:Array = query ? query.split( "&" ) : [];
			var l:int = queries.length;
			for ( var i:int = 0; i < l; i++ ) {
				var item:Array = String( queries[i] ).split( "=" );
				o[item[0]] = StringUtil.toProperType( item[1] );
			}
			
			return o;
		}
		
		/**
		 * 是否为Email地址
		 */ 
		public static function isEmail(char:String):Boolean
		{ 
			if(char == null){ 
				return false; 
			} 
			char = trim(char); 
			var pattern:RegExp = /(\w|[_.\-])+@((\w|-)+\.)+\w{2,4}+/;  
			var result:Object = pattern.exec(char); 
			if(result == null) { 
				return false; 
			} 
			return true; 
		} 
		
		/**
		 * 是否是数值字符串
		 */ 
		public static function isNumber(char:String):Boolean
		{ 
			if(char == null){ 
				return false; 
			} 
			return !isNaN(Number(char)); 
		} 
		
		/** 
		 * English;
		 */  
		public static function isEnglish(char:String):Boolean
		{ 
			if(char == null){ 
				return false; 
			} 
			char = trim(char); 
			var pattern:RegExp = /^[A-Za-z]+$/;  
			var result:Object = pattern.exec(char); 
			if(result == null) { 
				return false; 
			} 
			return true; 
		} 
		
		/**
		 * 中文;
		 */  
		public static function isChinese(char:String):Boolean
		{ 
			if(char == null){ 
				return false; 
			} 
			char = trim(char); 
			var pattern:RegExp = /^[\u0391-\uFFE5]+$/;  
			var result:Object = pattern.exec(char); 
			if(result == null) { 
				return false; 
			} 
			return true; 
		}
		
		/** 
		 * URL地址
		 */  
		public static function isURL(char:String):Boolean
		{ 
			if(char == null){ 
				return false; 
			} 
			char = trim(char).toLowerCase(); 
			var pattern:RegExp = /^http:\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/;  
			var result:Object = pattern.exec(char); 
			if(result == null) { 
				return false; 
			} 
			return true; 
		}
		
		/**
		 * 去左右空格
		 */  
		public static function trim(char:String):String
		{ 
			if(char == null){ 
				return null; 
			} 
			return rtrim(ltrim(char)); 
		} 
		
		/**
		 * 去左空格;
		 */   
		public static function ltrim(char:String):String
		{ 
			if(char == null){ 
				return null; 
			} 
			var pattern:RegExp = /^\s*/;   
			return char.replace(pattern,"");  
		}  
		
		/**
		 * 去右空格;
		 */   
		public static function rtrim(char:String):String
		{  
			if(char == null){  
				return null;  
			}  
			var pattern:RegExp = /\s*$/;   
			return char.replace(pattern,"");  
		}
		
		/**
		 * 是否为前缀字符串;
		 */   
		public static function beginsWith(char:String, prefix:String):Boolean
		{            
			return (prefix == char.substring(0, prefix.length));  
		}  
		
		/**
		 * 是否为后缀字符串; 
		 */  
		public static function endsWith(char:String, suffix:String):Boolean
		{  
			return (suffix == char.substring(char.length - suffix.length));  
		} 
		
		/**
		 * 字符串替换;
		 */   
		public static function replace(char:String, replace:String, replaceWith:String):String
		{           
			return char.split(replace).join(replaceWith);  
		}
		
		/**
		 * 添加新字符到指定位置;
		 */          
		public static function addAt(char:String, value:String, position:int):String 
		{  
			if (position > char.length) {  
				position = char.length;  
			}  
			var firstPart:String = char.substring(0, position);  
			var secondPart:String = char.substring(position, char.length);  
			return (firstPart + value + secondPart);  
		}  
		
		/** 
		 * 替换指定位置字符;
		 */   
		public static function replaceAt(char:String, value:String, beginIndex:int, endIndex:int):String 
		{  
			beginIndex = Math.max(beginIndex, 0);             
			endIndex = Math.min(endIndex, char.length);  
			var firstPart:String = char.substr(0, beginIndex);  
			var secondPart:String = char.substr(endIndex, char.length);  
			return (firstPart + value + secondPart);  
		}  
		
		/**
		 * 删除指定位置字符; 
		 */  
		public static function removeAt(char:String, beginIndex:int, endIndex:int):String 
		{  
			return StringUtil.replaceAt(char, "", beginIndex, endIndex);  
		}
	}
}

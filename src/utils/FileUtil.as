package utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileUtil
	{
		/** 从文件读取 */
		public static function read(file:*, position:uint=0, length:uint=0):ByteArray
		{
			var tfs:FileStream;
			if(file is File)
			{
				tfs = new FileStream();
				tfs.open(file, FileMode.READ);
			}
			else if(file is FileStream)
			{
				tfs = file;
			}
			else if(file is String){
				file = new File(file);
				tfs = new FileStream();
				tfs.open(file, FileMode.READ);
			}
			else{
				throw new Error("参数类型不正确");
			}
			
			var tbyte:ByteArray = new ByteArray();
			tfs.position = position;
			if(tfs.bytesAvailable > length){
				tfs.readBytes(tbyte, 0, length);
			}
			else{
				tfs.readBytes(tbyte);
			}
			tfs.close();
			tbyte.position = 0;
			return tbyte;
		}
		
		/** 写入到文件 */
		public static function write(file:*, byte:*):void
		{
			var tfs:FileStream;
			if(file is File)
			{
				tfs = new FileStream();
				tfs.open(file, FileMode.WRITE);
			}
			else if(file is FileStream)
			{
				tfs = file;
			}
			else if(file is String){
				file = new File(file);
				tfs = new FileStream();
				tfs.open(file, FileMode.WRITE);
			}
			else{
				throw new Error("参数类型不正确");
			}
			
			if(byte is ByteArray){
				tfs.writeBytes(byte);
			}
			else if(byte is String){
				tfs.writeMultiByte(byte, "utf-8");
			}
			else if(byte is Array){
				//数组
				for(var i:int = 0; i < byte.length; i++){
					if(byte[i] is ByteArray){
						tfs.writeBytes(byte[i]);
					}
					else if(byte[i] is String){
						tfs.writeMultiByte(byte[i], "utf-8");
					}
				}
			}
			tfs.close();
			//trace("save:" + file.nativePath);
		}
		
		/** 文件是否存在 */
		public static function isExists(file:*):Boolean
		{
			if(file is File)
			{
				return (file as File).exists;
			}
			else if(file is String)
			{
				return (new File(file)).exists;
			}
			else
			{
				throw new Error("参数类型不正确");
			}
		}
		
		/** 得到文件扩展名 */
		public static function getExtname(file:*):String
		{
			var tname:String = file is File ? (file as File).name : file;
			var tidx:int = tname.lastIndexOf(".");
			var text:String = tidx == -1 ? "" : tname.substr(tidx + 1);
			
			return text.split("_")[0];
		}
		
		/** 得到不包括版本号的文件路径 */
		public static function getPath(file:*):String
		{
			var tname:String = file is File ? (file as File).name : file;
			var tidx:int = tname.lastIndexOf(".");
			var text:String = tidx == -1 ? "" : tname.substr(tidx + 1);
			var tarr:Array = text == "" ? tname.split("_") : text.split("_");
			
			var tpath:String = file is File ? (file as File).url : file;
			var tps:Array = tpath.split("/");
			tpath = tps.slice(0, tps.length-1).join("/") + "/";
			
			if(tarr.length > 1)
			{
				if(text == "")
				{
					return tpath+tarr[0];
				}
				else
				{
					return tpath+tname.substr(0, tidx)+"."+tarr[0];
				}
			}
			else
			{
				return tpath+tname;
			}
		}
		
		/** 文件改名 */
		public static function copyTo(file1:*, file2:*):void
		{
			var tf1:File, tf2:File;
			if(file1 is File)
			{
				tf1 = file1;
			}
			else if(file1 is String){
				tf1 = new File(file1);
			}
			else{
				throw new Error("参数类型不正确");
			}
			
			if(file2 is File)
			{
				tf2 = file2;
			}
			else if(file2 is String){
				tf2 = new File(file2);
			}
			else{
				throw new Error("参数类型不正确");
			}
			
			if(tf1.nativePath != tf2.nativePath)
			{
				if(!tf2.exists)
				{
					tf1.copyTo(tf2);
				}
			}
		}
		
		/** 得到文件大小 */
		public static function getSize(file:*):Number
		{
			var tf:File;
			if(file is File)
			{
				tf = file;
			}
			else if(file is String)
			{
				tf = new File(file);
			}
			else
			{
				throw new Error("参数类型不正确");
			}
			return tf.size;
		}
	}
}
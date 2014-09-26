package utils
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class Output
	{
		public static var append:Boolean=true;
		private static var log:File;
		public static function initlized(file:File, name:String="logo.txt"):void
		{
//			if(file.isDirectory){
//				log = new File(file.nativePath + File.separator + name);
//			}
//			else{
//				log = file;
//			}
		}
		
		public static function clear():void
		{
//			if(log.exists){
//				FileUtil.write(log, new ByteArray());
//			}
		}
		
		public static function output(...args):void
		{
			trace(args);
			
//			var tmsg:String = args.join("\t");
//			var tstr:ByteArray;
//			if(log.exists && append){
//				tstr = FileUtil.read(log);
//				tstr.position = tstr.length;
//			}
//			else{
//				tstr = new ByteArray();
//			}
//			
//			tstr.writeMultiByte("\n", "utf-8");
//			tstr.writeMultiByte("[" + new Date().toString() + "] ", "utf-8");
//			tstr.writeMultiByte(tmsg, "utf-8");
//			
//			FileUtil.write(log, tstr);
//			tstr.clear();
		}
	}
}
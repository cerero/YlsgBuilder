package build
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	
	import utils.Output;

	public class MoveFile
	{
		public function MoveFile()
		{
		}
		
		/** 当前目录 */
		private var currentDirectory:File;
		/** 本地应用程序 */
		private var nativeApplication:NativeApplication;
		
		public function start(nativeApplication:NativeApplication, currentDirectory:File):void
		{
			this.currentDirectory = currentDirectory;
			this.nativeApplication = nativeApplication;
			
			Output.output("开始移动文件...");
			Output.output("当前目录: " + currentDirectory.nativePath);
			try{
				var sFile:File = new File(currentDirectory.parent.nativePath+File.separator+"output"+File.separator+"client");
				var tFile:File = new File(currentDirectory.parent.parent.parent.parent.nativePath+File.separator+"ylsg_output");
				
				var files:Array = sFile.getDirectoryListing();
				for each( var f:File in files ){
					if( !f.isDirectory && (f.name == "CommonProgressBar.swf" || f.name == "UtilLib.swf" )){
						continue;
					}
					f.copyTo(new File(tFile.nativePath+File.separator+f.name),true);
				}
			}catch(e:*){
				Output.output("错误:", e);
				if(nativeApplication) 
					nativeApplication.exit(1);
				
				return;
			}
			Output.output("移动文件完毕...");
			if(nativeApplication) nativeApplication.exit();
			
		}
	}
}
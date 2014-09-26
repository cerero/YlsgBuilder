package build
{
	import data.Config;
	
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	
	import utils.FileUtil;
	import utils.Output;
	import utils.SwfUtil;

	public class EncrySwf
	{
		/** 文件选择事件 */
		public function encry(nativeApplication:NativeApplication, currentDirectory:File):void
		{
			Output.output("生成加密文件列表...");
			Output.output("当前目录: " + currentDirectory.nativePath);
			try
			{
				//基础目录
				var tpath:String = currentDirectory.parent.nativePath + File.separator + "output" + File.separator + "client" + File.separator;
				var tlist:Array = [];
				//目录列表
				for each(var tfolder:String in Config.ENCRY_CFG.folder)
				{
					var tarr:Array = (new File(tpath + tfolder)).getDirectoryListing();
					for each(var tf:File in tarr){
						if(!tf.isDirectory && FileUtil.getExtname(tf) == "swf"){
							//swf文件
							Output.output("======<< " + tf.name + "\t\t\t\t[OK]");
							tlist.push(tf);
						}
					}
				}
				//文件列表
				for each(var tfile:String in Config.ENCRY_CFG.files){
					tf = new File(tpath + tfile)
					if(tf.exists){
						tlist.push(tf);
						Output.output("======<< " + tf.name + "\t\t\t\t[OK]");
					}
				}
				Output.output("total:" + tlist.length);
				SwfUtil.encrytSwf(tlist);
				Output.output("all complete!!!");
				if(nativeApplication) nativeApplication.exit();
			}
			catch(e:*){
				Output.output("错误:", e);
				if(nativeApplication) nativeApplication.exit(1);
			}
		}
	}
}
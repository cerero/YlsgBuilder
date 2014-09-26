package utils
{
	import data.Config;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.describeType;

	/** 模块解析工具类 */
	public class ParseModuleUtil
	{
		/**分析板块*/
		public static function parse(file:File, onComplete:Function, onError:Function):void
		{
			//分析并生成模块文件
			var tpath:String = [file.parent.nativePath, "output", "client", ""].join(File.separator);
			var tlc:LoaderContext = new LoaderContext();
			//
			loaders = new Vector.<Loader>();
			files = new Vector.<File>();
			tlc.applicationDomain = ApplicationDomain.currentDomain;
			tlc.allowLoadBytesCodeExecution = true;
			tlc.allowCodeImport = true;
			for(var i:int = 0; i < Config.SCRIPT_CFG.base_swf.length; i+=1)
			{
				var tf:File = new File(tpath+Config.SCRIPT_CFG.base_swf[i]);
				if(tf.exists){
					files.push(tf);
					Output.output("======>> " + tf.name + "\t\t\t\t[OK]");
				}
				else{
					Output.output("======>> " + tf.name + "\t\t\t\t[FAILURE]");
				}
			}
			if(files.length != Config.SCRIPT_CFG.base_swf.length){
				Output.output("检查目录文件失败，有文件不存在！");
				if(onError is Function) onError();
				return;
			}
			
			refFiles = new Vector.<File>();
			for( var j:int=0;j<Config.SCRIPT_CFG.ref_swf.length;j++  ){
				var ref:File = new File(tpath+Config.SCRIPT_CFG.ref_swf[j]);
				if( ref.exists ){
					refFiles.push(ref);
					Output.output("======>> 引用库" + ref.name + "\t\t\t\t[OK]");
				}else
					Output.output("======>> 引用库" + ref.name + "\t\t\t\t[FAILURE]");
			}
			if(refFiles.length != Config.SCRIPT_CFG.ref_swf.length){
				Output.output("检查引用库文件失败，有文件不存在！");
				if(onError is Function) onError();
				return;
			}
			
			Output.output("加载文件...");
			parseRefModuleFiles(tlc, onComplete);
		}
		
		/** 分析模块信息 */
		private static function parseRefModuleFiles(lc:LoaderContext, onComplete:Function):void
		{
			var tfile:File = refFiles.shift();
			var tld:Loader = new Loader();
			//加载完成函数
			completeHandler = function(evt:Event):void
			{
				//卸载及删除事件
				evt.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
				Output.output("=====<< 加载库文件" + tfile.name + "\t\t\t\t\t[OK]");
				//加载剩余的文件
				if(refFiles.length > 0){
					parseRefModuleFiles(lc, onComplete);
				}
				else{
					//清理
					completeHandler = null;
					//loaders = null;
					refFiles = null;
					//加载完成，生成模块信息及编译脚本
					parseModuleFiles(lc,onComplete);
				}
			};
			//加载
			//loaders.push(tld);
			tld.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			tld.loadBytes(SwfUtil.decryptSwf(tfile), lc);
		}
		
		/** 完成函数 */
		private static var completeHandler:Function;
		private static var loaders:Vector.<Loader>;
		private static var files:Vector.<File>;
		private static var refFiles:Vector.<File>;
		/** 分析模块信息 */
		private static function parseModuleFiles(lc:LoaderContext, onComplete:Function):void
		{
			var tfile:File = files.shift();
			var tld:Loader = new Loader();
			//加载完成函数
			completeHandler = function(evt:Event):void
			{
				//卸载及删除事件
				evt.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
				//加载剩余的文件
				if(files.length > 0){
					Output.output("=====<< " + tfile.name + "\t\t\t\t\t[OK]");
					parseModuleFiles(lc, onComplete);
				}
				else{
					//加载完成，生成模块信息及编译脚本
					onComplete(genModuleConfig(loaders));
					//清理
					completeHandler = null;
					loaders = null;
					files = null;
				}
			};
			//加载
			loaders.push(tld);
			tld.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			tld.loadBytes(SwfUtil.decryptSwf(tfile), lc);
		}
		
		/** 生成模块配置文件 */
		private static function genModuleConfig(loaders:Vector.<Loader>):Object
		{
			//得到模块定义
			var tcls:Class = null;
			var tdomain:ApplicationDomain;
			var tld:Loader;
			var tmodulesDic:Object = {};
			
			for each(var tname:String in Config.SCRIPT_CFG.modules){
				for each(tld in loaders){
					tdomain = tld.contentLoaderInfo.applicationDomain;
					try
					{ 
						tcls = tdomain.getDefinition(tname) as Class;
					}
					catch(e:*)
					{
						tcls = null;
					};
					if(tcls != null) break;
				}
				//获取的类存在
				if(tcls != null){
					//所有面板
					var txml:XML = describeType(tcls);
					var tvarlist:* = CAmfUtil.read(txml)["type"].factory.variable;
					
					tvarlist = tvarlist == null ? null : (tvarlist is Array ? tvarlist : [tvarlist]);
					
					tname = tname.split("::")[1];
					if(tmodulesDic[tname] == null){
						tmodulesDic[tname] = {};
					}
					
					for each (var itm:* in  tvarlist){
						tmodulesDic[tname][String(itm.name)] = String(itm.type);
					}
				}
			}
			return tmodulesDic;
		}
	}
}
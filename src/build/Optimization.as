package build
{
	import by.blooddy.crypto.MD5;
	import by.blooddy.crypto.serialization.JSON;
	
	import com.adobe.utils.StringUtil;
	
	import data.Config;
	
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import utils.CAmfUtil;
	import utils.FileUtil;
	import utils.JsonUtil;
	import utils.Output;
	import utils.ParseModuleUtil;

	public class Optimization
	{
		/** assets/config.xml数据内容 */
		private var configObj : Object;
		/** assets/config.xml数据集合文件内容 */
		private var configDataObj : Object;
		/** assets/config.xml数据集合文件内容数据 */
		private var configDataByte : ByteArray;
		/** assets/config.xml数据集合文件 */
		private var configDataFile : File;
		
		/** 选择目录事件 */
		public function start(nativeApplication:NativeApplication, currentDirectory:File):void
		{
			try
			{
				optimizaConfig(nativeApplication, currentDirectory, false);
				optimizaSwf(nativeApplication, currentDirectory, true);
			}
			catch(e:*){
				Output.output("错误:", e);
				if(nativeApplication) nativeApplication.exit(1);
			}
		}
		
		private var nativeApplication:NativeApplication;
		private var verDic:Dictionary;
		private var proptertiesFile:File;
		private var fileNum:uint;
		private function finish():void
		{
			/**生成版本配置表**/
			var versionStr:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
			versionStr+="<version>";
			var outputVerDic:Dictionary = new Dictionary();
			var oriUrlToVerUrl:Dictionary = new Dictionary();
			var md5:String;
			for( var key:* in verDic ){
				md5 = verDic[key];
				var name:String = key;
				name = name.replace(/\\/g,"/");
				name = name.split(Config.OUT_PUT).join("");
				name = name.substr(1);
				versionStr+="<item id=\""+name+"\" v=\""+md5+"\"/>";
				
				outputVerDic[name] = md5;
				
				var pattern:RegExp = /^assets\/scene\/\d*$/g ;
				var ret:Object = pattern.exec(name);
				if( ret ){
					//searchId = ret[1]+ret[2];
				}else{
					var suffix:String = name.substr(name.lastIndexOf("."));
					var prefix:String = name.substring(0,name.lastIndexOf("."));
					var vUrl:String = prefix + "_"+ md5 +suffix;
					oriUrlToVerUrl[name] = vUrl;
				}
			}
			versionStr += "</version>";
			outputVerDic["oriUrlToVerUrl"] = oriUrlToVerUrl; 
			
			/**生成startup.xml**/
			var startupXmlFile:File =new File(Config.OUT_PUT.split("/").join(File.separator)+File.separator+"startup.xml"); 
			tbyte = FileUtil.read(startupXmlFile);
			var startupXml:XML = new XML(tbyte);
			startupXml.cfg[0].project_state.@value = 1;
			
			var libSize:int = 0;
			for each( var lib:XML in startupXml.libs[0].children() ){
				var url:String = Config.OUT_PUT+"/"+lib.@url;
				url = url.split("/").join(File.separator);
				var libFile:File = new File(url);
				//md5 = verDic[libFile.nativePath];
				md5 = outputVerDic[String(lib.@url)];
				lib.@size = int(FileUtil.getSize(libFile)/1024);
				libSize += int(lib.@size);
				lib.@ver = md5;
			}
			startupXml.libs[0].@size = libSize;
			FileUtil.write(new File(Config.PUB_GAME_RES_PATH.split("/").join(File.separator)+File.separator+"startup.xml"),startupXml.toString());
			
			
			var tbyte:ByteArray = CAmfUtil.write(new XML(versionStr));
			var verByte:ByteArray = CAmfUtil.write(outputVerDic);
			
			md5 = MD5.hashBytes(verByte).substr(0,8);
			FileUtil.write(new File(Config.PUB_GAME_RES_PATH.split("/").join(File.separator)+File.separator+"version.xml"),verByte);
			FileUtil.write(new File(Config.PUB_GAME_RES_PATH.split("/").join(File.separator)+File.separator+"version_o.xml"),versionStr);
			
			/**生成plugin.xml中的版本号**/
			tbyte = FileUtil.read(new File(Config.OUT_PUT.split("/").join(File.separator)+File.separator+"plugin.xml"));
			var pluginXml:XML = new XML(tbyte);
			pluginXml.Global[0].Version[0].@ver = md5;
			tbyte = CAmfUtil.write(pluginXml);
			
			FileUtil.write(new File(Config.PUB_GAME_RES_PATH.split("/").join(File.separator)+File.separator+"plugin.xml"),tbyte);
			FileUtil.write(new File(Config.PUB_GAME_RES_PATH.split("/").join(File.separator)+File.separator+"plugin_o.xml"),pluginXml.toString());
			
			Output.output("打版本结束,处理了"+fileNum+"个文件");
			if(nativeApplication)
				nativeApplication.exit(0);
		}
	
		/**遍历目录资源，构造版本号**/
		public function makeVersion(nativeApplication:NativeApplication, currentDirectory:File, exit:Boolean=true):void
		{
			/*try
			{*/
				fileNum = 0;
				this.nativeApplication = nativeApplication; 
				//BuildQueue.setQueueFinishCallback(finish);
				//清除PUB_BASE_RES_PATH目录的内容
				Output.output("清除"+Config.PUB_BASE_RES_PATH+"目录的内容...");
				var delFile:File = new File(Config.PUB_BASE_RES_PATH);
				if( delFile.exists )
					delFile.deleteDirectory(true);
				
				//清除PUB_GAME_RES_PATH目录的内容
				Output.output("清除"+Config.PUB_GAME_RES_PATH+"目录的内容...");
				delFile = new File(Config.PUB_GAME_RES_PATH);
				if( delFile.exists )
					delFile.deleteDirectory(true);
				
				var fileOutput:File = new File(Config.OUT_PUT.split("/").join(File.separator));//工程输出目录
				//对工程输出目录下的代码swf构造版本号
				var files:Array = fileOutput.getDirectoryListing();
				var file:File;
				verDic = new Dictionary();
				Output.output("开始打版本...");
				for each( file in files ){
					doMakeVersion(file,verDic);
					//BuildQueue.getInstance().add(doMakeVersion,[file,verDic]);
				}
				finish();
			/*}
			catch(e:*){
				Output.output("错误:", e);
				if(nativeApplication) nativeApplication.exit(1);
			}*/
		}
		
		/**复制配置目录内容到发布目录，并添加md5码到文件名**/
		private function moveConfigFile(source:File,compressByte:ByteArray,md5:String):void
		{
			var newNativePath:String = source.nativePath.replace(/\\/g,"/");
			newNativePath = newNativePath.split(Config.OUT_PUT).join(Config.PUB_BASE_RES_PATH);
			
			var suffix:String = newNativePath.substr(newNativePath.lastIndexOf("."));
			var prefix:String = newNativePath.substring(0,newNativePath.lastIndexOf("."));
			newNativePath = prefix + "_"+ md5 +suffix;
			
			var target:File = new File(newNativePath);
			FileUtil.write(target,compressByte);
			Output.output(source.nativePath+"复制到"+newNativePath);
		}
		/**复制内容到发布目录，并添加md5码到文件名**/
		private function moveFile(source:File,md5:String):void
		{
			var newNativePath:String = source.nativePath.replace(/\\/g,"/");
			newNativePath = newNativePath.split(Config.OUT_PUT).join(Config.PUB_BASE_RES_PATH);
			if( md5 != null ){
				var suffix:String = newNativePath.substr(newNativePath.lastIndexOf("."));
				var prefix:String = newNativePath.substring(0,newNativePath.lastIndexOf("."));
				newNativePath = prefix + "_"+ md5 +suffix;
			}
			FileUtil.copyTo(source,new File(newNativePath));
			Output.output(source.nativePath+"复制到"+newNativePath);
		}
		
		private function doMakeVersion(file:File,verDic:Dictionary,callback:Function=null):void
		{
			var filName:String = file.name;
			if(checkSkipSys(file, Config.OPT_CFG.cfg_skips)){//忽略系统生成的文件
				var tname:String;
				if( file.isDirectory )
					tname = file.name;
				else
					tname = file.name.substr(0, file.name.lastIndexOf(".")); //文件名
					
				var text:String = file.name.substr(file.name.lastIndexOf(".") + 1).toLowerCase(); //扩展名
				fileNum++;
				if( tname == "crossdomain" ){
					moveFile(file,null);			
				}else if(tname=="Startup"&&text=="swf"){//Startup.swf不用打版本 直接移动
					var newNativePath:String = file.nativePath.replace(/\\/g,"/");
					newNativePath = newNativePath.split(Config.OUT_PUT).join(Config.PUB_GAME_RES_PATH);
					var newFile:File = new File(newNativePath);
					Output.output(file.nativePath+"复制到"+newFile.nativePath);
					FileUtil.copyTo(file,newFile);
				}
			}else{
				if( !file.isDirectory ){//根目录下的代码swf、css、敏感词、version文件
					fileNum++;
					var byte:ByteArray = FileUtil.read(file);
					var zip:Object = {};
					zip["md5"] = MD5.hashBytes(byte).substr(0, 8);
					zip["name"] = file.nativePath;
					verDic[file.nativePath] = zip["md5"];
					
					Output.output("读取"+file.nativePath+",md5="+zip["md5"]);
					
					if( file.name == "sensitiveWord.txt" ){//压缩敏感词
						//byte = CAmfUtil.write(String(byte));
						moveConfigFile(file,byte,zip["md5"]);
					}else
						moveFile(file,zip["md5"]);
					
				}else{
					var assetsFiles:Array = file.getDirectoryListing();
					var assetsFile:File;
					for each( assetsFile in assetsFiles ){
						recursiveMakeAssetsVersion(assetsFile,verDic);
						//BuildQueue.getInstance().add(recursiveMakeAssetsVersion,[assetsFile,verDic]);
					}
				}
			}
			if( callback != null )
				callback.call();
		}
		
		/**对assets目录下的内容做版本**/
		private function recursiveMakeAssetsVersion(file:File,verDic:Dictionary,callback:Function=null):void
		{
			if(!checkSkipSys(file, Config.OPT_CFG.cfg_skips) && !checkSkip(file) ){//忽略系统生成的文件
				if( file.isDirectory ){
					if(file.parent.name == "scene" && file.name.match(/^\d*$/)){//地图文件
						recursiveMakeMapVersion(file,verDic);
						//BuildQueue.getInstance().add(recursiveMakeMapVersion,[file,verDic]);
					}/*else if( file.name == "music" ){//音效文件不用打版本 直接移动
						var newNativePath:String = file.nativePath.replace(/\\/g,"/");
						newNativePath = newNativePath.split(Config.PROPERTIES["OUTPUT_DIR"]).join(Config.PROPERTIES["PUB_BASE_RES_PATH"]);
						var newFile:File = new File(newNativePath);
						Output.output(file.nativePath+"复制到"+newFile.nativePath);
						FileUtil.copyTo(file,newFile);
					}*/else{
						var files:Array = file.getDirectoryListing();
						if(file.name == "config")
						{//config目录
							configDataObj = {};
							configDataByte = new ByteArray();
							var configFile:File = new File(file.nativePath+File.separator+"config.xml");
							configObj = CAmfUtil.read(FileUtil.read(configFile), "xml");
							for each(var aFile:File in files)
							{
								if(aFile.name != "config.xml")
								{
									recursiveMakeAssetsVersion(aFile,verDic);
								}
							}
							
							configDataByte = CAmfUtil.write(configDataObj);
							var configInfo:Object = {};
							configInfo["md5"] = MD5.hashBytes(configDataByte).substr(0,8);
							configInfo["name"] = configFile.nativePath;
							verDic[configInfo["name"]] = configInfo["md5"];
							moveConfigFile(configFile,configDataByte,configInfo["md5"]);
							fileNum++;
						}
						for each( var tFile:File in files ){
							if(file.name == "config" && tFile.name == "config.xml")
							{
								continue;
							}
							recursiveMakeAssetsVersion(tFile,verDic);
						}
						/*if(file.name == "config")
						{
							fileNum++;
							configDataByte = CAmfUtil.write(configDataObj);
							FileUtil.write(configDataFile,configDataByte);
						}*/
					}
				}else{//非目录
					var zip:Object = {};
					var byte:ByteArray = FileUtil.read(file);
					zip["md5"] = MD5.hashBytes(byte).substr(0,8);
					zip["name"] = file.nativePath;
					Output.output("读取"+file.nativePath+",md5="+zip["md5"]);
					/*if( file.name == "config.xml" ){
						var obj : Object = CAmfUtil.read(byte, "xml");
						configObj = obj;
						byte = CAmfUtil.write(obj);
						moveConfigFile(file,byte,zip["md5"]);
						
						var newNativePath:String = file.nativePath.replace(/\\/g,"/");
						newNativePath = newNativePath.split(Config.OUT_PUT).join(Config.PUB_BASE_RES_PATH);
						var suffixs:String = newNativePath.substr(newNativePath.lastIndexOf("."));
						var prefix:String = newNativePath.substring(0,newNativePath.lastIndexOf("."));
						newNativePath = prefix + "_"+ zip["md5"] +suffixs;
						configDataFile = new File(newNativePath);
						configDataByte = new ByteArray();
						configDataObj = {};
					}else*/ 
					if( file.parent.nativePath.indexOf("config") > -1){//config目录
						try
						{
							var tdef:Object = {};
							var txml:Object = CAmfUtil.read(byte, "xml");
							var tobj:Object = CAmfUtil.children(txml);
							if( txml.root && txml.root.item != null && txml.root.key != null && String(txml.root.key)!=""){//需要转化为dic
								if( !(tobj is Array) ){
									var arr:Array = new Array();
									//arr.push(tobj.item);
									arr.push(tobj.item);
									tobj = arr;
								}
								var keys:Array = String(txml.root.key).split(",");
								for(var e1:Object in tobj){
									if(e1 == "ignoreWhitespace") continue;
									if(e1 == "key") continue;
									if(tobj[e1] == null) continue;
									//先剔除不存在的key
									for( var i:int=keys.length-1;i>-1;i--){
										var key:* = keys[i];
										if( tobj[e1].hasOwnProperty(key) && tobj[e1][key] == null ){
											tobj[e1][key] = 0;
										}
										if(!tobj[e1].hasOwnProperty(key) ){
											keys.splice(i,1);
										}
									}
									createKeyValue(tobj[e1],keys[0],keys,tdef);
									
									if( tdef["vals"] == null )
										tdef["vals"] = new Array();
									
									tdef["vals"].push(tobj[e1]); 
								}
								tdef["keys"] = keys;
							}else{//保留原始格式的
								tdef = txml;
							}
							byte = CAmfUtil.write(tdef);
							var isConfig : Boolean = false;
							if(configObj && configObj.root && configObj.root.cfg_item)
							{
								for each(var item : Object in configObj.root.cfg_item)
								{
									var simpleName : String = file.name.substr(0, file.name.length-4);
									if(item.name == simpleName) //配置数据文件
									{
										isConfig = true;
										configDataObj[simpleName] = byte;
										break;
									}
								}
							}
							if(!isConfig)
							{
								fileNum++;
								moveConfigFile(file,byte,zip["md5"]);
							}
						}
						catch(err:*)
						{
							//错误
							throw new Error("配置文件 '" + file.nativePath + "' 格式错误！");
						}
					}else{
						var suffix:String = file.name.substr(file.name.lastIndexOf(".") + 1).toLowerCase(); //扩展名
						//if( !(["npc","player","monster","flySkill"].indexOf(file.parent.name)>-1 && suffix == "png")){//这些png用于地图编辑器的，不用打版本
							fileNum++;
							moveFile(file,zip["md5"]);	
						//}
					}
					verDic[zip["name"]] = zip["md5"];
				}
			}
			
			if( callback != null )
				callback.call();
		}
		
		private function createKeyValue(value:Object,fKey:*,keys:Array,ret:Object):void
		{
			var ind:int = keys.indexOf(fKey);
			if( keys.length == (ind+1) ){
				if( ret[value[fKey]] == null )
					ret[value[fKey]] = new Array();
				ret[value[fKey]].push(value);
				return;
			}else{
				if( ret[value[fKey]] == null )
					ret[value[fKey]] = {};
				createKeyValue(value,keys[ind+1],keys,ret[value[fKey]]);
			}
		}
		
		/**创建地图版本**/
		private function recursiveMakeMapVersion(file:File,verDic:Dictionary,callback:Function=null):void
		{
			var files:Array = file.getDirectoryListing();
			var sourcefile:File;
			var newFile:File;
			var md5:String = "";
			var zip:Object = {};
			for each( sourcefile in files ){
				if( !sourcefile.isDirectory && !checkSkipSys(sourcefile, Config.OPT_CFG.cfg_skips) && !checkSkip(file) ){
					var byte:ByteArray = FileUtil.read(sourcefile);
					md5 += MD5.hashBytes(byte).substr(0,4);
				}
			}
			zip["md5"] = md5; 
			zip["name"] = file.nativePath;
			
			for each( sourcefile in files ){
				if( sourcefile.isDirectory && !checkSkipSys(sourcefile, Config.OPT_CFG.cfg_skips) && !checkSkip(file)){
					fileNum++;
					var newNativePath:String = file.nativePath.replace(/\\/g,"/");
					newNativePath = newNativePath.split(Config.OUT_PUT).join(Config.PUB_BASE_RES_PATH)+"_"+md5;
					newFile = new File(newNativePath+File.separator+sourcefile.name);
					Output.output(sourcefile.nativePath+"复制到"+newFile.nativePath);
					FileUtil.copyTo(sourcefile,newFile);
				}
			}
			verDic[zip["name"]] = zip["md5"];
			if( callback!=null )
				callback.call();
		}
		
		/** 单独优化配置文件 */
		public function optimizaConfig(nativeApplication:NativeApplication, currentDirectory:File, exit:Boolean=true):void
		{
			
			var tproject:File = new File(currentDirectory.parent.parent.parent.nativePath);
			
			var tsource:File = new File([tproject.nativePath, Config.OPT_CFG.cfg_source].join(File.separator));
			var toutput:File = new File([tproject.nativePath, Config.OPT_CFG.cfg_output].join(File.separator));
			var tpath:String = toutput.nativePath + File.separator;
			var tf:File;
			
			try
			{
				Output.output("优化配置...");
				verdic = {};
				
				//conf文件生成
				Output.output("======>> conf");
				for each(var tdir:String in Config.OPT_CFG.conf_folder)
				{
					var tmd5:String;
					var tzip:* = {};
					tf = new File(tsource.nativePath + File.separator + tdir.split("/").join(File.separator));
					makeConf(tf, tzip);
					tmd5 = MD5.hash(tzip["___md5___"]).substr(0, 8);
					tf = new File(tf.parent.nativePath.replace(tsource.nativePath, toutput.nativePath) + File.separator + tf.name + ".conf_"+tmd5);
					//保存版本
					verdic[tdir + ".conf"] = tmd5;
					//生成文件
					if(!FileUtil.isExists(tf))
					{
						delete tzip["___md5___"];
						FileUtil.write(tf, CAmfUtil.write(tzip));
					}
				}
				
				//version <<==>> url
				Output.output("======>> resouce");
				tf = new File([tsource.nativePath, "assets"].join(File.separator));
				rootUrl = tsource.url;
				rootPath = tsource.nativePath;
				makeFile(tf, toutput);
				
				//clear <<==>> url
				Output.output("======>> clean");
				tf = new File([toutput.nativePath, "assets"].join(File.separator));
				rootUrl = toutput.url;
				rootPath = toutput.nativePath;
				cleanFile(tf, toutput);
				
				Output.output("======>> patch_l");
				FileUtil.write(tpath+"/client/patch_l.o", CAmfUtil.write(verdic));
				
				Output.output("配置完成！");
				if(exit && nativeApplication) nativeApplication.exit();
			}
			catch(e:*)
			{
				if(exit && nativeApplication)
				{
					Output.output("错误:", e);
					nativeApplication.exit(1);
				}
				else
				{
					throw e;
				}
			}
		}
		
		/** 生成版本 */
		public function optimizaSwf(nativeApplication:NativeApplication, currentDirectory:File, exit:Boolean=true):void
		{
			var troot:File = new File(currentDirectory.parent.nativePath + File.separator + "output");
			var tpath:String = troot.nativePath + File.separator + "client" + File.separator;
			var tf:File;
			
			try
			{
				Output.output("初始版本...");
				tf = new File(tpath+"patch_l.o");
				if(tf.exists)
				{
					verdic = CAmfUtil.read(FileUtil.read(tf));
					tf.deleteFile();
				}
				else
				{
					verdic = {};
				}
				
//				Output.output("======>> swf");
//				tf = new File(troot.nativePath);
//				rootUrl = troot.url;
//				rootPath = troot.nativePath;
//				makeFile(tf, tf, false);
//				
//				tf = new File(troot.nativePath + File.separator + "modules");
//				if(tf.exists)
//				{
//					makeFile(tf, tf, false);
//				}
				
				//生成客户端使用的版本文件
				Output.output("======>> config.json");
				ParseModuleUtil.parse(currentDirectory, onComplete, onError);
				//错误
				function onError():void
				{
					if(exit && nativeApplication) nativeApplication.exit(1);
				};
				//完成
				function onComplete(tmodules:*):void
				{
					//写入文件，使用新的 modules 属性
					var troot:String = currentDirectory.parent.parent.parent.nativePath + File.separator;
					var tfile:File = new File(troot + Config.SCRIPT_CFG.config_file);
					var tconf:* = JSON.decode(FileUtil.read(tfile).toString());
					tconf["modules"] = tmodules;
					//
					Output.output("======>> config.o");
					var tvers:Dictionary = new Dictionary();
					var tfileList:Array = [];
					var tdic:*, tnds:Array, tlen:int, texist:Dictionary=new Dictionary(), i:int;
					
					tconf["patch_l"] = new Dictionary();
					for(var e:String in verdic)
					{
						//已有版本则跳过
						var turl:String = e;
						if(verdic[e] != "无所谓" && texist[turl] == undefined)
						{
							texist[turl] = true;
							tdic = tconf["patch_l"];
							tnds = turl.split("/");
							tlen = tnds.length-1;
							for(i = 0; i < tlen; i++)
							{
								if(tdic[tnds[i]] == null)
								{
									tdic[tnds[i]] = {};
								}
								tdic = tdic[tnds[i]];
							}
							tdic[tnds[tlen]] = verdic[turl];
						}
						//总文件列表
						tfileList.push(e+(verdic[e] != "无所谓"?"_"+verdic[e]:""));
					}
					FileUtil.write(tpath+"config.json", JsonUtil.formatJson(JSON.encode(tconf)));
					FileUtil.write(tpath+"config.o", CAmfUtil.write(tconf));
					FileUtil.write(tpath+"filelist", tfileList.join("\r\n"));
					
					Output.output("版本完成！");
					if(exit && nativeApplication) nativeApplication.exit();
				}
			}
			catch(e:*){
				if(exit && nativeApplication)
				{
					Output.output("错误:", e);
					nativeApplication.exit(1);
				}
				else
				{
					throw e;
				}
			}
		}
		
		/** 总目录 */
		private var verdic:Object;
		private var rootUrl:String;
		private var rootPath:String;
		
		/** 文件处理 */
		private function makeFile(file:File, root:File, includeDir:Boolean=true):Boolean  
		{  
			var text:String = FileUtil.getExtname(file); //扩展名
			var tname:String = file.name.substr(0, file.name.lastIndexOf(".")); //文件名
			
			if(checkSkipSys(file, Config.OPT_CFG.ver_skips))
			{
				//忽略系统生成的文件
				return true;
			}
			else if(file.isDirectory)
			{ 
				//不包含子文件夹则直接退出
				if(!includeDir && file.url != rootUrl) return false;
				//排序，优先处理文件，再处理目录
				var tfiles:Array=file.getDirectoryListing();
				var tlen:int = tfiles.length;
				tfiles.sort(Array.DESCENDING);
				for(var i:int = 0; i < tlen; i++)
				{
					var tf:File = tfiles[i];
					//文件名中带中文
					if(checkSkip(tf)) continue;
					//检查, 忽略系统生成的文件
					if(checkSkipSys(tf, Config.OPT_CFG.ver_skips)) continue;
					//如果不需要继续此目录，则跳过
					if(!makeFile(tf, root, includeDir)) break;
				}
			}
			else
			{
				//是否为目录版本号
				var turl:String = StringUtil.trim((file.url.replace(rootUrl + "/", "")));
				var tskip:Boolean = false;
				//版本跳过文件
				tskip = tskip || Config.OPT_CFG.ver_exclude.indexOf(turl) != -1;
				//版本跳过扩展名
				tskip = tskip || Config.OPT_CFG.ver_ext_skips.indexOf(text) != -1;
				//跳过的目录
				for each(var te1:String in Config.OPT_CFG.ver_dir_skips)
				{
					if(turl.substr(0, te1.length) == te1)
					{
						tskip = true;
						break;
					}
				}
				//真实路径（不带版本号）
				tkey = FileUtil.getPath(file);
				tkey = StringUtil.trim((tkey.replace(rootUrl+"/", "")));
				//此版本已存在
				if(verdic[tkey])
				{
					return true;
				}
				//是否是使用目录版本号
				if(!tskip)
				{
					for each(var te:String in Config.OPT_CFG.ver_dir)
					{
						if(turl.substr(0, te.length) == te)
						{
							//存在
							var t:Array = turl.substr(te.length+1).split("/");
							var turl2:String = t.length > 1 ? te + "/" + t[0] : turl;
							
							var tkey:String = turl2.split("_")[0];
							if(verdic[tkey] == null)
							{
								//从多个文件中生成版本号，只要有一个文件有修改，则版本号会改变
								var tsc:String = rootPath+File.separator+turl2.split("/").join(File.separator);
								var tvp:String = tsc+File.separator+t[0].split("_")[0];
								//目标路径
								var ttar:String = root.nativePath+File.separator+tkey.split("/").join(File.separator);
								
								var tvm:String = "";
								var tvf:File;
								var tvlist:Array = ["_mini.jpg", "_monster.mst", "_server.mpt", "_world.mpt"];
								//Output.output("地图："+ t[0]);
								for each(var tvfp:* in tvlist)
								{
									tvf = new File(tvp+tvfp);
									if(tvf.exists)
									{
										tvm += MD5.hashBytes(FileUtil.read(tvf));
									}
								}
								//md5
								verdic[tkey] = StringUtil.trim(MD5.hash(tvm)).substr(0,8);
								//目录复制
								copyDir(tsc, ttar+"_"+verdic[tkey]);
							}
							//后继文件不用再处理
							return false;
						}
					}
				}
				//目标路径
				var ttarget:String = root.nativePath+File.separator+tkey.split("/").join(File.separator);
				//是否有必要生成版本或优化
				if(tskip && ["json","xml"].indexOf(text) == -1)
				{
					verdic[tkey] = "无所谓";
					FileUtil.copyTo(file, ttarget);
				}
				else
				{
					//读取文件内容
					var tcont:ByteArray = FileUtil.read(file);
					//生成版本对照表
					verdic[tkey] = tskip ? "无所谓" : StringUtil.trim(MD5.hashBytes(tcont)).substr(0, 8);
					if(verdic[tkey] != "无所谓")
					{
						ttarget += "_"+verdic[tkey];
					}
					//保存至目标
					if(!CAmfUtil.isCAmf(tcont) && ["json","xml"].indexOf(text) != -1)
					{
						try
						{
							FileUtil.write(ttarget, CAmfUtil.write(CAmfUtil.read(tcont, text)));
						}
						catch(e:*)
						{
							throw new Error("配置文件 '" + file.url + "' 格式错误！");
						}
					}
					else
					{
						FileUtil.copyTo(file, ttarget);
					}
				}
			}
			//是否继续此目录下的文件
			return true;
		}
		
		/** 目录同步 */
		private function copyDir(file1:*, file2:*):void
		{
			var tf1:File = file1 is File ? file1 : new File(file1);
			var tf2:File = file2 is File ? file2 : new File(file2);
			//目标文件已存在
			if(tf2.exists) return;
			//
			var ttar:String;
			var tfiles:Array=tf1.getDirectoryListing();
			for each(var tf:File in tfiles)
			{
				//目标已存在
				if(!tf.exists) continue;
				//忽略系统生成的文件
				if(checkSkipSys(tf, Config.OPT_CFG.ver_skips)) continue;
				//文件名中带中文，文件大小超限等检测
				if(checkSkip(tf)) continue;
				//目标路径
				ttar = tf.nativePath.replace(tf1.nativePath, tf2.nativePath);
				//子目录拷贝
				if(tf.isDirectory)
				{
					copyDir(tf, ttar);
				}
				else
				{
					FileUtil.copyTo(tf, ttar);
				}
			}
		}
		
		/** 检测是否略过（系统文件）及配置中指定略过的文件 */
		private function checkSkipSys(file:File, list:Vector.<String>):Boolean
		{
			var tname:String;
			if( file.isDirectory )
				tname = file.name;
			else
				tname = file.name.substr(0, file.name.lastIndexOf(".")); //文件名
			
			var text:String = file.name.substr(file.name.lastIndexOf(".") + 1).toLowerCase(); //扩展名
			if(file.nativePath.indexOf(".svn") != -1 
				|| list.indexOf(file.name.toLowerCase()) != -1
				|| list.indexOf(text.toLowerCase()) != -1
				|| list.indexOf(tname.toLowerCase()) != -1){
				//忽略系统生成的文件
				return true;
			}
			//
			return false;
		}
		
		/** 检查略过的（名字中带中文，文件超大小） */
		private function checkSkip(file:File):Boolean
		{
			if(file.exists)
			{
				//文件名中带中文
				if(escape(file.name).split("%u").length > 1) 
				{
					Output.output("文件或文件夹名称中带有中文 ：" + file.name);
					return true;
				}
				//非文件夹
				if(!file.isDirectory)
				{
					var text:String = FileUtil.getExtname(file).toLowerCase(); //扩展名
					//判断文件大小，过大的文件删除并不记录至版本对照表，跳过swf文件
					if(text != "swf" && FileUtil.getSize(file) >= Config.OPT_CFG.file_max_size)
					{
						Output.output("文件超过最大资源大小 ：" + file.name);
						return true;
					}
				}
			}
			return false;
		}
		
		/** 清理过期版本 */
		private function cleanFile(file:File, root:File):void
		{
			//真实路径（不带版本号）
			var tkey:String = FileUtil.getPath(file);
			tkey = StringUtil.trim((tkey.replace(rootUrl+"/", "")));
			//不管理版本或版本相同，则不预处理
			if(verdic[tkey] == "无所谓") return;
			var tver:String = file.name.substr(file.name.lastIndexOf("_")+1);
			if(verdic[tkey] == tver) return;
			
			//目录
			if(file.isDirectory)
			{
				var tfiles:Array=file.getDirectoryListing();
				for each(var tf:File in tfiles)
				{
					cleanFile(tf, root);
				}
				//空目录删除
				if(file.getDirectoryListing().length < 1)
				{
					Output.output("版本清理：" + StringUtil.trim((file.url.replace(rootUrl+"/", ""))));
					file.deleteDirectory(true);
				}
			}
			else
			{
				Output.output("版本清理：" + StringUtil.trim((file.url.replace(rootUrl+"/", ""))));
				file.deleteFile();
			}
		}
		
		/** 生成 conf 文件 */
		private function makeConf(file:File, zip:*):void
		{
			var tbyte:ByteArray;
			var tname:String = file.name.substr(0, file.name.lastIndexOf(".")); //文件名
			var text:String = file.name.substr(file.name.lastIndexOf(".") + 1).toLowerCase(); //扩展名
			if(checkSkipSys(file, Config.OPT_CFG.cfg_skips)){
				//忽略系统生成的文件
				return;
			}
			
			if(file.isDirectory){ 
				var tfiles:Array=file.getDirectoryListing();
				var tfile:File;
				//排序，保持顺序
				tfiles.sort();
				for(var i:int= 0; i < tfiles.length; i++){
					tfile = tfiles[i];
					tname = tfile.name.substr(0, tfile.name.lastIndexOf(".")); //文件名
					text = tfile.name.substr(tfile.name.lastIndexOf(".") + 1).toLowerCase(); //扩展名
					
					if(checkSkipSys(file, Config.OPT_CFG.cfg_skips)){
						//忽略系统生成的文件
						continue;
					}
					else{
						makeConf(tfile, zip);
					}
				}
			}
			else {
				tbyte = FileUtil.read(file);
				if(zip["___md5___"] == null){
					zip["___md5___"] ="";
				}
				zip["___md5___"] += MD5.hashBytes(tbyte);
				
				if(text == "xml"){
					//XML文件
					try
					{
						var tdef:Object = {};
						var txml:Object = CAmfUtil.read(tbyte, "xml")
						var tobj:Object = CAmfUtil.children(txml);
						for(var e1:Object in tobj){
							if(e1 == "ignoreWhitespace") continue;
							if(tobj[e1] == null) continue;
							if(!tobj[e1].hasOwnProperty("id") || tobj[e1].id == null){
								tdef = txml;
								break;
							}else{
								tdef[tobj[e1].id] = tobj[e1];
							}
						}
						//
						tbyte = CAmfUtil.write(tdef);
					}
					catch(err:*)
					{
						//错误
						throw new Error("配置文件 '" + file.url + "' 格式错误！");
					}
				}
				else if(text == "json"){
					//JSON文件
					try
					{
						if(!CAmfUtil.isCAmf(tbyte))
						{
							tbyte = CAmfUtil.write(CAmfUtil.read(tbyte));
						}
					}
					catch(err:*)
					{
						//错误
						throw new Error("配置文件 '" + file.url + "' 格式错误！");
					}
				}
				//保存
				zip[file.name] = tbyte;
			}
		}
	}
}
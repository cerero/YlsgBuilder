package build
{
	import com.adobe.serialization.json.JSON;
	
	import data.Config;
	
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	
	import utils.FileUtil;
	import utils.JsonUtil;
	import utils.Output;
	import utils.ParseModuleUtil;

	public class GenerateScript
	{
		/** 当前目录 */
		private var currentDirectory:File;
		/** 项目目录 */
		private var projectFile:File;
		/** 本地应用程序 */
		private var nativeApplication:NativeApplication;
		/** 文件分割数量 */
		private var fileNum:int=10;
		
		public function buildScript(nativeApplication:NativeApplication, currentDirectory:File, fileNum:uint=10):void
		{
			this.currentDirectory = currentDirectory;
			this.nativeApplication = nativeApplication;
			this.fileNum = Math.min(200, fileNum);
			
			Output.output("开始生成模块编译脚本...");
			Output.output("当前目录: " + currentDirectory.nativePath);
			try{
				projectFile = currentDirectory.parent.parent.parent;
				Output.output("项目根目录: " + projectFile.nativePath);
				Output.output("检查目录文件...");
				ParseModuleUtil.parse(currentDirectory, onComplete, onError);
			}
			catch(e:*){
				Output.output("错误:", e);
				if(nativeApplication) nativeApplication.exit(1);
			}
		}
		
		/** 分析失败 */
		private function onError():void
		{
			if(nativeApplication) nativeApplication.exit(1);
		}
		
		/** 分析模块信息完成 */
		private function onComplete(tmodules:*):void
		{
			Output.output("生成编译脚本...");
			genCompilerScript(tmodules, true);
			genCompilerScript(tmodules, false);
			Output.output("顺利完成!!!");
			if(nativeApplication) nativeApplication.exit();
		}
		
		/** 生成编译脚本 */
		private function genCompilerScript(modulesDic:Object, isosx:Boolean):void
		{
			//生成编译脚本
			var tend:String = isosx ? "\n" : "\r\n";
			var turl:String = projectFile.nativePath + File.separator + Config.SCRIPT_CFG.project;
			var tclz:String = FileUtil.read(turl + "/compiler/tools/TemplateClass").toString();
			var toutput2:Array = [];
			
			for(var t1:* in modulesDic){
				if(Config.SCRIPT_CFG.exclude.indexOf(t1) != -1){ continue;}
				//脚本
				for each(var t2:* in modulesDic[t1]){
					var ts:String = t2.split(".").join("/").split("::").join("/");
					for each(var e:* in Config.SCRIPT_CFG.source){
						var tf:File = new File(turl + File.separator + e + File.separator +  ts + ".as");
						if(tf.exists){
							//单项编译
							var tname:String = ts.substr(ts.lastIndexOf("/") + 1);
							toutput2[toutput2.length] = 
								(
									//编译命令
									//"MXMLC=/usr/bin/flex_sdk_4.6.0/bin/mxmlc \n $MXMLC ../tmp_as/" + tname + ".as -external-library-path+=../tmp/CommonProgressBar.swc -output ../output/client/modules/" + tname + 
									"mxmlc ../tmp_as/" + tname + ".as -external-library-path+=../tmp/CommonProgressBar.swc -output ../output/client/modules/" + tname +
									".swf -load-config " + Config.SCRIPT_CFG.load_config + 
									" " + Config.SCRIPT_CFG.load_externs
								) +
								(
									//重定向
									(isosx ? " >/dev/null 2>&1" : "  > nul") + tend 
								);
							
							//根据模板生成具体的可编译类文件
							var tclass:String = tclz.split("{import}").join(t2.split("::").join("."));
							tclass = tclass.split("{name}").join(tname);
							FileUtil.write(turl+"/compiler/tmp_as/" + tname + ".as", tclass);
							break;
						}
					}
				}
			}
			
			//生成文件内容
			var tprefix:String = "";
			var text:String = ".bat";
			//苹果系统
			if(isosx){
				text = ".sh";
				tprefix = 	"#!/bin/sh" + tend  +
					tend  +
					"# module.sh" + tend  +
					"# " + tend  +
					"#" + tend  +
					"# Created by Stowen on 11-6-18." + tend  +
					"# Copyright 2011 __MyCompanyName__. All rights reserved." + tend  +
					"#!/bin/sh" + tend + tend;
			}
			
			//生成文件内容列表，分配
			var tnum:int = Math.min(fileNum, toutput2.length);//Math.ceil(toutput2.length / fileNum);
			var tlist:Vector.<Array> = new Vector.<Array>(tnum);
			var tidx:int = 0;
			while(toutput2.length > 0)
			{
				if(tlist[tidx] == null)
				{
					tlist[tidx] = [];
				}
				tlist[tidx].push(toutput2.shift());
				tidx = (tidx+1) % tnum;
			}
			
			//写入至文件
			tidx = 0;
			for(var i:int = 0; i < tlist.length; i++)
			{
				tidx += tlist[i].length;
				FileUtil.write( turl + File.separator + 
								"compiler/build" + (isosx ? "_osx" : "_win32") + 
								"/modules_" + (i+1) + text, 
								
								//编译脚本
								tprefix + tlist[i].join("")+(isosx?"":"@pause")
				);
			}
		}
	}
}
package data
{
	import com.adobe.utils.StringUtil;
	
	import flash.filesystem.File;
	
	import utils.CAmfUtil;
	import utils.FileUtil;

	public class Config
	{
		public static var PUB_BASE_RES_PATH:String;
		public static var PUB_GAME_RES_PATH:String;
		public static var OUT_PUT:String;
		/** 加密功能配置 */
		public static const ENCRY_CFG:EncryConfig = new EncryConfig();
		
		/** 优化功能配置 */
		public static const OPT_CFG:OptConfig = new OptConfig();
		
		/** 生成脚本功能配置 */
		public static const SCRIPT_CFG:ScriptConfig = new ScriptConfig();
		
		/** 加载配置文件 */
		public static function load(file:File):void
		{
			if(file.isDirectory){
				file = new File(file.nativePath + File.separator + "config.xml");
			}
			//
			var tobj:Object = CAmfUtil.read(FileUtil.read(file), "xml")["root"];
			PUB_BASE_RES_PATH = StringUtil.trim(tobj["publish_base_res_path"]);
			PUB_GAME_RES_PATH = StringUtil.trim(tobj["publish_game_res_path"]);
			
			transArrayToVector(tobj["encry"]["files"]["item"], ENCRY_CFG.files);
			transArrayToVector(tobj["encry"]["folder"]["item"], ENCRY_CFG.folder);
			//optimiza
			transArrayToVector(tobj["optimiza"]["conf"]["item"], OPT_CFG.conf_folder);
			transArrayToVector(tobj["optimiza"]["version"]["exclude"]["item"], OPT_CFG.ver_exclude);
			transArrayToVector(tobj["optimiza"]["version"]["ver_skips"]["item"], OPT_CFG.ver_skips);
			transArrayToVector(tobj["optimiza"]["version"]["ver_ext_skips"]["item"], OPT_CFG.ver_ext_skips);
			transArrayToVector(tobj["optimiza"]["version"]["ver_dir"]["item"], OPT_CFG.ver_dir);
			transArrayToVector(tobj["optimiza"]["version"]["ver_dir_skips"]["item"], OPT_CFG.ver_dir_skips);
			transArrayToVector(tobj["optimiza"]["cfg_skips"]["item"], OPT_CFG.cfg_skips);
			OPT_CFG.file_max_size = tobj["optimiza"]["file_max_size"];
			OPT_CFG.cfg_source = (tobj["optimiza"]["source"] as String).split("/").join(File.separator);
			OPT_CFG.cfg_output = (tobj["optimiza"]["output"] as String).split("/").join(File.separator);
			//script
			transArrayToVector(tobj["script"]["ref_swf"]["item"], SCRIPT_CFG.ref_swf);
			transArrayToVector(tobj["script"]["base_swf"]["item"], SCRIPT_CFG.base_swf);
			transArrayToVector(tobj["script"]["modules"]["item"], SCRIPT_CFG.modules);
			transArrayToVector(tobj["script"]["script_exclude"]["item"], SCRIPT_CFG.exclude);
			transArrayToVector(tobj["script"]["project"]["source"]["item"], SCRIPT_CFG.source);
			SCRIPT_CFG.project = transArrayToString(tobj["script"]["project"]["name"]);
			SCRIPT_CFG.config_file = transArrayToString(tobj["script"]["config_file"]);
			SCRIPT_CFG.load_config = transArrayToString(tobj["script"]["config"]);
			SCRIPT_CFG.load_externs = "";
			
			var arExtern:Array = [].concat(tobj["script"]["load_externs"]["item"]);
			for each(var tparam:String in arExtern){
				SCRIPT_CFG.load_externs += " -load-externs" + (SCRIPT_CFG.load_externs==""?"":"+") + "=" + tparam;
			}
		}
		
		public static function constructPath(currentDirectory:File):void
		{
			Config.OUT_PUT = currentDirectory.parent.parent.parent.parent.nativePath+File.separator+"ylsg_output"
			Config.OUT_PUT = Config.OUT_PUT.replace(/\\/g,"/");
			
			Config.PUB_BASE_RES_PATH = currentDirectory.parent.parent.parent.parent.nativePath+File.separator+Config.PUB_BASE_RES_PATH;
			Config.PUB_BASE_RES_PATH = Config.PUB_BASE_RES_PATH.replace(/\\/g,"/");
			
			Config.PUB_GAME_RES_PATH = currentDirectory.parent.parent.parent.parent.nativePath+File.separator+Config.PUB_GAME_RES_PATH;
			Config.PUB_GAME_RES_PATH = Config.PUB_GAME_RES_PATH.replace(/\\/g,"/");
		}
		
		/** 转换数组为Vector */
		private static function transArrayToVector(array:*, vect:*):void
		{
			if(!(array is Array)){
				array = [array];
			}
			var tlen:int = array.length;
			for(var i:int = 0; i < tlen; i+=1){
				vect[i] = array[i];
			}
		}
		
		/** 转换数组为String */
		private static function transArrayToString(array:*, sep:String=""):String
		{
			if(!(array is Array)){
				array = [array];
			}
			
			return array.join(sep);
		}
	}
}
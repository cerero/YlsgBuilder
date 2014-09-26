package data
{
	/** 生成脚本功能配置 */
	public class ScriptConfig
	{
		/** 需加载分析的swf的前提库文件列表 */
		public var ref_swf:Vector.<String> = new Vector.<String>();
		
		/** 需加载分析的swf文件列表 */
		public var base_swf:Vector.<String> = new Vector.<String>();
		
		/** 模块列表 */
		public var modules:Vector.<String> = new Vector.<String>();
		
		/** 生成脚本不包括的模块 */
		public var exclude:Vector.<String> = new Vector.<String>();
		
		/** 编译的项目名称 */
		public var project:String;
		
		/** 源码目录列表 */
		public var source:Vector.<String> = new Vector.<String>();
		
		/** config 文件路径 */
		public var config_file:String;
		
		/** 生成编译脚本 load-config 参数 */
		public var load_config:String;
		
		/** 生成编译脚本 load-externs 参数 */
		public var load_externs:String;
	}
}
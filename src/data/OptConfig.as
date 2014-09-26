package data
{
	/** 优化功能配置 */
	public class OptConfig
	{
		/** 生成conf目录列表 */
		public var conf_folder:Vector.<String> = new Vector.<String>();
		
		/** 生成版本信息，跳过文件列表 */
		public var ver_exclude:Vector.<String> = new Vector.<String>();
		
		/** 生成版本信息，忽略文件名列表 */
		public var ver_skips:Vector.<String> = new Vector.<String>();
		
		/** 生成 patch_l 属性时，忽略的扩展名列表 */
		public var ver_ext_skips:Vector.<String> = new Vector.<String>();
		
		/** 生成 patch_l 属性时，忽略的目录列表 */
		public var ver_dir_skips:Vector.<String> = new Vector.<String>();
		
		/** 整个目录使用一个版本的父目录列表（此目录的子目录以目录为版本管理最小单位）*/
		public var ver_dir:Vector.<String> = new Vector.<String>();
		
		/** 优化配置文件，忽略文件名列表 */
		public var cfg_skips:Vector.<String> = new Vector.<String>();
		
		/** 跳过的文件大小，默认6M */
		public var file_max_size:uint = 6 * 1024 * 1024;
		
		/** 配置文件源目录 */
		public var cfg_source:String;
		
		/** 配置文件目标目录 */
		public var cfg_output:String;
	}
}
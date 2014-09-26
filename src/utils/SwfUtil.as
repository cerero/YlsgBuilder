package utils
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class SwfUtil
	{
		/** logo byteArray */
		private static var logoByte:ByteArray;
		
		/** 加密文件 **/
		public static function encrytSwf(files:Array, ret:ByteArray=null, log:Boolean=false):void
		{
			if(logoByte == null){
				logoByte = FileUtil.read("app:/logo.swf");
			}
			
			for each(var tfile:File in files){
				
				if(tfile.isDirectory){
					continue;
				}
				//读取
				var tbytes:ByteArray = FileUtil.read(tfile, 0, logoByte.length);
				if(tbytes != null && XmlUtil.compareObject(tbytes, logoByte)){
					//判断是否已加密
					if(log) Output.output("======<< " + tfile.name + "\t\t\t\t[ENC]");
					continue;
				}
				//非加密
				tbytes = FileUtil.read(tfile);
				//加密
				tbytes = encrypt_impl(tbytes);
				//写入加密后的内容
				if(ret == null) 
					FileUtil.write(tfile, [logoByte, tbytes]);
				else
					ret.writeBytes(tbytes);
			}
		}
		
		/** 加密顺序数组 */
		private static const POS_ARR:Array = [8,10,6,1,4,9,11,3,2,0,13,7,12,5,14];
		
		/** 加密SWF文件 */
		private static function encrypt_impl(swf:ByteArray):ByteArray
		{
			var tret:ByteArray = new ByteArray();
			
			var block_num:uint = POS_ARR.length;
			var blocks:int = Math.ceil(swf.length / block_num);
			for (var i:int = 0; i < block_num-1; i++) {
				tret.writeBytes(swf, POS_ARR[i]*blocks, blocks);
			}
			
			//write block
			var tpos:int = (block_num - 1) * blocks;
			tret.writeBytes(swf, tpos, swf.length-tpos);
			
			//
			return tret;
		}
		
		/** swf文件解密 */
		public static function decryptSwf(tfile:File):ByteArray
		{
			if(logoByte == null){
				logoByte = FileUtil.read("app:/logo.swf");
			}
			const block_num:int = POS_ARR.length; 		//加密块数量
			const offset_head:int = logoByte.length; 	//加密块偏移字节数
			
			//读取
			var tbytes:ByteArray = FileUtil.read(tfile, 0, offset_head);
			if(!XmlUtil.compareObject(tbytes, logoByte)){
				//判断是否已加密
				return FileUtil.read(tfile);
			}
			
			var byte:ByteArray = FileUtil.read(tfile);
			var tsize:int = byte.length;
			var tbyte:ByteArray = new ByteArray();
			var blocks:int = Math.ceil((tsize - offset_head) / block_num);
			
			//对字节流排序
			for (var i:int = 0; i < block_num - 1; i++) {
				var j:int = POS_ARR.indexOf(i);
				byte.position = offset_head + j * blocks;
				byte.readBytes(tbyte, tbyte.position, blocks);
				tbyte.position = tbyte.length;
			}
			
			//增加最后剩余字节
			var tlen:int = (block_num - 1) * blocks;
			byte.position = offset_head + tlen;
			byte.readBytes(tbyte, tbyte.position, tsize - offset_head - tlen);
			
			return tbyte;
		}
	}
}
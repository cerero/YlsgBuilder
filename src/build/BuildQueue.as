package build
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class BuildQueue
	{
		private var queue:Vector.<QueueInfo>;
		private var running:Boolean;
		private var shape:Shape;
		private var lastExecTime:uint;
		private var totalTime:uint;
		private var num:uint;
		public function BuildQueue(param:SingletonEnforcer)
		{
			queue = new Vector.<QueueInfo>();
			running = false;
			totalTime = num = 0;
		}
		
		private static var instance:BuildQueue;
		public static function getInstance():BuildQueue
		{
			if( instance == null )
				instance = new BuildQueue(new SingletonEnforcer());
			
			return instance;
		}
		
		public var completeFun:Function;
		public static function setQueueFinishCallback(fun:Function):void
		{
			getInstance().completeFun = fun;
		}
		
		public function add(execFun:Function,param:Array):void
		{
			num++;
			queue.push(new QueueInfo(execFun,param));
			checkFrameScript();
		}
		
		private function checkFrameScript():void
		{
			if( running )
				return;
			
			if( shape == null)
				shape = new Shape(); 
			
			if( queue.length>0 ){
				if( !shape.hasEventListener(Event.ENTER_FRAME) ){
					lastExecTime = getTimer();
					shape.addEventListener(Event.ENTER_FRAME,onEnterFrame);
				}
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			if( running || queue.length == 0)
				return;
			
			running = true;
			doExec();
		}
		
		private function doExec():void
		{
			if( queue.length>0 ){
				var queueInfo:QueueInfo = queue.shift();
				queueInfo.param.push(next);
				lastExecTime = getTimer();
				queueInfo.execFun.apply(null,queueInfo.param);
			}
		}
		
		private function next():void
		{
			running = false;
			var curTime:uint = getTimer();
			if( queue.length == 0 ){
				trace("结束打版本... 文件数:"+num+",耗时："+totalTime+"毫秒");
				completeFun();
				return;
			}
			var dt:uint = curTime - lastExecTime;
			lastExecTime = curTime;
			totalTime+=dt;
			//trace("完成，花费"+dt+"毫秒");
			if( dt<(1000/30-10) )
				doExec();
				
		}
	}
}

class QueueInfo{
	public var execFun:Function;
	public var param:Array;
	public function QueueInfo(execFun:Function,param:Array){
		this.execFun = execFun;
		this.param = param;
	}
}

class SingletonEnforcer{}
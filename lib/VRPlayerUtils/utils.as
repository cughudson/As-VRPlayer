/**
* 
* @author Hudson
* TimeStamp:2016-9-18 9:59
* 该模块当前仅包含了时间格式转换，以及两点间的距离计算等两个功能模块
* 
*/
package VRPlayerUtils 
{
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.*;
	public class utils 
	{
		private static var hour:Number;
		private static var minutes:Number;
		private static var second:Number;
		private static var str:String;
		
		public function utils() 
		{
			//构造函数为空
		}
		//将以秒为单位的时长转化成如下格式：0:00:00
		public static function timeFormat(time:Number):String
		{
			if(typeof time != "number"){
				throw "TypeError:Input is valid";
			}
			var aStr:Array = [];
			hour = Number(String(time / 3600).split(".")[0]);
			minutes = Number(String(time / 60).split(".")[0]-hour * 60);
			second =  Number(String(time).split(".")[0] - hour * 3600 - minutes * 60);
			aStr.push(hour == 0? "00":hour < 10?("0" + hour) : hour);
			aStr.push(minutes == 0 ? "00" : minutes < 10 ? ("0" + minutes) : minutes);
			aStr.push(second == 0 ? "00" : second < 10 ? ("0" + second) : second);
			return aStr.join(".");
		}
		//计算两点之间的距离
		public static function getDistance(point1:Point, point2:Point):Number
		{	
			return Math.sqrt(Math.pow((point1.x - point2.x),2) + Math.pow((point1.y - point2.y),2));
		}
	}

}

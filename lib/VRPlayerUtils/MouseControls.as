package VRPlayerUtils 
{
	/**
	 * ...
	 * @author Hudson
	 * 统一采用弧度来进行计算；
	 * 设计成一个静态类，
	 */
	 import flash.display.*;
	 import flash.events.*;
	 import flash.ui.*;
	 import flash.utils.*;
	 public class MouseControls
	 {	
		 //实时的旋转角度
		 //rotateX,rotateY,zoomDistance;之间要进行参数共享；
		 public static var rotateX:Number = 0;
		 public static var rotateY:Number = 0;
		 private static var endRotateX:Number = 0;
		 private static var endRotateY:Number = 0;
		 private static var lastMousePosX:Number = 0;
		 private static var lastMousePosY:Number = 0;
		 private static var currentMousePosX:Number = 0;
		 private static var currentMousePosY:Number =0;
		 public static var zoomDistance:Number = 0;
		 private static var delta:Number = 0;
		 public static var stages:Stage;
		 private static var lbtndown_t:Boolean = false;
		 private static var bRotateRunning:Boolean = false;
		 private static var runningId:Number = 0;
		 private static var ctrlPress:Boolean = false;
		 private static var altPress:Boolean = false;
		 private static var mouseWheelRate:Number;
		 private static var flag:Number;
		/**
		 * 构造函数
		 */
		 public function MouseControls()
		 {
			 //empty
		 }
		 /**
		  * 鼠标滚轮发生滚动的时候，触发该函数，该函数用于控制缩放
		  * @param	event
		  */
		 public static function onMouseWheels(event:MouseEvent):void
		 {
			 event.stopPropagation();
			 delta = event.delta * 0.4;
			 if(zoomDistance >= 15) delta > 0?zoomDistance:zoomDistance += delta;
			 else if(zoomDistance <= -20) delta < 0?zoomDistance:zoomDistance += delta;
			 else if (zoomDistance > -20 && zoomDistance < 20) zoomDistance += delta;
			 trace(zoomDistance);
		 }
		 /**
		  * 鼠标按下的时候，触发该函数
		  * @param	event
		  */
		 public static function onMouseDowns(event:MouseEvent):void
		 {
			 event.stopPropagation();
			 lbtndown_t = true;
			 lastMousePosX = event.stageX ;
			 lastMousePosY = event.stageY ;			
			 if(bRotateRunning){
				 rotateX = 0;
				 rotateY = 0;
				 bRotateRunning = false;
				 clearInterval(runningId);
			 }
		 }
		 /**
		  * 鼠标松开的时候，触发该函数；
		  * @param	event
		  */
		 public static function onMouseUps(event:MouseEvent):void
		 {	
			 Mouse.cursor = MouseCursor.AUTO;
			 event.stopPropagation();
			 endRotateX = rotateX;
			 endRotateY = rotateY;	
			 runningId = setInterval(continueRotate, 30);
			 lbtndown_t = false;
		 }
		 /**
		  * 键盘按键按下时触发该函数；
		  * @param	event
		  */
		 public static function keydowns(event:KeyboardEvent):void
		 {
			 ctrlPress = event.ctrlKey;
			 altPress = event.altKey;
		 }
		 /**
		  * 松开键盘按键时，触发该函数；
		  * @param	event
		  */
		 public static function keyups(event:KeyboardEvent):void
		 {
			 ctrlPress = false;
			 altPress = false;
		 }
		 /**
		  * 缓动函数
		  */
		 public static function continueRotate():void
		 {
			 flag = Math.abs(endRotateX) >= Math.abs(endRotateY)? Math.abs(endRotateX):Math.abs(endRotateY);
			 if (flag >= 0.2){
				 endRotateX -= endRotateX/2;
				 endRotateY -= endRotateY/2;
				 rotateX = endRotateX;
				 rotateY = endRotateY;
				 bRotateRunning = true;
			 }else{
				 rotateX = 0;
				 rotateY = 0;
				 bRotateRunning = false;
				 clearInterval(runningId);
			 }
		 }	
		 /**
		  * 鼠标离开时调用该函数
		  * @param	event
		  */
		 public static function onMouseLeaves(event:MouseEvent):void
		 {
			 event.stopPropagation();
			 lbtndown_t = false;
			 if(bRotateRunning){
				 rotateX = 0;
				 rotateY = 0;	
			 }
		 }
		 /**
		  * 鼠标移动时调用该函数
		  * @param	event
		  */
		 public static function onMouseMoves(event:MouseEvent):void
		{	
			if (lbtndown_t) {
				Mouse.cursor = MouseCursor.HAND
				currentMousePosX = event.stageX ;
				currentMousePosY = event.stageY ; 
				var tempRotateX:Number = currentMousePosX - lastMousePosX;
				var tempRotateY:Number = currentMousePosY - lastMousePosY;
				lastMousePosX = currentMousePosX;
				lastMousePosY = currentMousePosY;
				if(ctrlPress){
					rotateY = tempRotateY ;
				}else if(altPress){
					rotateX = tempRotateX ;
				}else{
					rotateX = tempRotateX ;
					rotateY = tempRotateY ;
				}
			  
			}
		}	
	 }
}


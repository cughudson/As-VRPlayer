package VRPlayerUtils 
{
	/**
	 * 该模块基本上用不到，因为大部分移动端浏览器都不支持flash,该模块与MouseControls基本类似
	 * ...
	 * @author Hudson
	 */
	import VRPlayerUtils.MouseControls;
	import VRPlayerUtils.utils;
	import flash.events.TouchEvent;
	import flash.events.GesturePhase;
	import flash.events.GestureEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.display.Sprite;
	import flash.utils.*;
	public class TouchControls extends Sprite
	{
		public static var zoomDistance:Number = 0 ;
		public static var rotateX:Number = 0 ;
		public static var rotateY:Number = 0 ;		
		private static var endRotateX:Number = 0;
		private static var endRotateY:Number = 0;
		private static var lastTouchPosX:Number = 0;
		private static var lastTouchPosY:Number = 0;
		private static var currentTouchPosX:Number = 0;
		private static var currentTouchPosY:Number = 0; 
		private static var isRotateRunning:Boolean = false;
		private static var tempRotateX:Number = 0;
		private static var tempRotateY:Number = 0;
		private static var intervalId:Number = 0;
		
		private static var delta:Number = 0;
		
		public function TouchControls() 
		{
			zoomDistance = MouseControls.zoomDistance;
			rotateX = MouseControls.rotateX;
			rotateY = MouseControls.rotateY;
		}
		public static function onTouchStart(event:TouchEvent):void
		{
			lastTouchPosX = event.stageX;
			lastTouchPosY = event.stageY;
			if(isRotateRunning){
				rotateX = 0;
				rotateY = 0;
				isRotateRunning = false;
				clearInterval(intervalId);
			}
		}
		public static function onTouchMove(event:TouchEvent):void
		{
			event.preventDefault();
			currentTouchPosX = event.stageX ;
			currentTouchPosY = event.stageY ; 
			tempRotateX = currentTouchPosX - lastTouchPosX;
			tempRotateY = currentTouchPosY - lastTouchPosY;
			lastTouchPosX = currentTouchPosX;
			lastTouchPosY = currentTouchPosY;
			
			rotateX = tempRotateX ;
			rotateY = tempRotateY ;
		}
		public static function onTouchEnd(event:TouchEvent):void
		{	
			event.stopPropagation();
			endRotateX = rotateX;
			endRotateY = rotateY;	
			intervalId = setInterval(continueRotate, 30);
		 }
		public static function onMultitouch(event:TransformGestureEvent):void
		 {
			rotateX = 0;
			rotateY = 0;
			delta = event.scaleX > event.scaleY ? event.scaleX:event.scaleY ;			
			if(zoomDistance >= 15) delta > 0?zoomDistance:zoomDistance += delta;
			else if(zoomDistance <= -20) delta < 0?zoomDistance:zoomDistance += delta;
			else if (zoomDistance > -20 && zoomDistance < 20) zoomDistance += delta;
		 }
		public static function continueRotate():void
		{
			var flag:Number  = Math.abs(endRotateX) >= Math.abs(endRotateY)? Math.abs(endRotateX):Math.abs(endRotateY);
			if (flag >= 0.3){
				endRotateX -= endRotateX/10;
				endRotateY -= endRotateY/10;
				rotateX = endRotateX;
				rotateY = endRotateY;
				isRotateRunning = true;
			}else{
				rotateX = 0;
				rotateY = 0;
				isRotateRunning = false;
				clearInterval(intervalId);
			 }
		}
	}

}
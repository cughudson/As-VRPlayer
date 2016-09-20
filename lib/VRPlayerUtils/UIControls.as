package VRPlayerUtils 
{
   /**
	* 
	* @author Hudson
	* TimeStamp:2016-9-18 10:04
	* 用于控制视频UI及交互效果
	* 
	*/
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import VRPlayerUtils.MyVideo;
	import VRPlayerUtils.MouseControls;
	import flash.utils.*;
	import flash.media.SoundTransform;
	import mx.core.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.external.*;
	public class UIControls extends Sprite
	{
		
		public var isFullScreen:Boolean  = false;
		public var isDbScreen:Boolean  = false ;
		public var timeFormat:Number = 0;
		private var toolbarVisible:Boolean = true;

		private var toolbar:Object;
		private var toolbarHeight:Number;
		private var toolbarBottom:Number = 0;
		private var animateRuning:Boolean = false;
		public var progressWidth:Number = 0;

		private var videoPlayer:MyVideo;
		private var myStage:Stage;
		public static var bufferingLenRatio:Number;
		public static var progressLenRatio:Number;
		public var target:Object;
		public var position:Number;
		public var mousemoveID:Number;

		public var documentMouseOutEvt:MouseEvent = new MouseEvent("document:mosueout");
		public var movestopEvt:MouseEvent = new MouseEvent("mouse:move:stop");
		public var configs:Object = {sdbscreen:false, isfullscreen:false};

		[Embed(source = "../../assert/icon/sound.png")]
		[Bindable]
		private var sound:Class;
		/**
		 * 
		 * @param	configs 配置UI界面
		 * @param	videoMat 
		 * @param	stage
		 */
		public function UIControls(configs:Object,video:MyVideo,stage:Stage) 
		{
			isDbScreen = configs.isdbscreen || isDbScreen;
			isFullScreen = configs.isfullscreen || isFullScreen;		
			videoPlayer = video;
			myStage = stage;

			progressWidth = myStage.stageWidth - 350;
			initUI();
			initUIEvent();
		}
		public function initUIEvent():void
		{
			myStage.addEventListener(Event.ENTER_FRAME, updateUI);			
			myStage.addEventListener(Event.RESIZE, updateUI);
			myStage.addEventListener(MouseEvent.MOUSE_MOVE, mousemove);
			FlexGlobals.topLevelApplication.volumeslider.addEventListener("change", soundControls);
			FlexGlobals.topLevelApplication.progressInstance.addEventListener(MouseEvent.CLICK, playForwardControls);
			
		}
		public function initUI():void
		{
			//控制鼠标移入/移出鼠标形状
			//控制鼠标与界面交互时鼠标的形状
			FlexGlobals.topLevelApplication.playbtn.addEventListener(MouseEvent.MOUSE_OVER, MouseOverApperent);
			FlexGlobals.topLevelApplication.playbtn.addEventListener(MouseEvent.MOUSE_OUT, MouseOverApperent);
			
			FlexGlobals.topLevelApplication.soundbtn.addEventListener(MouseEvent.MOUSE_OVER, MouseOverApperent);
			FlexGlobals.topLevelApplication.soundbtn.addEventListener(MouseEvent.MOUSE_OUT,MouseOutApperent);
			//单双屏控制按钮；
			FlexGlobals.topLevelApplication.dbscreen.addEventListener(MouseEvent.MOUSE_OVER, MouseOverApperent);
			FlexGlobals.topLevelApplication.dbscreen.addEventListener(MouseEvent.MOUSE_OUT,MouseOutApperent);
			//全屏控制按钮；
			FlexGlobals.topLevelApplication.fullscreen.addEventListener(MouseEvent.MOUSE_OVER, MouseOverApperent);
			FlexGlobals.topLevelApplication.fullscreen.addEventListener(MouseEvent.MOUSE_OUT,MouseOutApperent);
			//控件栏
			FlexGlobals.topLevelApplication.controlbarContainer.addEventListener(MouseEvent.MOUSE_DOWN, MouseDownApperent);
			FlexGlobals.topLevelApplication.controlbarContainer.addEventListener(MouseEvent.MOUSE_UP, MouseUpApperent);
			//时间显示控件
			FlexGlobals.topLevelApplication.time.addEventListener(MouseEvent.MOUSE_OVER, MouseOverApperent);
			FlexGlobals.topLevelApplication.time.addEventListener(MouseEvent.MOUSE_OUT, MouseOverApperent);	
			//Logo显示
			FlexGlobals.topLevelApplication.logo.addEventListener(MouseEvent.MOUSE_OVER, MouseDownApperent);
			FlexGlobals.topLevelApplication.logo.addEventListener(MouseEvent.MOUSE_OUT, MouseUpApperent);
			//code hacks
			FlexGlobals.topLevelApplication.progressInstance.progressStage = 0;
			FlexGlobals.topLevelApplication.progressInstance.bufferingProgressStage = 0;		
					
		}
		/**
		 * 当鼠标在200ms之内没有移动时，就分发停止移动事件
		 * @param	event
		 */
		public function mousemove(event:MouseEvent):void
		{
			if (mousemoveID){
				clearTimeout(mousemoveID)
			}
			mousemoveID = setTimeout(function(){
				myStage.dispatchEvent(movestopEvt);
			}, 200);
		}
		/**
		 * 当鼠标移出swf object的时候分发鼠标移出swf object事件，该函数需要与js进行通讯才能够（正确）触发；
		 */
		public function triggerDocumentMouseOut():void
		{
			myStage.dispatchEvent(documentMouseOutEvt);
		}
		/**
		 * 实时更新UI界面
		 * @param	event
		 */
		public function updateUI(event:Event):void
		{
			onStartPlayVideo();
			progressWidth = myStage.stageWidth - 350;
			FlexGlobals.topLevelApplication.progressInstance.progressStage = progressLenRatio * progressWidth;
			FlexGlobals.topLevelApplication.progressInstance.bufferingProgressStage = bufferingLenRatio * progressWidth;
			reCalculatePlayForward();
			//更新UI的显示格式
			switch (timeFormat) 
			{
				//倒计时；
				case 0:
					FlexGlobals.topLevelApplication.time.text = utils.timeFormat(MyVideo.duration - MyVideo.videoStream.time);
					break;
				case 1:
					FlexGlobals.topLevelApplication.time.text = utils.timeFormat(MyVideo.currentTime) + " / " + utils.timeFormat(MyVideo.duration);
					break;
				case 2:
					FlexGlobals.topLevelApplication.time.text = utils.timeFormat(MyVideo.videoStream.time);
					break;
			}
		}
		/**
		 * 重新计算快进进度操作控件（白色的竖线），只在UI更新的时候才会调用该函数
		 */
		public function reCalculatePlayForward():void
		{ 
			FlexGlobals.topLevelApplication.progressInstance.playforward.left = FlexGlobals.topLevelApplication.progressInstance.progressStage - 3;
		}
		/**
		 * 初始化鼠标操作控制函数，也就是对三维场景的操作
		 */
		public function setUpMouseControl():void 
		{
			//初始化鼠标控制事件
			myStage.addEventListener(MouseEvent.MOUSE_MOVE, MouseControls.onMouseMoves);
			myStage.addEventListener(MouseEvent.MOUSE_WHEEL, MouseControls.onMouseWheels);
			myStage.addEventListener(MouseEvent.MOUSE_DOWN, MouseControls.onMouseDowns);
			myStage.addEventListener(MouseEvent.MOUSE_UP, MouseControls.onMouseUps);
			myStage.addEventListener(KeyboardEvent.KEY_DOWN,MouseControls.keydowns);
			myStage.addEventListener(KeyboardEvent.KEY_UP, MouseControls.keyups);
			myStage.addEventListener("mouse:move:stop", MouseControls.onMouseUps);
			myStage.addEventListener("document:mosueout", MouseControls.onMouseUps);		
			
		}
		/**
		 * 取消鼠标操作控制函数，也就是取消对三维场景的操作
		 */
		public function cancelMouseControl():void 
		{
			myStage.removeEventListener(MouseEvent.MOUSE_MOVE, MouseControls.onMouseMoves);
			myStage.removeEventListener(MouseEvent.MOUSE_WHEEL, MouseControls.onMouseWheels);
			myStage.removeEventListener(MouseEvent.MOUSE_DOWN, MouseControls.onMouseDowns);
			myStage.removeEventListener(MouseEvent.MOUSE_UP, MouseControls.onMouseUps);
			myStage.removeEventListener(KeyboardEvent.KEY_DOWN,MouseControls.keydowns);
			myStage.removeEventListener(KeyboardEvent.KEY_UP, MouseControls.keyups);	
		}
		/**
		 * 跨进控制函数
		 * @param	e
		 */
		public function playForwardControls(e:MouseEvent):void
		{
			e.stopPropagation();
			var posX:Number = e.stageX;
			var len:Number = posX - 60;
			var ratio:Number = len / progressWidth;
			MyVideo.videoStream.seek(MyVideo.duration * ratio);
			
		}
		//开始播放视频的时候
		private function onStartPlayVideo():void
		{
			if (MyVideo.isPlay){
				FlexGlobals.topLevelApplication.time.text = utils.timeFormat(MyVideo.duration - MyVideo.videoStream.time);
			}
			setBufferAndCurrentTimeRatio(MyVideo.videoStream.time, MyVideo.videoStream.bytesLoaded);
		}
		//设置缓冲区长度及当前的时间比例
		private function setBufferAndCurrentTimeRatio(currentTime:Number,bufferingLen:Number):void
		{
			bufferingLenRatio = bufferingLen / MyVideo.videoStream.bytesTotal;
			progressLenRatio = Math.floor(currentTime) / Math.floor(MyVideo.duration);
			
		}
		/**
		 * 视频播放暂停控制
		 */
		public function playControls():void
		{
			if (MyVideo.isEnd){
				MyVideo.videoStream.seek(0.1);
				MyVideo.isEnd = false;
			}else{
				MyVideo.videoStream.togglePause();
			}
		}
		/**
		 * 音量大小控制
		 * @param	evt
		 */
		public function soundControls(evt:Event):void
		{	
			MyVideo.videoStream.soundTransform = new SoundTransform(MyVideo.currentVolume);
			MyVideo.videoStream.soundTransform  = new SoundTransform(new Number(FlexGlobals.topLevelApplication.volumeslider.value / 100));
			MyVideo.currentVolume = MyVideo.videoStream.soundTransform.volume;
			FlexGlobals.topLevelApplication.soundbtn.source = sound;
		}
		/**
		 * 静音控制
		 */
		public function handleMute():void{
			if(MyVideo.isMute){
				MyVideo.videoStream.soundTransform = new SoundTransform(MyVideo.currentVolume);
			}else{
				MyVideo.videoStream.soundTransform = new SoundTransform(0);
			}
		}
		/**
		 * 全屏切换控制
		 * @param	value
		 */
		public function setToggleFullScreen(value:Boolean):void
		{
			isFullScreen = value;
		}
		/**
		 * 但双屏切换控制
		 * @param	value
		 */
		public function setToggleDbScreen(value:Boolean):void
		{
			isDbScreen = value;
		}
		/**
		 * 控制鼠标按下去的时候的样式
		 * @param	e
		 */
		private static function MouseDownApperent(e:MouseEvent):void
		{
			e.stopPropagation();
			Mouse.cursor = MouseCursor.AUTO;
		}
		/**
		 * 控制鼠标弹起来的样式
		 * @param	e
		 */
		private static function MouseUpApperent(e:MouseEvent):void
		{
			e.stopPropagation();
			Mouse.cursor = MouseCursor.AUTO;
		}
		/**
		 * 控制鼠标经过的时候的样式
		 * @param	e
		 */
		private static function MouseOverApperent(e:MouseEvent):void
		{
			e.stopPropagation();
			Mouse.cursor = MouseCursor.BUTTON;
		}
		/**
		 * 控制鼠标移出的时候的样式
		 * @param	e
		 */
		private static function MouseOutApperent(e:MouseEvent):void
		{
			e.stopPropagation();
			Mouse.cursor = MouseCursor.AUTO;
		}
	}
}
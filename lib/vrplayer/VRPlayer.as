	
	import VRPlayerUtils.*;
	import VRPlayerUtils.*;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.events.TouchEvent;
	import flash.events.MouseEvent;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	import flash.external.*;
	import flash.utils.*;
	import flash.ui.*;
	
	private var _main:Render;
	private var videoPlayer:MyVideo;
	private var uicontrols:UIControls;
	public var mousecontrol:MouseControls;
	public var configs:Object = {isplay:false, ismute:false, sdbscreen:false, isfullscreen:false};
	private var signal:Number = 0;
	private var toolbarHide:Event = new Event("toolbar:hide");
	private var toolbarShow:Event = new Event("toolbar:show");
	private var timeOutId:Number = 0;
	private var isToolbarVisible:Boolean = true;
	private var isSoundControlVisible:Boolean = false;
	//全屏控制
	include "Resource.as";
	private function fullscreenHellper(e:Event = null):void
	{
		if (!uicontrols.isFullScreen){		
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			_main.onResize();
		}else{
			stage.displayState = StageDisplayState.NORMAL;
			_main.onResize();
		}
	}
	//在浏览器当中会存在问题
	private function handleFullScreenEvent(evt:FullScreenEvent):void
	{
		//当前在浏览器中无法响应
		if (evt.fullScreen){		
			uicontrols.setToggleFullScreen(true);
			fullscreen.source = exitFullScreen;
		}else{
			uicontrols.setToggleFullScreen(false);
			fullscreen.source = fullScreen;
		}
		fullscreen.validateNow();
	}
	/**
	 * 1.控制单双屏幕；
	 * @param	e
	 */
	private function dbScreenHelper(e:Event = null):void
	{
		if(uicontrols.isDbScreen){
			dbscreen.source = dbScreen;
			uicontrols.setToggleDbScreen(false);
		}else{
			dbscreen.source = exitdbScreen;
			uicontrols.setToggleDbScreen(true);
		}
		dbscreen.validateNow();
		_main.render();
	}
	/**
	 * 1. 控制声音的开关
	 * @param	e
	 */
	private function soundAndMuteHelper(e:Event = null):void
	{
		if (MyVideo.isMute){
			uicontrols.handleMute();
			MyVideo.isMute = false;
			soundbtn.source = soundBtnPic;
			
		}else{
			uicontrols.handleMute();
			MyVideo.isMute = true;
			soundbtn.source = muteBtnPic;
		}
		soundbtn.validateNow();
	}
	/**
	 * 1. 控制视屏的播放与暂停
	 * @param	e
	 */
	private function playAndPauseHelper(e:Event = null):void
	{
		if (MyVideo.isPlay){
			uicontrols.playControls();
			MyVideo.isPlay = false;
			playbtn.source = play;
		}else{
			uicontrols.playControls();
			MyVideo.isPlay = true;
			playbtn.source = pause;					
		}
		playbtn.validateNow();
	}
	/**
	 * 1.控制时间显示格式
	 * @param	e
	 */
	private function timeShowFormatHelper(e:Event = null):void
	{	
		uicontrols.timeFormat = ++ signal % 3;
	}
	/**
	 * 1.该函数调用外部名为navigatorTo的javascript函数
	 * @param	e
	 */
	private function navigator(e:Event = null):void
	{
		if(ExternalInterface.available){
			ExternalInterface.call("navigatorTo");
		}
	}
	/**
	 * 1.如果鼠标超过3s不动，工具栏将自动隐藏
	 * @param	evt
	 */
	private function handleMouseMove(evt:MouseEvent):void
	{
		if(timeOutId){
			clearTimeout(timeOutId);
			stage.dispatchEvent(toolbarShow);
		}
		timeOutId = setTimeout(triggerToolbarEvent, 3000);
	}
	private function triggerToolbarEvent():void
	{
		stage.dispatchEvent(toolbarHide);
	}
	/**
	 * 1. 显示工具栏
	 */
	private function showToolbar():void
	{
		Mouse.show();
		Mouse.cursor = MouseCursor.AUTO;
		movedownAnimate.end();
		moveupAnimate.play();
		isToolbarVisible = true;	
	}
	/**
	 * 隐藏工具栏
	 */
	private function hideToolbar():void
	{
		Mouse.hide();
		moveupAnimate.end();
		movedownAnimate.play();
		isToolbarVisible = false;
	}
	/**
	 * 控制工具栏的显示与隐藏
	 * @param	evt
	 */
	private function handleToolbarShow(evt:Event):void
	{
		if (evt.type == "toolbar:show"){
			if (isToolbarVisible) return;
			showToolbar();
		}else if (evt.type == "toolbar:hide"){
			if (!isToolbarVisible) return;
			hideToolbar();
		}
	}
	/**
	 * 初始化UI控制
	 */
	private function initUIEvent():void
	{

		playbtn.addEventListener(MouseEvent.CLICK,playAndPauseHelper);
		soundbtn.addEventListener(MouseEvent.CLICK, soundAndMuteHelper);

		dbscreen.addEventListener(MouseEvent.CLICK, dbScreenHelper);
		fullscreen.addEventListener(MouseEvent.CLICK,fullscreenHellper);

		time.addEventListener(MouseEvent.CLICK, timeShowFormatHelper);
		logo.addEventListener(MouseEvent.CLICK, navigator);		
		
		stage.addEventListener(FullScreenEvent.FULL_SCREEN , handleFullScreenEvent);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove );
		
		stage.addEventListener("toolbar:show", handleToolbarShow );
		stage.addEventListener("toolbar:hide", handleToolbarShow );
	}
	/**
	 * 为外部JS调用封装接口
	 */
	public function initHook():void
	{
		ExternalInterface.addCallback("setVideoURL", videoPlayer.setVideoURL);
		ExternalInterface.addCallback("documentMouseOut", uicontrols.triggerDocumentMouseOut);
	}
	/**
	 * 检测swf的兼容性，低于18的版本，将不能播放视频
	 */
	private function SWFCapabilities():void
	{
		var str:String = Capabilities.version;
		var regVer:RegExp = new RegExp("\\d[12]");
		var regOs:RegExp = new RegExp("Window|Mac");
		var desktop:Boolean = regOs.test(Capabilities.os);
		var version:Number = Number(str.match(regVer));
		if(version < 18){
			trace( "您当前Flash player 版本过低，请到Adobe官方网站下载更新");
		}	
	}
	private function initUI():void
	{
		if(ExternalInterface.available){
			ExternalInterface.call("ui")
		}
	}
	/**
	 * 整个AS-VR视频播放器的入口
	 */
	public function _init():void
	{
		videoPlayer = new MyVideo(stage,"");
		uicontrols = new UIControls(configs, videoPlayer, stage);
		uicontrols.setUpMouseControl();
		_main = new Render(stage, videoPlayer, uicontrols);
		initUIEvent();
		initHook();
	}
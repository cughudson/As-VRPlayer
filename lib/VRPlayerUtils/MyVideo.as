/**
*
* @author Hudson
* TimeStamp:2016-9-18 10:39
* MyVideo模块用于控制视频的加载以及元数据的加载与解析的相关的操作
* 
*/
package VRPlayerUtils 
{
	import VRPlayerUtils.utils;
	import away3d.materials.*;
	import away3d.containers.View3D;
	import away3d.loaders.parsers.ImageParser;
	import away3d.primitives.SphereGeometry;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.display3D.Context3D;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.*;
	import flash.system.LoaderContext;
	import mx.core.*;
	import flash.geom.Vector3D;
	import flash.net.ObjectEncoding;
	import flash.errors.IOError;
	import flash.system.SecurityDomain;
	import flash.system.ApplicationDomain;
	import flash.external.ExternalInterface;
	public class MyVideo extends Sprite
	{
	
		public static var duration:Number = 0;
		public static var currentTime:Number = 0;
		
		public static var isPlay:Boolean = false;
		public static var isMute:Boolean  = false;
		public static var isEnd:Boolean = false;
		public static var videoStream:NetStream;
		
		public var videoSize:Number;
		private var timeStr:String;
		public var videoUrl:String;
		public var myStage:Stage;
		public var lastVideoUrl:String;
		public static var currentVolume:Number;
		
		private var context:LoaderContext = new LoaderContext();
		private var defaultURL:String = null; 
		public var video:Video;
		private var loader:Loader = new Loader();
		private var bitmap:Bitmap;
		private var connect:NetConnection;
		public var _videoContainer:Sprite = new Sprite();
		
		private var toolbar:Object;
		private var toolbarBottom:Number = 0;
		private var toolbarHeight:Number;
		[Embed(source = "../../assert/icon/play.png")]
		[Bindable]
		private var play:Class;
		public function MyVideo(stage:Stage = null, str:String = "") 
		{
			myStage = stage;
			videoUrl = str;
			initVideo();
			initEvent();
		}
		/**
		 * 初始化视频，视频声量，事件等等。创建NetStream，设置视频的大小（Flash对视频的大小做出了限制）
		 */
		public function initVideo():void
		{
			
			video = new Video(1024, 1024);
			connect = new NetConnection();
			connect.connect(null);
			videoStream = new NetStream(connect);
			
			videoStream.checkPolicyFile = true;
			videoStream.client = {};
			videoStream.client.onMetaData = myOnMetaData;
			videoStream.client.onPlayStatus = myOnPlayStatus; 
			video.smoothing = true;
			video.attachNetStream(videoStream);
			videoStream.play(videoUrl);
			videoStream.pause();
			_videoContainer.addChild(video);
			_videoContainer.visible = false;

			videoStream.soundTransform = new SoundTransform(new Number(FlexGlobals.topLevelApplication.volumeslider.value) / 100);
			currentVolume = videoStream.soundTransform.volume;
			myStage.addChild(_videoContainer);
		}
		private function initEvent(event:Event = null):void
		{
			videoStream.addEventListener(NetStatusEvent.NET_STATUS, myOnNetStatus);
			connect.addEventListener(SecurityErrorEvent.SECURITY_ERROR, asyncErrorHandler);		
			myStage.addEventListener(Event.ENTER_FRAME, updateVideoTime);
		}
		/**
		 * 设置所要播放视频的URL地址。该函数需要与外界的javascript进行通信才能够使用
		 * @param	urlStr
		 */
		public function setVideoURL(urlStr:String):void
		{			
	
			videoUrl = urlStr; 
			//
			//对URL进行过滤，剔除不符合规则的URL，保护知识产权，暂时未去实现;
			//
			videoStream.dispose();
			videoStream.play(videoUrl);
			videoStream.seek(0.1);
			videoStream.pause();
			FlexGlobals.topLevelApplication.playbtn.source = play;
			MyVideo.isPlay = false;
		}
		/**
		 * 设置初始视频状态，当视频可以播放的时候触发该函数
		 * @param	metaData
		 */
		private function myOnPlayStatus(metaData:Object):void
		{
			isEnd = true;
			isPlay = false;
			FlexGlobals.topLevelApplication.playbtn.source = play;
		}
		/**
		 * 读取到了视频的元素据的时候，将会触发该函数
		 * @param	metaData 元素据对象
		 */
		private function myOnMetaData(metaData:Object):void
		{
			duration = metaData.duration;
			videoSize = videoStream.bytesTotal;
			setDurationTime(duration);
		}
		private function myOnNetStatus(event:NetStatusEvent):void
		{
			switch(event.info.code){
				case "NetConnection.Call.BadVersion":
					if(ExternalInterface.available){
						ExternalInterface.call("alert", "不支持的数据包格式");
					}
					break;
				case "NetConnection.Connect.Failed":
					if(ExternalInterface.available){
						ExternalInterface.call("alert", "资源链接失败");
					}
					break;
				case "NetConnection.Connect.NetworkChange":
					if(ExternalInterface.available){
						ExternalInterface.call("alert", "网络连接问题，请尝试重新连接");
					}
					break;
				case "NetStream.Play.StreamNotFound":
					if(ExternalInterface.available){
						ExternalInterface.call("alert", "未发现指定资源");
					}
					break;
				case "NetStream.Buffer.Empty":
					//trace("视频播放完毕，缓存清空");
					//TODO：添加默认动作；
					break;
				default:
			}
		}
		/**
		 * 更新视频时间
		 * @param	event
		 */
		private function updateVideoTime(event:Event = null):void
		{
			currentTime = videoStream.time;
		}
		/**
		 * 设置视频时长的显示格式
		 * @param	duration
		 */
		private function setDurationTime(duration:Number):void
		{
			FlexGlobals.topLevelApplication.time.text = utils.timeFormat(duration);
		}
	}
}

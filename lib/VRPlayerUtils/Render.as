/**
* @mxmlc -default-size 400 300 -o bin/foo.swf
* @author Hudson
* TimeStamp:2016-9-18 11:05
* Render为一渲染模块，用来将视频渲染到球体上
* 
*/
package VRPlayerUtils
{
	import VRPlayerUtils.MouseControls;
	import VRPlayerUtils.UIControls;
	import VRPlayerUtils.MyVideo;
	import away3d.cameras.Camera3D;
	import away3d.textures.BitmapTexture;
	import away3d.tools.helpers.MeshHelper;
	
	import away3d.entities.Mesh;
	import away3d.primitives.SphereGeometry;
	import away3d.containers.*;
	import away3d.materials.TextureMaterial;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.ui.*;
	import flash.utils.*;
	import flash.system.Security;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;

	[SWFVersion(backgroundColor ="#ff0000",width="900",height="600",frameRate = "60")]
	public class Render extends Sprite 
	{
		public var myStage:Stage;
		private var _uicontrol:UIControls;
		private var zoomDistance:Number = 0;
		
		private var _mousecontrol:MouseControls;
		private var _mySphere:Mesh;
		private var _videoMaterial:TextureMaterial;
		private var videoPlayer:MyVideo;
		private var bitmapData:BitmapData;
		private var bitMapTexture:BitmapTexture = new BitmapTexture(new BitmapData(1024, 1024, true, 0x000000),true);
		
		private var _view1:View3D = new View3D();
		private var _view2:View3D = new View3D();
		private var _view0:View3D = new View3D();
		private var _camera:Camera3D;	
		private var _cameraForWard:Vector3D;
		private var _scene:Scene3D = new Scene3D();
		private var _cameraMatrix:Matrix3D = new Matrix3D;
		
		private var rotateAtX:Number;
		private var rotateAtY:Number;
		private var _zoomDistance:Number;
				
		private var latLast:Number = 0;
		private var lonLast:Number = 0;
		private var latCurrent:Number = 0;
		private var lonCurrent:Number = 0;
		
		private var rotateMatrix:Matrix = new Matrix();
		
		private const degToRad:Number = Math.PI / 180;
		private const radToDeg:Number = 180 / Math.PI;
		/**
		 * 渲染模块构造函数
		 * @param	stage
		 * @param	videoMat
		 * @param	uicontrol
		 */
		public function Render(stage:Stage,videoMat:MyVideo,uicontrol:UIControls) 
		{
			super();			
			myStage = stage;
			videoPlayer = videoMat;
			_uicontrol = uicontrol;
			if (myStage) init();
			myStage.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		/**
		 * 初始化渲染模块
		 * @param	e
		 */
		public function init(e:Event = null):void 
		{
			myStage.addEventListener(Event.ENTER_FRAME, myRender);
			myStage.addEventListener(Event.RESIZE, updateView);
			
			myStage.scaleMode = StageScaleMode.NO_SCALE;
			myStage.align = StageAlign.TOP_LEFT;
			myStage.color = 0x000000;
			
			initView();	
			onResize();			
		}
		/**
		 * 构建球体，并将球体的表面进行反转，否则视频的图像将会左右倒置
		 */
		public function initSphereMesh():void
		{	 
			_mySphere = new Mesh(new SphereGeometry(50, 100, 100, true), null);
			MeshHelper.invertFaces(_mySphere, true);
			_videoMaterial = new TextureMaterial(bitMapTexture, true, true, true);
			_videoMaterial.bothSides = true;
			_mySphere.material = _videoMaterial; 
			_mySphere.position = new Vector3D(0, 0, 0);
			_scene.addChild(_mySphere);
			
		}
		/**
		 * 1. 构建相机
		 * 2. 初始化左眼播放视口
		 * 3. 初始化右眼播放视口
		 * 4. 初始化单屏播放视口
		 */
		public function initView():void
		{
			_camera = new Camera3D();			
			var centerPoint:Vector3D = new Vector3D(0, 0, 0);
			var cameraPos:Vector3D = new Vector3D(0, 1.7, 0);
			_camera.position = cameraPos;
			_camera.lookAt(centerPoint);
			//_view0为单视口对象
			_view0 = new View3D(_scene, _camera);
			_view0.x = 0;
			_view0.y = 0;
			_view0.height = myStage.stageHeight;
			_view0.width = myStage.stageWidth;
			_view0.visible = true;
			//_view1为左视口
			_view1 = new View3D(_scene, _camera);
			_view1.x = 0;
			_view1.y = 0;
			_view1.height = myStage.stageHeight;
			_view1.width = myStage.stageWidth / 2;
			_view1.visible = false;
			//_view2为右视口
			_view2 = new View3D(_scene, _camera);
			_view2.x = myStage.stageWidth / 2;
			_view2.y = 0;
			_view2.height = myStage.stageHeight;
			_view2.width = myStage.stageWidth / 2;
			_view2.visible = false;
			
			initSphereMesh();
			myStage.addChildAt(_view0, 0);
			myStage.addChildAt(_view1, 1);
			myStage.addChildAt(_view2, 2);
			
		}
		/**
		 * 更新视频材质
		 */
		private function updateTexture():void
		{
			bitmapData = bitMapTexture.bitmapData;
			bitMapTexture.hasMipMaps;
			bitmapData.lock();
			bitmapData.fillRect(bitmapData.rect, 0);
			bitmapData.draw(videoPlayer._videoContainer,null,null,BlendMode.NORMAL,null,true);
			bitMapTexture.invalidateContent();
		}
		/**
		 * 通过MouseControls获取球体的旋转角度；
		 * 视角旋转的角度为-72~72度之间；
		 */
		private function getRotateAngle():void
		{
			
			latCurrent += MouseControls.rotateX * 2;
			lonCurrent += MouseControls.rotateY * 2.5;
			lonCurrent = Math.max( -300 , Math.min(300 , lonCurrent));	
			rotateAtY = latCurrent;
			rotateAtX = lonCurrent;
			_zoomDistance = MouseControls.zoomDistance;

		}
		public function myRender(e:Event):void
		{
			render();
		}
		/**
		 * 1.渲染球体；
		 * 2.旋转球体
		 * 3.单双屏切换
		 */
		public function render():void
		{
			
			getRotateAngle();
			updateTexture();
			
			_cameraForWard = _camera.forwardVector;	
			_camera.position = new Vector3D(_zoomDistance * _cameraForWard.x, _zoomDistance * _cameraForWard.y, _zoomDistance * _cameraForWard.z);
			
			_camera.rotationY = -rotateAtY * 0.2;
			_camera.rotationX = rotateAtX * 0.2;
			if(_uicontrol.isDbScreen){
				_view0.visible = false;
				_view1.visible = true;
				_view2.visible = true;
				_view1.render();
				_view2.render();
			}else{
				_view0.visible = true;
				_view1.visible = false;
				_view2.visible = false;
				_view0.render();
			}		
		}
		/**
		 * 调用onResize函数来更新场景
		 * @param	event
		 */
		public function updateView(event:Event):void
		{
			onResize();
		}
		public function onResize():void
		{			
			_view0.x = 0;
			_view0.y = 0;
			_view0.height = myStage.stageHeight;
			_view0.width = myStage.stageWidth;
			
			_view1.y = 0;
			_view1.x = 0;
			_view1.height = myStage.stageHeight;
			_view1.width = myStage.stageWidth / 2;
			
			_view2.y = 0;
			_view2.x = myStage.stageWidth / 2;
			_view2.height = myStage.stageHeight;
			_view2.width = myStage.stageWidth / 2;
			render();
		}
	}
	
}


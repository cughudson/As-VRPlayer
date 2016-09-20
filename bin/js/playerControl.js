/**
 * ...
 * @author Hudson
 */
  // var swfObj;
  // var url = "http://192.168.1.166/project/doing/JS-VR%E6%92%AD%E6%94%BE%E5%99%A8/HTML5Player.bak/asser/dubai2.mp4";
  // var setUrl = function(url){

  //       swfObj = document.getElementById('swfplayer');
  //       setTimeout(function(){ swfObj.setVideoURL(url)}, 1000);
  // };
  // window.navigatorTo = function (){
  //     window.open('http://www.vrbobo.com');
  // };
  // window.addEventListener('load', function(){setUrl(url)}, false);
  var lastObject = null;
  var currentObject = null;
  var swfObj = null;
  //var base = "http://statics.bananavr.com/";
  //var base = "http://cache.utovr.com/";
  var base = "http://statics.bananavr.com/statics/upload/videos/";
  var runPlayer_swf = function(url){
    var intervalId;
    url = base + url;
    swfObj = document.getElementById('swfplayer');  
    intervalId = setInterval(function(){
      if(swfObj.setVideoURL){
          swfObj.setVideoURL(url);
          dispatchMouseOutEvent();
          clearInterval(intervalId);
        }
    }, 1000 / 60);

  }
  window.navigatorTo = function (){
      window.open('http://www.vrbobo.com');
  };
  var dispatchMouseOutEvent = function(){
    _H(document).bind("mousemove", function(evt){
      currentObject = evt.target;
      if(typeof lastObject === "function" && typeof currentObject === "object"){
          swfObj.documentMouseOut();
      }
      lastObject = currentObject;
    })
  };
  _H(window).bind('load', function(){runPlayer_swf("1461899866994.mp4")});
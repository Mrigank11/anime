package com.example.animedl;

import android.os.Bundle;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import com.chaquo.python.*;
import com.chaquo.python.android.*;


public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "kmrigank.animedl/search";
  private static final String TAG = "ANIME_DL";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    if(!Python.isStarted()){
        Python.start(new AndroidPlatform(getApplicationContext()));
    }

    GeneratedPluginRegistrant.registerWith(this);

      new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
              new MethodCallHandler() {
                  @Override
                  public void onMethodCall(MethodCall call, Result result) {
                    //always run in new thread, as python is sync.
                    new Thread(new Task(call, result)).start();
                  }
              });
  }
  

  private String getStreamUrl(String query, int ep){
      Python py = Python.getInstance();
      PyObject main = py.getModule("main");
      Log.d(TAG, "getStreamUrl: starting");
      PyObject url = main.callAttr("get_stream_url",query,ep);
      Log.d(TAG, "getStreamUrl: ret from python");
      return url.toString();
  }

  private String searchAnime(String query){
      Python py = Python.getInstance();
      PyObject main = py.getModule("main");
      Log.d(TAG, "searchAnime: starting search");
      PyObject animes = main.callAttr("search",query);
      Log.d(TAG, "searchAnime: ret from python");
      return animes.toString();
  }

    class Task implements Runnable{
        private Result result;
        private MethodCall call;

        public Task(MethodCall call, Result res){
            this.result = res;
            this.call = call;
        }

        @Override
        public void run() {
            try {
                //every response must be String or else must be JSON encoded
                String res="";
                switch(this.call.method){
                    case "searchAnime":
                        res = searchAnime(this.call.argument("query").toString());
                        break;
                    case "getStreamUrl":
                        res = getStreamUrl(this.call.argument("url").toString(), Integer.parseInt(this.call.argument("ep").toString()));
                        break;
                    default:
                        this.result.notImplemented();
                }
                result.success(res);
            }catch (Exception e){
                result.error("ERR","some error occured",e);
            }
        }
    }
}
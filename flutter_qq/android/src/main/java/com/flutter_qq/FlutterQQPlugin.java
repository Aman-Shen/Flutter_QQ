package com.flutter_qq;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.tencent.connect.UserInfo;
import com.tencent.connect.common.Constants;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterQqPlugin */
public class FlutterQQPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware,PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
    private Context context;
    private Tencent mTencent;
    private Activity activity;
    private Result result;
    private IUiListener loginListener = new IUiListener(){

      @Override
      public void onComplete(Object o) {

        JSONObject response = (JSONObject)o;

        try {

          Map<String,Object> resultData = new HashMap<>();
          resultData.put("Code",0);
          resultData.put("Message","Ok");
          Map<String,Object> data = new HashMap<>();
          String openId = response.getString("openid");
          String access_token = response.getString("access_token");
          data.put("openid",openId);
          data.put("accessToken",access_token);
          resultData.put("Response",data);
          result.success(resultData);

        }catch (Exception e){

          Map<String,Object> resultData = new HashMap<>();
          resultData.put("Code",1);
          resultData.put("Message","ERROR");
          result.success(resultData);
        }
      }

      @Override
      public void onError(UiError uiError) {

        Map<String,Object> resultData = new HashMap<>();
        resultData.put("Code",1);
        resultData.put("Message","error login");
        result.success(resultData);
      }

      @Override
      public void onCancel() {

        Map<String,Object> resultData = new HashMap<>();
        resultData.put("Code",1);
        resultData.put("Message","cancle login");
        result.success(resultData);
      }

      @Override
      public void onWarning(int i) {

        Map<String,Object> resultData = new HashMap<>();
        resultData.put("Code",1);
        resultData.put("Message","warning login");
        result.success(resultData);
      }
    };


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_qq");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();



  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull  final Result result) {
    this.result = result;

    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }else if(call.method.equals("registerQQ")){

        Map<String, String> arguments = (Map<String, String>) call.arguments;
        String appId = arguments.get("appId");
        mTencent = Tencent.createInstance(appId,context);
        result.success(null);

    } else if(call.method.equals("isQQInstalled")){

      boolean isOk = mTencent.isQQInstalled(context);
      result.success(isOk);

    }else if(call.method.equals("login")){

//      mTencent.checkLogin(new IUiListener() {
//        @Override
//        public void onComplete(Object o) {
//
//
//
//        }
//
//        @Override
//        public void onError(UiError uiError) {
//
//        }
//
//        @Override
//        public void onCancel() {
//
//        }
//
//        @Override
//        public void onWarning(int i) {
//
//        }
//      });
      mTencent.login(activity,"all",loginListener);


    } else if(call.method.equals("getUserInfo")){
//      Map<String, String> arguments = (Map<String, String>) call.arguments;
//      String token = arguments.get("token");
      UserInfo info = new UserInfo(context, mTencent.getQQToken());
      info.getUserInfo(new IUiListener(){

        @Override
        public void onComplete(Object o) {
          JSONObject jo = (JSONObject) o;
          Map<String, Object> data =new HashMap<>();
          Iterator it =jo.keys();
          while (it.hasNext()) {
            Map.Entry<String, Object> entry = (Map.Entry<String, Object>) it.next();
            data.put(entry.getKey(), entry.getValue());
          }
          Map<String,Object> resultData = new HashMap<>();
          resultData.put("Code",0);
          resultData.put("Message","Ok");
          resultData.put("Response",data);
          result.success(resultData);

        }

        @Override
        public void onError(UiError uiError) {

          Map<String,Object> resultData = new HashMap<>();
          resultData.put("Code",1);
          resultData.put("Message","error getUsr");
          result.success(resultData);
        }

        @Override
        public void onCancel() {

          Map<String,Object> resultData = new HashMap<>();
          resultData.put("Code",1);
          resultData.put("Message","error getUsr");
          result.success(resultData);
        }

        @Override
        public void onWarning(int i) {
          Map<String,Object> resultData = new HashMap<>();
          resultData.put("Code",1);
          resultData.put("Message","warn getUsr");
          result.success(resultData);
        }
      });

    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {

    activity = binding.getActivity();
    binding.addActivityResultListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
  }

  @Override
  public void onDetachedFromActivity() {

  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {

    if(requestCode == Constants.REQUEST_LOGIN) {

      Tencent.onActivityResultData(requestCode,resultCode,data,loginListener);
    }
    return false;
  }
}

package com.paara.paara_app_duk

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.paara.paara_app_duk/back_handler"
    private var methodChannel: MethodChannel? = null
    private var canExit = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "setCanExit" -> {
                    canExit = call.argument<Boolean>("canExit") ?: false
                    result.success(canExit)
                }
                "exitApp" -> {
                    finish()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onBackPressed() {
        if (canExit) {
            super.onBackPressed() // exit app
        } else {
            // send back press event to Flutter side
            methodChannel?.invokeMethod("onBackPressed", null)
        }
    }
}

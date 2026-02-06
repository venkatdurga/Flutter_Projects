package com.example.my_app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.my_app.databinding.ActivityMainBinding

class MainActivity : FlutterActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.startInferenceButton.setOnClickListener {
            val intent = Intent(this, SpoofDetectionActivity::class.java)
            startActivity(intent)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "channel_name").setMethodCallHandler { call, result ->
            if (call.method == "method_name") {
                // Handle method calls here
                result.success("Result from native code")
            } else {
                result.notImplemented()
            }
        }
    }
}

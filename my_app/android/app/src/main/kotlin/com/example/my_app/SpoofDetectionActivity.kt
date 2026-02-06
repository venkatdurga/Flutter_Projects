package com.example.my_app

import android.graphics.Bitmap
import android.os.Bundle
import android.util.Log
import android.view.SurfaceHolder
import android.view.SurfaceView
import androidx.appcompat.app.AppCompatActivity
import com.example.my_app.api.ApiService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.content.Intent
import android.widget.Button



class SpoofDetectionActivity : AppCompatActivity() {

    private lateinit var surfaceView: SurfaceView
    private var isInferenceRunning = false
    private val apiService = ApiService()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_spoof_detection)

        surfaceView = findViewById(R.id.camera_preview)

        // Initialize camera
        setupCamera()

        // Start inference on button click
        findViewById<Button>(R.id.start_inference_button).setOnClickListener {
            isInferenceRunning = true
            startInference()
        }

        // Stop inference
        findViewById<Button>(R.id.stop_inference_button).setOnClickListener {
            isInferenceRunning = false
        }
    }

    private fun setupCamera() {
        // Implement camera setup using CameraX or Camera API
    }

    private fun startInference() {
        if (isInferenceRunning) {
            // Capture image frame from camera
            val bitmap = captureImageFrame()

            // Process image and send it to API
            bitmap?.let { sendToApi(it) }
        }
    }

    private fun captureImageFrame(): Bitmap? {
        // Capture a frame from the camera preview and return it as a Bitmap
        // Implement your frame capture logic here
        return null
    }

    private fun sendToApi(bitmap: Bitmap) {
        CoroutineScope(Dispatchers.IO).launch {
            val result = apiService.predictSpoof(bitmap)
            withContext(Dispatchers.Main) {
                // Handle result and update UI
                Log.d("SpoofDetection", "Spoof Result: $result")
                // Display result in UI
            }
        }
    }
}

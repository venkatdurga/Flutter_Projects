package com.example.my_app

import okhttp3.OkHttpClient
import okhttp3.MultipartBody
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import java.io.File

class ApiService {
    private val client = OkHttpClient()

    fun uploadImage(file: File) {
        val requestBody = MultipartBody.Builder()
            .setType(MultipartBody.FORM)
            .addFormDataPart("file", file.name, RequestBody.create("image/jpeg".toMediaTypeOrNull(), file))
            .build()

        val request = Request.Builder()
            .url("http://164.100.140.208:5000/predict_vehicle_type")
            .post(requestBody)
            .build()

        client.newCall(request).execute()
    }
}

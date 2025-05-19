package com.ghc.marsapp
// import com.webengage.sdk.android.LocationTrackingStrategy
// import com.webengage.sdk.android.WebEngageConfig
// import com.webengage.webengage_plugin.WebengageInitializer
import io.flutter.app.FlutterApplication;

import com.google.android.gms.tasks.Task;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.android.gms.tasks.OnCompleteListener;
import androidx.annotation.NonNull;
// import com.webengage.sdk.android.WebEngage;
// import com.microsoft.clarity.Clarity
// import com.microsoft.clarity.ClarityConfig


class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        // val config = ClarityConfig("iryghcd45p")
        // Clarity.initialize(this, config)
        // val webEngageConfig = WebEngageConfig.Builder()
        //     .setWebEngageKey("in~d3a49c4d")
        //     .setAutoGCMRegistrationFlag(false)
        //     .setLocationTrackingStrategy(LocationTrackingStrategy.ACCURACY_BEST)
        //     .setDebugMode(true) // only in development mode
        //     .build()
        // WebengageInitializer.initialize(this, webEngageConfig)

        FirebaseMessaging.getInstance().token
            .addOnCompleteListener(OnCompleteListener { task ->
                if (!task.isSuccessful) {
                    return@OnCompleteListener
                }
                // Get new FCM registration token
                val token: String = task.getResult()
                // WebEngage.get().setRegistrationID(token)
            })
    }
}
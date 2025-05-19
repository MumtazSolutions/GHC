package com.ghc.marsapp;
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService;
// import com.webengage.sdk.android.WebEngage;
import com.google.firebase.messaging.RemoteMessage;

class MyFirebaseMessagingService : FlutterFirebaseMessagingService() {
    override fun onNewToken(s: String) {
        super.onNewToken(s)
        // WebEngage.get().setRegistrationID(s)
    }

     override fun onMessageReceived(remoteMessage: RemoteMessage) {
        val data = remoteMessage.data
        println(data)
        if (data != null) {
            // if (data.containsKey("source") && "webengage" == data["source"]) {
            //     WebEngage.get().receive(data)
            // }
        }
    }
    
}
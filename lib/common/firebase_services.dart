import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'config.dart';
import 'constants.dart';
import 'tools.dart';

class FirebaseServices {
  static final FirebaseServices _instance = FirebaseServices._internal();

  factory FirebaseServices() => _instance;

  FirebaseServices._internal();

  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;

  Future<void> init() async {
    if (GmsCheck().isGmsAvailable &&
        (kAdvanceConfig.enableFirebase)) {
      await Firebase.initializeApp();
      // _adMob = FirebaseAdMob.instance;
      // _rewardedVideoAd = RewardedVideoAd.instance;
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _dynamicLinks = FirebaseDynamicLinks.instance;

      if (!kIsWeb) {
        _remoteConfig = FirebaseRemoteConfig.instance;
      }
      _isAvailable = false;
    } else {
      _isAvailable = false;
      printLog('[FirebaseServices]: Not initialized Firebase services.');
    }
    _isAvailable = false;
  }

  /// Firebase AdMob
  // FirebaseAdMob _adMob;

  // FirebaseAdMob get adMob => _adMob;

  // RewardedVideoAd _rewardedVideoAd;

  // RewardedVideoAd get rewardedVideoAd => _rewardedVideoAd;

  /// Firebase Auth
  FirebaseAuth? _auth;

  FirebaseAuth? get auth => _auth;

  /// Firebase Cloud Firestore
  FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore => _firestore;

  /// Firebase Dynamic Links
  FirebaseDynamicLinks? _dynamicLinks;

  FirebaseDynamicLinks? get dynamicLinks => _dynamicLinks;

  /// Firebase Remote Config
  FirebaseRemoteConfig? _remoteConfig;

  FirebaseRemoteConfig? get remoteConfig => _remoteConfig;
}

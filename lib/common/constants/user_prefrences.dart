import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._ctor();

  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._ctor();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void deInit() {
    _prefs?.clear();
  }

  bool get initAsk {
    return _prefs?.getBool('loggedIn') ?? true;
  }

  set initAsk(bool value) {
    _prefs?.setBool('loggedIn', value);
  }

  bool get seenSkin {
    return _prefs?.getBool('seenSkin') ?? false;
  }

  set seenSkin(bool value) {
    _prefs?.setBool('seenSkin', value);
  }

  bool get seenHair {
    return _prefs?.getBool('seenHair') ?? false;
  }

  set seenHair(bool value) {
    _prefs?.setBool('seenHair', value);
  }

   bool get seenBeard {
    return _prefs?.getBool('seenBeard') ?? false;
  }

  set seenBeard(bool value) {
    _prefs?.setBool('seenBeard', value);
  }

  bool get seenWeight {
    return _prefs?.getBool('seenWeight') ?? false;
  }

  set seenWeight(bool value) {
    _prefs?.setBool('seenWeight', value);
  }

   bool get seenAppOnboarding {
    return _prefs?.getBool('seenAppOnboarding') ?? false;
  }

  set seenAppOnboarding(bool value) {
    _prefs?.setBool('seenAppOnboarding', value);
  }

  double get height {
    return _prefs?.getDouble('height') ?? 170.0;
  }

  set height(double value) {
    _prefs?.setDouble('height', value);
  }
}

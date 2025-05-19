// ignore_for_file: prefer_single_quotes, lines_longer_than_80_chars final
Map<String, dynamic> marsStage = {
  "appConfig": "lib/config/config_en.json",
  "apiUrl": "https://stagingappapi.ghc.health/api",

  /// ➡️ lib/common/config.dart
  "serverConfig": {
    'type': 'shopify',
    'url': 'https://mars-ghc-us.myshopify.com',
    'accessToken': 'f88bc71d0a8178b6f1607ee957f2461b',
    // "blog": "http://demo.mstore.io", //Your website woocommerce. You can remove this line if it same url
    'forgetPassword':
        'https://ghc.health/account/login?return_url=%2Faccount#recover'
  },

  /// ➡️ lib/common/config/general.dart
  "defaultDarkTheme": false,
  "loginSMSConstants": {
    "countryCodeDefault": "IN",
    "dialCodeDefault": "+91",
    "nameDefault": "India"
  },
  "storeIdentifier": {
    "disable": true,
    "android": "com.ghc.marsapp",
    "ios": "1469772800"
  },
  "advanceConfig": {
    "DefaultLanguage": "en",
    "DetailedBlogLayout": "halfSizeImageType",
    "EnablePointReward": true,
    "hideOutOfStock": false,
    "EnableRating": true,
    "hideEmptyProductListRating": true,
    "EnableShipping": true,
    "EnableSkuSearch": true,
    "showStockStatus": true,
    "GridCount": 3,
    "isCaching": false,
    "kIsResizeImage": false,
    "DefaultCurrency": {
      "symbol": "\₹",
      "decimalDigits": 2,
      "symbolBeforeTheNumber": true,
      "currency": "INR",
      "currencyCode": "inr",
      "smallestUnitRate": 100, // 100 cents = 1 usd
    },
    "Currencies": [
      {
        "symbol": "\₹",
        "decimalDigits": 2,
        "symbolBeforeTheNumber": true,
        "currency": "INR",
        "currencyCode": "inr",
        "smallestUnitRate": 100, // 100 cents = 1 usd
      }
    ],

    /// Below config is used for Magento store
    "DefaultStoreViewCode": "",
    "EnableAttributesConfigurableProduct": ["color", "size"],
    "EnableAttributesLabelConfigurableProduct": ["color", "size"],
    "isMultiLanguages": false,
    "EnableApprovedReview": false,
    "EnableSyncCartFromWebsite": true,
    "EnableSyncCartToWebsite": true,
    "EnableShoppingCart": false,
    "EnableFirebase": true,
    "RatioProductImage": 1.2,
    "EnableCouponCode": true,
    "ShowCouponList": true,
    "ShowAllCoupons": true,
    "ShowExpiredCoupons": false,
    "AlwaysShowTabBar": false,
    "PrivacyPoliciesPageId": 25569,
    "QueryRadiusDistance": 10 //km
  },
  "defaultDrawer": {
    "logo": "assets/images/logo.png",
    "background": null,
    "items": [
      {"type": "home", "show": true},
      {"type": "blog", "show": true},
      {"type": "categories", "show": false},
      {"type": "cart", "show": true},
      {"type": "profile", "show": true},
      {"type": "wishlist", "show": true},
      {"type": "login", "show": true},
      {"type": "tracker", "show": true},
      {"type": "support", "show": true},
      {"type": "category", "show": true}
    ]
  },
  "defaultSettings": [
    "products",
    "chat",
    "wishlist",
    "notifications",
    "language",
    // "currencies",
    // "darkTheme",
    "order",
    // "point",
    "rating",
    // "privacy",
    // "about"
  ],
  "loginSetting": {
    "IsRequiredLogin": false,
    "showAppleLogin": false,
    "showFacebook": false,
    "showSMSLogin": false,
    "showGoogleLogin": false,
    "showPhoneNumberWhenRegister": false,
    "requirePhoneNumberWhenRegister": false
  },
  "oneSignalKey": {
    "enable": false,
    "appID": "8b45b6db-7421-45e1-85aa-75e597f62714"
  },

  /// ➡️ lib/common/onboarding.dart
  "onBoardingData": [
    {
      "title": "Shop",
      "image": "assets/images/banner1.png",
      "desc":
          "Men’s health and wellness products on hair, beard, performance and weight management"
    },
    {
      "title": "Track",
      "image": "assets/images/banner1.png",
      "desc": "Track your Wellness progress while you are on your treatment"
    },
    {
      "title": "Compare",
      "image": "assets/images/banner1.png",
      "desc": "Compare and Monitor your improvement on the go!"
    }
  ],

  /// ➡️ lib/common/advertise.dart
  "adConfig": {
    "enable": false,
    "type": "googleBanner",

    /// ----------------- Facebook Ads  -------------- ///
    "hasdedIdTestingDevice": "9dd4404c-5278-46ba-9851-e2dfcccdddb6",
    "bannerAndroidPlacementId": "430258564493822_489007588618919",
    "interstitialAndroidPlacementId": "430258564493822_489092398610438",
    "nativeAndroidPlacementId": "430258564493822_489092738610404",
    "nativeBannerAndroidPlacementId": "430258564493822_489092925277052",
    "banneriOSPlacementId": "430258564493822_489007588618919",
    "interstitialiOSPlacementId": "430258564493822_489092398610438",
    "nativeiOSPlacementId": "430258564493822_489092738610404",

    /// ------------------ Google Admob  -------------- ///
    "androidAppId": "ca-app-pub-2101182411274198~6793075614",
    "androidUnitBanner": "ca-app-pub-2101182411274198/4052745095",
    "androidUnitInterstitial": "ca-app-pub-2101182411274198/7131168728",
    "androidUnitReward": "ca-app-pub-2101182411274198/6939597036",
    "iosAppId": "ca-app-pub-2101182411274198~6923444927",
    "iosUnitBanner": "ca-app-pub-2101182411274198/5418791562",
    "iosUnitInterstitial": "ca-app-pub-2101182411274198/9218413691",
    "iosUnitReward": "ca-app-pub-2101182411274198/9026842008",
    "waitingTimeToDisplayInterstitial": 10,
    "waitingTimeToDisplayReward": 10
  },

  /// ➡️ lib/common/dynamic_link.dart
  "firebaseDynamicLinkConfig": {
    "isEnabled": true,
    "uriPrefix": "https://fluxstoreinspireui.page.link",
    //The link your app will open
    "link": "https://mstore.io/",
    //----------* Android Setting *----------//
    "androidPackageName": "com.ghc.marsapp",
    "androidAppMinimumVersion": 1,
    //----------* iOS Setting *----------//
    "iOSBundleId": "com.inspireui.mstore.flutter",
    "iOSAppMinimumVersion": "1.0.1",
    "iOSAppStoreId": "1469772800"
  },

  /// ➡️ lib/common/languages.dart
  "languagesInfo": [
    {
      "name": "English",
      "icon": "assets/images/country/gb.png",
      "code": "en",
      "text": "English",
      "storeViewCode": ""
    }
  ],
  "unsupportedLanguages": [],

  /// ➡️  lib/common/config/payments.dart
  "paymentConfig": {
    "DefaultCountryISOCode": "IN",
    "DefaultStateISOCode": "TG",
    "EnableShipping": false,
    "EnableAddress": true,
    "EnableCustomerNote": false,
    "EnableAddressLocationNote": true,
    "EnableAlphanumericZipCode": false,
    "EnableReview": false,
    "allowSearchingAddress": false,
    "GuestCheckout": true,
    "EnableOnePageCheckout": false,
    "NativeOnePageCheckout": false,
    "CheckoutPageSlug": {"en": "checkout"},
    "EnableCreditCard": false,
    "UpdateOrderStatus": false,
    "ShowOrderNotes": true,
    "EnableRefundCancel": false
  },
  "payments": {
    // "paypal": "assets/icons/payment/paypal.png",
    // "stripe": "assets/icons/payment/stripe.png",
    "razorpay": "assets/icons/payment/razorpay.png",
    // "tap": "assets/icons/payment/tap.png"
  },

  "razorpayConfig": {
    "keyId": "rzp_test_4HIlifA9tZvEqU",
    "keySecret": "D7TOxh0j3zsG4P2FtoSgDPUg",
    "paymentMethodId": "razorpay",
    "enabled": true
  },

  "defaultCountryShipping": [],

  /// config for after shipping
  "afterShip": {
    "api": "e2e9bae8-ee39-46a9-a084-781d0139274f",
    "tracking_url": "https://fluxstore.aftership.com"
  },

  /// ➡️ lib/common/products.dart
  "productDetail": {
    "height": 0.4,
    "marginTop": 0,
    "safeArea": false,
    "showVideo": true,
    "showBrand": true,
    "showThumbnailAtLeast": 1,
    "layout": "simpleType",
    "borderRadius": 3.0,

    /// Enable this to show review in product description.
    "enableReview": false,
    "attributeImagesSize": 50.0,
    "showSku": true,
    "showStockQuantity": true,
    "showProductCategories": true,
    "showProductTags": true,
    "hideInvalidAttributes": false
  },
  "productVariantLayout": {
    "color": "color",
    "size": "box",
    "height": "option",
    "color-image": "image"
  },
  "productAddons": {
    "allowImageType": true,
    "allowVideoType": true,
    "allowCustomType": true,
    "allowedCustomType": ["png", "pdf", "docx"],
    "allowMultiple": false,
    "fileUploadSizeLimit": 5.0
  },
  "cartDetail": {"minAllowTotalCartValue": 0, "maxAllowQuantity": 10},
  "productVariantLanguage": {
    "en": {
      "color": "Color",
      "size": "Size",
      "height": "Height",
      "color-image": "Color"
    }
  },
  "excludedCategory": 260629627044,
  "saleOffProduct": {"ShowCountDown": true, "Color": "#C7222B"},
  "notStrictVisibleVariant": true,
  "configChat": {"EnableSmartChat": true},
  "smartChat": [
    {"app": "https://wa.me/849908854", "iconData": "whatsapp"},
    {"app": "tel: 040-48211222", "iconData": "phone"},
    // {"app": "sms://8499999999", "iconData": "sms"},
    {"app": "firebase", "iconData": "google"},
    // {
    //   "app": "https://tawk.to/chat/5e5cab81a89cda5a1888d472/default",
    //   "iconData": "facebookMessenger" //ghc163
    // }
  ],
  "adminEmail": "admininspireui@gmail.com",
  "adminName": "InspireUI",

  /// ➡️ lib/common/vendor.dart
  "vendorConfig": {
    "VendorRegister": true,
    "DisableVendorShipping": false,
    "ShowAllVendorMarkers": true,
    "DisableNativeStoreManagement": false,
    "dokan": "my-account?vendor_admin=true",
    "wcfm": "store-manager?vendor_admin=true"
  },

  //lib/common/loading.dart
  "loadingIcon": {"size": 30.0, "type": "fadingCube"},

  //lib/screens/community_Forum
  "baseUrl": "https://nodebbstaging.ghc.health",

  "customerSupportUrl": "whatsapp://send?phone=+919154703345",
};

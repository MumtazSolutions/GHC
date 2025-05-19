/// uid : 15
/// username : "Ridhima GHC"
/// userslug : "ridhima-ghc"
/// email : ""
/// email:confirmed : 0
/// joindate : 1689592298078
/// lastonline : 1690307845907
/// picture : null
/// icon:bgColor : "#009688"
/// fullname : ""
/// location : null
/// birthday : null
/// website : null
/// aboutme : null
/// signature : null
/// uploadedpicture : null
/// profileviews : 1
/// reputation : 1
/// postcount : 14
/// topiccount : 10
/// lastposttime : 1690307845864
/// banned : false
/// banned:expire : 0
/// status : "offline"
/// flags : null
/// followerCount : 1
/// followingCount : 1
/// cover:url : null
/// cover:position : null
/// groupTitle : null
/// mutedUntil : 0
/// mutedReason : null
/// displayname : "Ridhima GHC"
/// groupTitleArray : []
/// icon:text : "R"
/// joindateISO : "2023-07-17T11:11:38.078Z"
/// lastonlineISO : "2023-07-25T17:57:25.907Z"
/// banned_until : 0
/// banned_until_readable : "Not Banned"
/// muted : false

class GetProfileModel {
  GetProfileModel({
      this.uid, 
      this.username, 
      this.userslug, 
      this.email, 
      this.emailconfirmed, 
      this.joindate, 
      this.lastonline, 
      this.picture, 
      this.iconbgColor, 
      this.fullname, 
      this.location, 
      this.birthday, 
      this.website, 
      this.aboutme, 
      this.signature, 
      this.uploadedpicture, 
      this.profileviews, 
      this.reputation, 
      this.postcount, 
      this.topiccount, 
      this.lastposttime, 
      this.banned, 
      this.bannedexpire, 
      this.status, 
      this.flags, 
      this.followerCount, 
      this.followingCount, 
      this.coverurl, 
      this.coverposition, 
      this.groupTitle, 
      this.mutedUntil, 
      this.mutedReason, 
      this.displayname, 
      this.groupTitleArray, 
      this.icontext, 
      this.joindateISO, 
      this.lastonlineISO, 
      this.bannedUntil, 
      this.bannedUntilReadable, 
      this.muted,});

  GetProfileModel.fromJson(dynamic json) {
    uid = json['uid'];
    username = json['username'];
    userslug = json['userslug'];
    email = json['email'];
    emailconfirmed = json['email:confirmed'];
    joindate = json['joindate'];
    lastonline = json['lastonline'];
    picture = json['picture'];
    iconbgColor = json['icon:bgColor'];
    fullname = json['fullname'];
    location = json['location'];
    birthday = json['birthday'];
    website = json['website'];
    aboutme = json['aboutme'];
    signature = json['signature'];
    uploadedpicture = json['uploadedpicture'];
    profileviews = json['profileviews'];
    reputation = json['reputation'];
    postcount = json['postcount'];
    topiccount = json['topiccount'];
    lastposttime = json['lastposttime'];
    banned = json['banned'];
    bannedexpire = json['banned:expire'];
    status = json['status'];
    flags = json['flags'];
    followerCount = json['followerCount'];
    followingCount = json['followingCount'];
    coverurl = json['cover:url'];
    coverposition = json['cover:position'];
    groupTitle = json['groupTitle'];
    mutedUntil = json['mutedUntil'];
    mutedReason = json['mutedReason'];
    displayname = json['displayname'];
    // if (json['groupTitleArray'] != null) {
    //   groupTitleArray = [];
    //   json['groupTitleArray'].forEach((v) {
    //     groupTitleArray?.add(Dynamic.fromJson(v));
    //   });
    // }
    icontext = json['icon:text'];
    joindateISO = json['joindateISO'];
    lastonlineISO = json['lastonlineISO'];
    bannedUntil = json['banned_until'];
    bannedUntilReadable = json['banned_until_readable'];
    muted = json['muted'];
  }
  num? uid;
  String? username;
  String? userslug;
  String? email;
  num? emailconfirmed;
  num? joindate;
  num? lastonline;
  dynamic picture;
  String? iconbgColor;
  String? fullname;
  dynamic location;
  dynamic birthday;
  dynamic website;
  dynamic aboutme;
  dynamic signature;
  dynamic uploadedpicture;
  num? profileviews;
  num? reputation;
  num? postcount;
  num? topiccount;
  num? lastposttime;
  bool? banned;
  num? bannedexpire;
  String? status;
  dynamic flags;
  num? followerCount;
  num? followingCount;
  dynamic coverurl;
  dynamic coverposition;
  dynamic groupTitle;
  num? mutedUntil;
  dynamic mutedReason;
  String? displayname;
  List<dynamic>? groupTitleArray;
  String? icontext;
  String? joindateISO;
  String? lastonlineISO;
  num? bannedUntil;
  String? bannedUntilReadable;
  bool? muted;
GetProfileModel copyWith({  num? uid,
  String? username,
  String? userslug,
  String? email,
  num? emailconfirmed,
  num? joindate,
  num? lastonline,
  dynamic picture,
  String? iconbgColor,
  String? fullname,
  dynamic location,
  dynamic birthday,
  dynamic website,
  dynamic aboutme,
  dynamic signature,
  dynamic uploadedpicture,
  num? profileviews,
  num? reputation,
  num? postcount,
  num? topiccount,
  num? lastposttime,
  bool? banned,
  num? bannedexpire,
  String? status,
  dynamic flags,
  num? followerCount,
  num? followingCount,
  dynamic coverurl,
  dynamic coverposition,
  dynamic groupTitle,
  num? mutedUntil,
  dynamic mutedReason,
  String? displayname,
  List<dynamic>? groupTitleArray,
  String? icontext,
  String? joindateISO,
  String? lastonlineISO,
  num? bannedUntil,
  String? bannedUntilReadable,
  bool? muted,
}) => GetProfileModel(  uid: uid ?? this.uid,
  username: username ?? this.username,
  userslug: userslug ?? this.userslug,
  email: email ?? this.email,
  emailconfirmed: emailconfirmed ?? this.emailconfirmed,
  joindate: joindate ?? this.joindate,
  lastonline: lastonline ?? this.lastonline,
  picture: picture ?? this.picture,
  iconbgColor: iconbgColor ?? this.iconbgColor,
  fullname: fullname ?? this.fullname,
  location: location ?? this.location,
  birthday: birthday ?? this.birthday,
  website: website ?? this.website,
  aboutme: aboutme ?? this.aboutme,
  signature: signature ?? this.signature,
  uploadedpicture: uploadedpicture ?? this.uploadedpicture,
  profileviews: profileviews ?? this.profileviews,
  reputation: reputation ?? this.reputation,
  postcount: postcount ?? this.postcount,
  topiccount: topiccount ?? this.topiccount,
  lastposttime: lastposttime ?? this.lastposttime,
  banned: banned ?? this.banned,
  bannedexpire: bannedexpire ?? this.bannedexpire,
  status: status ?? this.status,
  flags: flags ?? this.flags,
  followerCount: followerCount ?? this.followerCount,
  followingCount: followingCount ?? this.followingCount,
  coverurl: coverurl ?? this.coverurl,
  coverposition: coverposition ?? this.coverposition,
  groupTitle: groupTitle ?? this.groupTitle,
  mutedUntil: mutedUntil ?? this.mutedUntil,
  mutedReason: mutedReason ?? this.mutedReason,
  displayname: displayname ?? this.displayname,
  groupTitleArray: groupTitleArray ?? this.groupTitleArray,
  icontext: icontext ?? this.icontext,
  joindateISO: joindateISO ?? this.joindateISO,
  lastonlineISO: lastonlineISO ?? this.lastonlineISO,
  bannedUntil: bannedUntil ?? this.bannedUntil,
  bannedUntilReadable: bannedUntilReadable ?? this.bannedUntilReadable,
  muted: muted ?? this.muted,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['username'] = username;
    map['userslug'] = userslug;
    map['email'] = email;
    map['email:confirmed'] = emailconfirmed;
    map['joindate'] = joindate;
    map['lastonline'] = lastonline;
    map['picture'] = picture;
    map['icon:bgColor'] = iconbgColor;
    map['fullname'] = fullname;
    map['location'] = location;
    map['birthday'] = birthday;
    map['website'] = website;
    map['aboutme'] = aboutme;
    map['signature'] = signature;
    map['uploadedpicture'] = uploadedpicture;
    map['profileviews'] = profileviews;
    map['reputation'] = reputation;
    map['postcount'] = postcount;
    map['topiccount'] = topiccount;
    map['lastposttime'] = lastposttime;
    map['banned'] = banned;
    map['banned:expire'] = bannedexpire;
    map['status'] = status;
    map['flags'] = flags;
    map['followerCount'] = followerCount;
    map['followingCount'] = followingCount;
    map['cover:url'] = coverurl;
    map['cover:position'] = coverposition;
    map['groupTitle'] = groupTitle;
    map['mutedUntil'] = mutedUntil;
    map['mutedReason'] = mutedReason;
    map['displayname'] = displayname;
    if (groupTitleArray != null) {
      map['groupTitleArray'] = groupTitleArray?.map((v) => v.toJson()).toList();
    }
    map['icon:text'] = icontext;
    map['joindateISO'] = joindateISO;
    map['lastonlineISO'] = lastonlineISO;
    map['banned_until'] = bannedUntil;
    map['banned_until_readable'] = bannedUntilReadable;
    map['muted'] = muted;
    return map;
  }

}
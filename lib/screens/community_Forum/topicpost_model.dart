class TopicPost {
  num? cid;
  num? lastposttime;
  num? mainPid;
  num? postcount;
  String? slug;
  List<Tags>? tags;
  num? tid;
  num? timestamp;
  String? title;
  num? uid;
  num? viewcount;
  num? postercount;
  num? deleted;
  bool? locked;
  bool? pinned;
  num? pinExpiry;
  num? upvotes;
  num? downvotes;
  num? deleterUid;
  String? titleRaw;
  String? timestampISO;
  bool? scheduled;
  String? lastposttimeISO;
  String? pinExpiryISO;
  num? votes;
  dynamic teaserPid;
  List<dynamic>? thumbs;
  Category? category;
  User? user;
  dynamic teaser;
  bool? isOwner;
  bool? ignored;
  bool? unread;
  num? bookmark;
  bool? unreplied;
  List<dynamic>? icons;
  num? index;

  num? pid;
  String? content;
  num? timestampPost;
  bool? deletedPost;
  num? upvotesPost;
  num? downvotesPost;
  num? repliesPost;
  num? votesPost;
  String? timestampISOPost;
  User? userPost;
  Topic? topicPost;
  bool? isMainPost;

  TopicPost({
    this.cid,
    this.lastposttime,
    this.mainPid,
    this.postcount,
    this.slug,
    this.tags,
    this.tid,
    this.timestamp,
    this.title,
    this.uid,
    this.viewcount,
    this.postercount,
    this.deleted,
    this.locked,
    this.pinned,
    this.pinExpiry,
    this.upvotes,
    this.downvotes,
    this.deleterUid,
    this.titleRaw,
    this.timestampISO,
    this.scheduled,
    this.lastposttimeISO,
    this.pinExpiryISO,
    this.votes,
    this.teaserPid,
    this.thumbs,
    this.category,
    this.user,
    this.teaser,
    this.isOwner,
    this.ignored,
    this.unread,
    this.bookmark,
    this.unreplied,
    this.icons,
    this.index,
    this.pid,
    this.content,
    this.timestampPost,
    this.deletedPost,
    this.upvotesPost,
    this.downvotesPost,
    this.repliesPost,
    this.votesPost,
    this.timestampISOPost,
    this.userPost,
    this.topicPost,
    this.isMainPost,
  });

  factory TopicPost.fromJson(Map<String, dynamic> json) {
    return TopicPost(
      cid: json['cid'],
      lastposttime: json['lastposttime'],
      mainPid: json['mainPid'],
      postcount: json['postcount'],
      slug: json['slug'],
      tags: json['tags'] != null
          ? List<Tags>.from(json['tags'].map(Tags.fromJson))
          : null,
      tid: json['tid'],
      timestamp: json['timestamp'],
      title: json['title'],
      uid: json['uid'],
      viewcount: json['viewcount'],
      postercount: json['postercount'],
      deleterUid: json['deleterUid'],
      thumbs: json['thumbs'] != null
          ? List<dynamic>.from(json['thumbs'].map((t) => t))
          : null,
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      teaser: json['teaser'],
      isOwner: json['isOwner'],
      ignored: json['ignored'],
      unread: json['unread'],
      unreplied: json['unreplied'],
      icons: json['icons'] != null
          ? List<dynamic>.from(json['icons'].map((i) => i))
          : null,
      index: json['index'],
      pid: json['pid'],
      content: json['content'],
      timestampPost: json['timestampPost'],
      deletedPost: json['deletedPost'],
      upvotesPost: json['upvotesPost'],
      downvotesPost: json['downvotesPost'],
      repliesPost: json['repliesPost'],
      votesPost: json['votesPost'],
      timestampISOPost: json['timestampISOPost'],
      userPost:
          json['userPost'] != null ? User.fromJson(json['userPost']) : null,
      topicPost:
          json['topicPost'] != null ? Topic.fromJson(json['topicPost']) : null,
      isMainPost: json['isMainPost'],
    );
  }

  Map<String, dynamic> toJson() {
    final  data = <String, dynamic>{};
    data['cid'] = cid;
    data['lastposttime'] = lastposttime;
    data['mainPid'] = mainPid;
    data['postcount'] = postcount;
    data['slug'] = slug;
    if (tags != null) {
      data['tags'] = tags!.map((t) => t.toJson()).toList();
    }
    data['tid'] = tid;
    data['timestamp'] = timestamp;
    data['title'] = title;
    data['uid'] = uid;
    data['viewcount'] = viewcount;
    data['postercount'] = postercount;
    data['deleted'] = deleted;
    data['locked'] = locked;
    data['pinned'] = pinned;
    data['pinExpiry'] = pinExpiry;
    data['upvotes'] = upvotes;
    data['downvotes'] = downvotes;
    data['deleterUid'] = deleterUid;
    data['titleRaw'] = titleRaw;
    data['timestampISO'] = timestampISO;
    data['scheduled'] = scheduled;
    data['lastposttimeISO'] = lastposttimeISO;
    data['pinExpiryISO'] = pinExpiryISO;
    data['votes'] = votes;
    data['teaserPid'] = teaserPid;
    if (thumbs != null) {
      data['thumbs'] = thumbs!.map((t) => t).toList();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['teaser'] = teaser;
    data['isOwner'] = isOwner;
    data['ignored'] = ignored;
    data['unread'] = unread;
    data['bookmark'] = bookmark;
    data['unreplied'] = unreplied;
    if (icons != null) {
      data['icons'] = icons!.map((i) => i).toList();
    }
    data['index'] = index;
    data['pid'] = pid;
    data['content'] = content;
    data['timestampPost'] = timestampPost;
    data['deletedPost'] = deletedPost;
    data['upvotesPost'] = upvotesPost;
    data['downvotesPost'] = downvotesPost;
    data['repliesPost'] = repliesPost;
    data['votesPost'] = votesPost;
    data['timestampISOPost'] = timestampISOPost;
    if (userPost != null) {
      data['userPost'] = userPost!.toJson();
    }
    if (topicPost != null) {
      data['topicPost'] = topicPost!.toJson();
    }
    data['isMainPost'] = isMainPost;
    return data;
  }
}

class Widgets {
  Widgets({
    this.footer,
  });

  Widgets.fromJson(dynamic json) {
    if (json['footer'] != null) {
      footer = [];
      json['footer'].forEach((v) {
        footer?.add(Footer.fromJson(v));
      });
    }
  }
  List<Footer>? footer;
  Widgets copyWith({
    List<Footer>? footer,
  }) =>
      Widgets(
        footer: footer ?? this.footer,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (footer != null) {
      map['footer'] = footer?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// html : "<footer id=\"footer\" class=\"container footer\">\r\n\t<div>\r\n\t\tPowered by <a target=\"_blank\" href=\"https://nodebb.org\">NodeBB</a> | <a target=\"_blank\" href=\"//github.com/NodeBB/NodeBB/graphs/contributors\">Contributors</a>\r\n\t</div>\r\n</footer>"

class Footer {
  Footer({
    this.html,
  });

  Footer.fromJson(dynamic json) {
    html = json['html'];
  }
  String? html;
  Footer copyWith({
    String? html,
  }) =>
      Footer(
        html: html ?? this.html,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['html'] = html;
    return map;
  }
}

/// tags : {"meta":[{"name":"viewport","content":"width&#x3D;device-width, initial-scale&#x3D;1.0"},{"name":"content-type","content":"text/html; charset=UTF-8","noEscape":true},{"name":"apple-mobile-web-app-capable","content":"yes"},{"name":"mobile-web-app-capable","content":"yes"},{"property":"og:site_name","content":"NodeBB"},{"name":"msapplication-badge","content":"frequency=30; polling-uri=${Configurations.baseUrl}/sitemap.xml","noEscape":true},{"name":"theme-color","content":"#ffffff"},{"property":"og:image","content":"${Configurations.baseUrl}/assets/images/logo@3x.png","noEscape":true},{"property":"og:image:url","content":"${Configurations.baseUrl}/assets/images/logo@3x.png","noEscape":true},{"property":"og:image:width","content":"963"},{"property":"og:image:height","content":"225"},{"content":"NodeBB","property":"og:title"},{"content":"${Configurations.baseUrl}/api/user/ridhima-ghc/posts","property":"og:url"}],"link":[{"rel":"icon","type":"image/x-icon","href":"/assets/uploads/system/favicon.ico?v&#x3D;eeahodnfqoe"},{"rel":"manifest","href":"/manifest.webmanifest","crossorigin":"use-credentials"},{"rel":"search","type":"application/opensearchdescription+xml","title":"NodeBB","href":"/osd.xml"},{"rel":"apple-touch-icon","href":"/assets/images/touch/512.png"},{"rel":"icon","sizes":"36x36","href":"/assets/images/touch/36.png"},{"rel":"icon","sizes":"48x48","href":"/assets/images/touch/48.png"},{"rel":"icon","sizes":"72x72","href":"/assets/images/touch/72.png"},{"rel":"icon","sizes":"96x96","href":"/assets/images/touch/96.png"},{"rel":"icon","sizes":"144x144","href":"/assets/images/touch/144.png"},{"rel":"icon","sizes":"192x192","href":"/assets/images/touch/192.png"},{"rel":"icon","sizes":"512x512","href":"/assets/images/touch/512.png"},{"rel":"prefetch","href":"/assets/src/modules/composer.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/uploads.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/drafts.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/tags.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/categoryList.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/resize.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/autocomplete.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/templates/composer.tpl?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/language/en-GB/topic.json?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/language/en-GB/modules.json?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/language/en-GB/tags.json?v&#x3D;eeahodnfqoe"},{"rel":"stylesheet","href":"${Configurations.baseUrl}/assets/plugins/nodebb-plugin-emoji/emoji/styles.css?v&#x3D;eeahodnfqoe"}]}

class Header {
  Header({
    this.tags,
  });

  Header.fromJson(dynamic json) {
    tags = json['tags'] != null ? Tags.fromJson(json['tags']) : null;
  }
  Tags? tags;
  Header copyWith({
    Tags? tags,
  }) =>
      Header(
        tags: tags ?? this.tags,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (tags != null) {
      map['tags'] = tags?.toJson();
    }
    return map;
  }
}

/// meta : [{"name":"viewport","content":"width&#x3D;device-width, initial-scale&#x3D;1.0"},{"name":"content-type","content":"text/html; charset=UTF-8","noEscape":true},{"name":"apple-mobile-web-app-capable","content":"yes"},{"name":"mobile-web-app-capable","content":"yes"},{"property":"og:site_name","content":"NodeBB"},{"name":"msapplication-badge","content":"frequency=30; polling-uri=${Configurations.baseUrl}/sitemap.xml","noEscape":true},{"name":"theme-color","content":"#ffffff"},{"property":"og:image","content":"${Configurations.baseUrl}/assets/images/logo@3x.png","noEscape":true},{"property":"og:image:url","content":"${Configurations.baseUrl}/assets/images/logo@3x.png","noEscape":true},{"property":"og:image:width","content":"963"},{"property":"og:image:height","content":"225"},{"content":"NodeBB","property":"og:title"},{"content":"${Configurations.baseUrl}/api/user/ridhima-ghc/posts","property":"og:url"}]
/// link : [{"rel":"icon","type":"image/x-icon","href":"/assets/uploads/system/favicon.ico?v&#x3D;eeahodnfqoe"},{"rel":"manifest","href":"/manifest.webmanifest","crossorigin":"use-credentials"},{"rel":"search","type":"application/opensearchdescription+xml","title":"NodeBB","href":"/osd.xml"},{"rel":"apple-touch-icon","href":"/assets/images/touch/512.png"},{"rel":"icon","sizes":"36x36","href":"/assets/images/touch/36.png"},{"rel":"icon","sizes":"48x48","href":"/assets/images/touch/48.png"},{"rel":"icon","sizes":"72x72","href":"/assets/images/touch/72.png"},{"rel":"icon","sizes":"96x96","href":"/assets/images/touch/96.png"},{"rel":"icon","sizes":"144x144","href":"/assets/images/touch/144.png"},{"rel":"icon","sizes":"192x192","href":"/assets/images/touch/192.png"},{"rel":"icon","sizes":"512x512","href":"/assets/images/touch/512.png"},{"rel":"prefetch","href":"/assets/src/modules/composer.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/uploads.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/drafts.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/tags.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/categoryList.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/resize.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/src/modules/composer/autocomplete.js?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/templates/composer.tpl?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/language/en-GB/topic.json?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/language/en-GB/modules.json?v&#x3D;eeahodnfqoe"},{"rel":"prefetch","href":"/assets/language/en-GB/tags.json?v&#x3D;eeahodnfqoe"},{"rel":"stylesheet","href":"${Configurations.baseUrl}/assets/plugins/nodebb-plugin-emoji/emoji/styles.css?v&#x3D;eeahodnfqoe"}]

class Tags {
  Tags({
    this.meta,
    this.link,
  });

  Tags.fromJson(dynamic json) {
    if (json['meta'] != null) {
      meta = [];
      json['meta'].forEach((v) {
        meta?.add(Meta.fromJson(v));
      });
    }
    if (json['link'] != null) {
      link = [];
      json['link'].forEach((v) {
        link?.add(Link.fromJson(v));
      });
    }
  }
  List<Meta>? meta;
  List<Link>? link;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (meta != null) {
      map['meta'] = meta?.map((v) => v.toJson()).toList();
    }
    if (link != null) {
      map['link'] = link?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// rel : "icon"
/// type : "image/x-icon"
/// href : "/assets/uploads/system/favicon.ico?v&#x3D;eeahodnfqoe"

class Link {
  Link({
    this.rel,
    this.type,
    this.href,
  });

  Link.fromJson(dynamic json) {
    rel = json['rel'];
    type = json['type'];
    href = json['href'];
  }
  String? rel;
  String? type;
  String? href;
  Link copyWith({
    String? rel,
    String? type,
    String? href,
  }) =>
      Link(
        rel: rel ?? this.rel,
        type: type ?? this.type,
        href: href ?? this.href,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rel'] = rel;
    map['type'] = type;
    map['href'] = href;
    return map;
  }
}

/// name : "viewport"
/// content : "width&#x3D;device-width, initial-scale&#x3D;1.0"

class Meta {
  Meta({
    this.name,
    this.content,
  });

  Meta.fromJson(dynamic json) {
    name = json['name'];
    content = json['content'];
  }
  String? name;
  String? content;
  Meta copyWith({
    String? name,
    String? content,
  }) =>
      Meta(
        name: name ?? this.name,
        content: content ?? this.content,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['content'] = content;
    return map;
  }
}

/// name : "account/posts"
/// account/posts : true

class Template {
  Template({
    this.name,
    this.accountposts,
  });

  Template.fromJson(dynamic json) {
    name = json['name'];
    accountposts = json['account/posts'];
  }
  String? name;
  bool? accountposts;
  Template copyWith({
    String? name,
    bool? accountposts,
  }) =>
      Template(
        name: name ?? this.name,
        accountposts: accountposts ?? this.accountposts,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['account/posts'] = accountposts;
    return map;
  }
}

/// uid : 0
/// username : "[[global:guest]]"
/// picture : ""
/// icon:text : "?"
/// icon:bgColor : "#aaa"

class LoggedInUser {
  LoggedInUser({
    this.uid,
    this.username,
    this.picture,
    this.icontext,
    this.iconbgColor,
  });

  LoggedInUser.fromJson(dynamic json) {
    uid = json['uid'];
    username = json['username'];
    picture = json['picture'];
    icontext = json['icon:text'];
    iconbgColor = json['icon:bgColor'];
  }
  num? uid;
  String? username;
  String? picture;
  String? icontext;
  String? iconbgColor;
  LoggedInUser copyWith({
    num? uid,
    String? username,
    String? picture,
    String? icontext,
    String? iconbgColor,
  }) =>
      LoggedInUser(
        uid: uid ?? this.uid,
        username: username ?? this.username,
        picture: picture ?? this.picture,
        icontext: icontext ?? this.icontext,
        iconbgColor: iconbgColor ?? this.iconbgColor,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['username'] = username;
    map['picture'] = picture;
    map['icon:text'] = icontext;
    map['icon:bgColor'] = iconbgColor;
    return map;
  }
}

/// url : "/user/ridhima-ghc/posts?sort=votes"
/// name : "[[global:votes]]"
/// selected : false

class SortOptions {
  SortOptions({
    this.url,
    this.name,
    this.selected,
  });

  SortOptions.fromJson(dynamic json) {
    url = json['url'];
    name = json['name'];
    selected = json['selected'];
  }
  String? url;
  String? name;
  bool? selected;
  SortOptions copyWith({
    String? url,
    String? name,
    bool? selected,
  }) =>
      SortOptions(
        url: url ?? this.url,
        name: name ?? this.name,
        selected: selected ?? this.selected,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['name'] = name;
    map['selected'] = selected;
    return map;
  }
}

/// text : "[[global:home]]"
/// url : "/"

class Breadcrumbs {
  Breadcrumbs({
    this.text,
    this.url,
  });

  Breadcrumbs.fromJson(dynamic json) {
    text = json['text'];
    url = json['url'];
  }
  String? text;
  String? url;
  Breadcrumbs copyWith({
    String? text,
    String? url,
  }) =>
      Breadcrumbs(
        text: text ?? this.text,
        url: url ?? this.url,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['text'] = text;
    map['url'] = url;
    return map;
  }
}

/// prev : {"page":1,"active":false}
/// next : {"page":1,"active":false}
/// first : {"page":1,"active":true}
/// last : {"page":1,"active":false}
/// rel : []
/// pages : []
/// currentPage : 1
/// pageCount : 1

class Pagination {
  Pagination({
    this.prev,
    this.next,
    this.first,
    this.last,
    this.rel,
    this.pages,
    this.currentPage,
    this.pageCount,
  });

  Pagination.fromJson(dynamic json) {
    prev = json['prev'] != null ? Prev.fromJson(json['prev']) : null;
    next = json['next'] != null ? Next.fromJson(json['next']) : null;
    first = json['first'] != null ? First.fromJson(json['first']) : null;
    last = json['last'] != null ? Last.fromJson(json['last']) : null;

    currentPage = json['currentPage'];
    pageCount = json['pageCount'];
  }
  Prev? prev;
  Next? next;
  First? first;
  Last? last;
  List<dynamic>? rel;
  List<dynamic>? pages;
  num? currentPage;
  num? pageCount;
  Pagination copyWith({
    Prev? prev,
    Next? next,
    First? first,
    Last? last,
    List<dynamic>? rel,
    List<dynamic>? pages,
    num? currentPage,
    num? pageCount,
  }) =>
      Pagination(
        prev: prev ?? this.prev,
        next: next ?? this.next,
        first: first ?? this.first,
        last: last ?? this.last,
        rel: rel ?? this.rel,
        pages: pages ?? this.pages,
        currentPage: currentPage ?? this.currentPage,
        pageCount: pageCount ?? this.pageCount,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (prev != null) {
      map['prev'] = prev?.toJson();
    }
    if (next != null) {
      map['next'] = next?.toJson();
    }
    if (first != null) {
      map['first'] = first?.toJson();
    }
    if (last != null) {
      map['last'] = last?.toJson();
    }
    if (rel != null) {
      map['rel'] = rel?.map((v) => v.toJson()).toList();
    }
    if (pages != null) {
      map['pages'] = pages?.map((v) => v.toJson()).toList();
    }
    map['currentPage'] = currentPage;
    map['pageCount'] = pageCount;
    return map;
  }
}

/// page : 1
/// active : false

class Last {
  Last({
    this.page,
    this.active,
  });

  Last.fromJson(dynamic json) {
    page = json['page'];
    active = json['active'];
  }
  num? page;
  bool? active;
  Last copyWith({
    num? page,
    bool? active,
  }) =>
      Last(
        page: page ?? this.page,
        active: active ?? this.active,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = page;
    map['active'] = active;
    return map;
  }
}

/// page : 1
/// active : true

class First {
  First({
    this.page,
    this.active,
  });

  First.fromJson(dynamic json) {
    page = json['page'];
    active = json['active'];
  }
  num? page;
  bool? active;
  First copyWith({
    num? page,
    bool? active,
  }) =>
      First(
        page: page ?? this.page,
        active: active ?? this.active,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = page;
    map['active'] = active;
    return map;
  }
}

/// page : 1
/// active : false

class Next {
  Next({
    this.page,
    this.active,
  });

  Next.fromJson(dynamic json) {
    page = json['page'];
    active = json['active'];
  }
  num? page;
  bool? active;
  Next copyWith({
    num? page,
    bool? active,
  }) =>
      Next(
        page: page ?? this.page,
        active: active ?? this.active,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = page;
    map['active'] = active;
    return map;
  }
}

/// page : 1
/// active : false

class Prev {
  Prev({
    this.page,
    this.active,
  });

  Prev.fromJson(dynamic json) {
    page = json['page'];
    active = json['active'];
  }
  num? page;
  bool? active;
  Prev copyWith({
    num? page,
    bool? active,
  }) =>
      Prev(
        page: page ?? this.page,
        active: active ?? this.active,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = page;
    map['active'] = active;
    return map;
  }
}

/// pid : 66
/// tid : 29
/// content : "Content not required"
/// uid : 15
/// timestamp : 1690391056477
/// deleted : false
/// upvotes : 0
/// downvotes : 0
/// replies : 0
/// votes : 0
/// timestampISO : "2023-07-26T17:04:16.477Z"
/// user : {"uid":15,"username":"Ridhima GHC","userslug":"ridhima-ghc","picture":null,"status":"offline","displayname":"Ridhima GHC","icon:text":"R","icon:bgColor":"#009688"}
/// topic : {"uid":15,"tid":29,"title":"I want to add a button on this form that add the details to a Card in a ListView on a different page. How can I do this?","cid":14,"tags":[{"value":"hair","valueEscaped":"hair","valueEncoded":"hair","class":"hair"}],"slug":"29/i-want-to-add-a-button-on-this-form-that-add-the-details-to-a-card-in-a-listview-on-a-different-page-how-can-i-do-this","deleted":0,"scheduled":false,"postcount":1,"mainPid":66,"teaserPid":null,"timestamp":1690391056477,"titleRaw":"I want to add a button on this form that add the details to a Card in a ListView on a different page. How can I do this?","timestampISO":"2023-07-26T17:04:16.477Z"}
/// category : {"cid":14,"name":"Hair Care","icon":"https://s3.ap-south-1.amazonaws.com/cdn.ghc.health/7d3adc26-c68c-44fd-a67b-10121faffe90.png","slug":"14/hair-care","parentCid":0,"bgColor":"#DC9656","color":"#ffffff","backgroundImage":"","imageClass":"cover"}
/// isMainPost : true

class Posts {
  Posts({
    this.pid,
    this.tid,
    this.content,
    this.uid,
    this.timestamp,
    this.deleted,
    this.upvotes,
    this.downvotes,
    this.replies,
    this.votes,
    this.timestampISO,
    this.user,
    this.topic,
    this.category,
    this.isMainPost,
  });

  Posts.fromJson(dynamic json) {
    pid = json['pid'];
    tid = json['tid'];
    content = json['content'];
    uid = json['uid'];
    timestamp = json['timestamp'];
    deleted = json['deleted'];
    upvotes = json['upvotes'];
    downvotes = json['downvotes'];
    replies = json['replies'];
    votes = json['votes'];
    timestampISO = json['timestampISO'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    topic = json['topic'] != null ? Topic.fromJson(json['topic']) : null;
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    isMainPost = json['isMainPost'];
  }
  num? pid;
  num? tid;
  String? content;
  num? uid;
  num? timestamp;
  bool? deleted;
  num? upvotes;
  num? downvotes;
  num? replies;
  num? votes;
  String? timestampISO;
  User? user;
  Topic? topic;
  Category? category;
  bool? isMainPost;
  Posts copyWith({
    num? pid,
    num? tid,
    String? content,
    num? uid,
    num? timestamp,
    bool? deleted,
    num? upvotes,
    num? downvotes,
    num? replies,
    num? votes,
    String? timestampISO,
    User? user,
    Topic? topic,
    Category? category,
    bool? isMainPost,
  }) =>
      Posts(
        pid: pid ?? this.pid,
        tid: tid ?? this.tid,
        content: content ?? this.content,
        uid: uid ?? this.uid,
        timestamp: timestamp ?? this.timestamp,
        deleted: deleted ?? this.deleted,
        upvotes: upvotes ?? this.upvotes,
        downvotes: downvotes ?? this.downvotes,
        replies: replies ?? this.replies,
        votes: votes ?? this.votes,
        timestampISO: timestampISO ?? this.timestampISO,
        user: user ?? this.user,
        topic: topic ?? this.topic,
        category: category ?? this.category,
        isMainPost: isMainPost ?? this.isMainPost,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['pid'] = pid;
    map['tid'] = tid;
    map['content'] = content;
    map['uid'] = uid;
    map['timestamp'] = timestamp;
    map['deleted'] = deleted;
    map['upvotes'] = upvotes;
    map['downvotes'] = downvotes;
    map['replies'] = replies;
    map['votes'] = votes;
    map['timestampISO'] = timestampISO;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (topic != null) {
      map['topic'] = topic?.toJson();
    }
    if (category != null) {
      map['category'] = category?.toJson();
    }
    map['isMainPost'] = isMainPost;
    return map;
  }
}

/// cid : 14
/// name : "Hair Care"
/// icon : "https://s3.ap-south-1.amazonaws.com/cdn.ghc.health/7d3adc26-c68c-44fd-a67b-10121faffe90.png"
/// slug : "14/hair-care"
/// parentCid : 0
/// bgColor : "#DC9656"
/// color : "#ffffff"
/// backgroundImage : ""
/// imageClass : "cover"

class Category {
  Category({
    this.cid,
    this.name,
    this.icon,
    this.slug,
    this.parentCid,
    this.bgColor,
    this.color,
    this.backgroundImage,
    this.imageClass,
  });

  Category.fromJson(dynamic json) {
    cid = json['cid'];
    name = json['name'];
    icon = json['icon'];
    slug = json['slug'];
    parentCid = json['parentCid'];
    bgColor = json['bgColor'];
    color = json['color'];
    backgroundImage = json['backgroundImage'];
    imageClass = json['imageClass'];
  }
  num? cid;
  String? name;
  String? icon;
  String? slug;
  num? parentCid;
  String? bgColor;
  String? color;
  String? backgroundImage;
  String? imageClass;
  Category copyWith({
    num? cid,
    String? name,
    String? icon,
    String? slug,
    num? parentCid,
    String? bgColor,
    String? color,
    String? backgroundImage,
    String? imageClass,
  }) =>
      Category(
        cid: cid ?? this.cid,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        slug: slug ?? this.slug,
        parentCid: parentCid ?? this.parentCid,
        bgColor: bgColor ?? this.bgColor,
        color: color ?? this.color,
        backgroundImage: backgroundImage ?? this.backgroundImage,
        imageClass: imageClass ?? this.imageClass,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['cid'] = cid;
    map['name'] = name;
    map['icon'] = icon;
    map['slug'] = slug;
    map['parentCid'] = parentCid;
    map['bgColor'] = bgColor;
    map['color'] = color;
    map['backgroundImage'] = backgroundImage;
    map['imageClass'] = imageClass;
    return map;
  }
}

/// uid : 15
/// tid : 29
/// title : "I want to add a button on this form that add the details to a Card in a ListView on a different page. How can I do this?"
/// cid : 14
/// tags : [{"value":"hair","valueEscaped":"hair","valueEncoded":"hair","class":"hair"}]
/// slug : "29/i-want-to-add-a-button-on-this-form-that-add-the-details-to-a-card-in-a-listview-on-a-different-page-how-can-i-do-this"
/// deleted : 0
/// scheduled : false
/// postcount : 1
/// mainPid : 66
/// teaserPid : null
/// timestamp : 1690391056477
/// titleRaw : "I want to add a button on this form that add the details to a Card in a ListView on a different page. How can I do this?"
/// timestampISO : "2023-07-26T17:04:16.477Z"

class Topic {
  Topic({
    this.uid,
    this.tid,
    this.title,
    this.cid,
    this.tags,
    this.slug,
    this.deleted,
    this.scheduled,
    this.postcount,
    this.mainPid,
    this.teaserPid,
    this.timestamp,
    this.titleRaw,
    this.timestampISO,
  });

  Topic.fromJson(dynamic json) {
    uid = json['uid'];
    tid = json['tid'];
    title = json['title'];
    cid = json['cid'];
    if (json['tags'] != null) {
      tags = [];
      json['tags'].forEach((v) {
        tags?.add(Tags.fromJson(v));
      });
    }
    slug = json['slug'];
    deleted = json['deleted'];
    scheduled = json['scheduled'];
    postcount = json['postcount'];
    mainPid = json['mainPid'];
    teaserPid = json['teaserPid'];
    timestamp = json['timestamp'];
    titleRaw = json['titleRaw'];
    timestampISO = json['timestampISO'];
  }
  num? uid;
  num? tid;
  String? title;
  num? cid;
  List<Tags>? tags;
  String? slug;
  num? deleted;
  bool? scheduled;
  num? postcount;
  num? mainPid;
  dynamic teaserPid;
  num? timestamp;
  String? titleRaw;
  String? timestampISO;
  Topic copyWith({
    num? uid,
    num? tid,
    String? title,
    num? cid,
    List<Tags>? tags,
    String? slug,
    num? deleted,
    bool? scheduled,
    num? postcount,
    num? mainPid,
    dynamic teaserPid,
    num? timestamp,
    String? titleRaw,
    String? timestampISO,
  }) =>
      Topic(
        uid: uid ?? this.uid,
        tid: tid ?? this.tid,
        title: title ?? this.title,
        cid: cid ?? this.cid,
        tags: tags ?? this.tags,
        slug: slug ?? this.slug,
        deleted: deleted ?? this.deleted,
        scheduled: scheduled ?? this.scheduled,
        postcount: postcount ?? this.postcount,
        mainPid: mainPid ?? this.mainPid,
        teaserPid: teaserPid ?? this.teaserPid,
        timestamp: timestamp ?? this.timestamp,
        titleRaw: titleRaw ?? this.titleRaw,
        timestampISO: timestampISO ?? this.timestampISO,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['tid'] = tid;
    map['title'] = title;
    map['cid'] = cid;
    if (tags != null) {
      map['tags'] = tags?.map((v) => v.toJson()).toList();
    }
    map['slug'] = slug;
    map['deleted'] = deleted;
    map['scheduled'] = scheduled;
    map['postcount'] = postcount;
    map['mainPid'] = mainPid;
    map['teaserPid'] = teaserPid;
    map['timestamp'] = timestamp;
    map['titleRaw'] = titleRaw;
    map['timestampISO'] = timestampISO;
    return map;
  }
}

/// value : "hair"
/// valueEscaped : "hair"
/// valueEncoded : "hair"
/// class : "hair"

// class Tags {
//   Tags({
//       this.value,
//       this.valueEscaped,
//       this.valueEncoded,
//       this.class,});
//
//   Tags.fromJson(dynamic json) {
//     value = json['value'];
//     valueEscaped = json['valueEscaped'];
//     valueEncoded = json['valueEncoded'];
//     class = json['class'];
//   }
//   String? value;
//   String? valueEscaped;
//   String? valueEncoded;
//   String? class;
// Tags copyWith({  String? value,
//   String? valueEscaped,
//   String? valueEncoded,
//   String? class,
// }) => Tags(  value: value ?? this.value,
//   valueEscaped: valueEscaped ?? this.valueEscaped,
//   valueEncoded: valueEncoded ?? this.valueEncoded,
//   class: class ?? this.class,
// );
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['value'] = value;
//     map['valueEscaped'] = valueEscaped;
//     map['valueEncoded'] = valueEncoded;
//     map['class'] = class;
//     return map;
//   }
//
// }

/// uid : 15
/// username : "Ridhima GHC"
/// userslug : "ridhima-ghc"
/// picture : null
/// status : "offline"
/// displayname : "Ridhima GHC"
/// icon:text : "R"
/// icon:bgColor : "#009688"

class User {
  User({
    this.uid,
    this.username,
    this.userslug,
    this.picture,
    this.status,
    this.displayname,
    this.icontext,
    this.iconbgColor,
  });

  User.fromJson(dynamic json) {
    uid = json['uid'];
    username = json['username'];
    userslug = json['userslug'];
    picture = json['picture'];
    status = json['status'];
    displayname = json['displayname'];
    icontext = json['icon:text'];
    iconbgColor = json['icon:bgColor'];
  }
  num? uid;
  String? username;
  String? userslug;
  dynamic picture;
  String? status;
  String? displayname;
  String? icontext;
  String? iconbgColor;
  User copyWith({
    num? uid,
    String? username,
    String? userslug,
    dynamic picture,
    String? status,
    String? displayname,
    String? icontext,
    String? iconbgColor,
  }) =>
      User(
        uid: uid ?? this.uid,
        username: username ?? this.username,
        userslug: userslug ?? this.userslug,
        picture: picture ?? this.picture,
        status: status ?? this.status,
        displayname: displayname ?? this.displayname,
        icontext: icontext ?? this.icontext,
        iconbgColor: iconbgColor ?? this.iconbgColor,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uid'] = uid;
    map['username'] = username;
    map['userslug'] = userslug;
    map['picture'] = picture;
    map['status'] = status;
    map['displayname'] = displayname;
    map['icon:text'] = icontext;
    map['icon:bgColor'] = iconbgColor;
    return map;
  }
}

/// posts : 15
/// best : 0
/// controversial : 0
/// topics : 11
/// groups : 0
/// following : 1
/// followers : 1

class Counts {
  Counts({
    this.posts,
    this.best,
    this.controversial,
    this.topics,
    this.groups,
    this.following,
    this.followers,
  });

  Counts.fromJson(dynamic json) {
    posts = json['posts'];
    best = json['best'];
    controversial = json['controversial'];
    topics = json['topics'];
    groups = json['groups'];
    following = json['following'];
    followers = json['followers'];
  }
  num? posts;
  num? best;
  num? controversial;
  num? topics;
  num? groups;
  num? following;
  num? followers;
  Counts copyWith({
    num? posts,
    num? best,
    num? controversial,
    num? topics,
    num? groups,
    num? following,
    num? followers,
  }) =>
      Counts(
        posts: posts ?? this.posts,
        best: best ?? this.best,
        controversial: controversial ?? this.controversial,
        topics: topics ?? this.topics,
        groups: groups ?? this.groups,
        following: following ?? this.following,
        followers: followers ?? this.followers,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['posts'] = posts;
    map['best'] = best;
    map['controversial'] = controversial;
    map['topics'] = topics;
    map['groups'] = groups;
    map['following'] = following;
    map['followers'] = followers;
    return map;
  }
}

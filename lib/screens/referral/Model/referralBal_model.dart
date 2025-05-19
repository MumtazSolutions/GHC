/// code : "OK"
/// body : {"ledger":[{"id":2503,"createdAt":"2023-06-01T12:40:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"pending","statusId":1,"voucher_code":"0","order":"922411","user":6741000585464},{"id":2497,"createdAt":"2023-05-31T13:25:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"pending","statusId":1,"voucher_code":"0","order":"920867","user":6741000585464},{"id":2495,"createdAt":"2023-05-31T11:30:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"pending","statusId":1,"voucher_code":"0","order":"920634","user":6741000585464},{"id":2456,"createdAt":"2023-05-30T07:00:07.000Z","value":100,"voucher_value":"0","type":"credit","status":"pending","statusId":1,"voucher_code":"0","order":"918506","user":6741000585464},{"id":2424,"createdAt":"2023-05-26T14:40:38.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"912729","user":6741000585464},{"id":2420,"createdAt":"2023-05-26T10:20:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"912215","user":6741000585464},{"id":2418,"createdAt":"2023-05-26T07:10:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"911730","user":6741000585464},{"id":2324,"createdAt":"2023-05-16T10:25:07.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"892991","user":6741000585464},{"id":2323,"createdAt":"2023-05-16T10:20:09.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"892983","user":6741000585464},{"id":2322,"createdAt":"2023-05-16T10:20:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"892989","user":6741000585464},{"id":2166,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"787039","user":6741000585464},{"id":2167,"createdAt":"2023-05-01T10:05:34.000Z","value":500,"voucher_value":"200","type":"debit","status":"redeemed","statusId":3,"voucher_code":"EG2DPH4LR27M8EKR","order":null,"user":6741000585464},{"id":2165,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"774589","user":6741000585464},{"id":2164,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"772389","user":6741000585464},{"id":2163,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"620836","user":6741000585464},{"id":2162,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"595545","user":6741000585464},{"id":2023,"createdAt":"2023-04-18T13:03:55.000Z","value":500,"voucher_value":"100000","type":"debit","status":"redeemed","statusId":3,"voucher_code":"ENJOY PANDAGOWW","order":null,"user":6741000585464},{"id":2019,"createdAt":"2023-04-18T13:03:55.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"772399","user":6741000585464},{"id":1895,"createdAt":"2023-02-23T07:59:57.000Z","value":500,"voucher_value":"200","type":"debit","status":"redeemed","statusId":3,"voucher_code":"aaaassssddddffff","order":null,"user":6741000585464},{"id":1894,"createdAt":"2023-02-23T07:59:57.000Z","value":100,"voucher_value":"0","type":"credit","status":"redeemed","statusId":3,"voucher_code":"0","order":"610241","user":6741000585464},{"id":1892,"createdAt":"2023-02-23T07:59:57.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"578678","user":6741000585464},{"id":1891,"createdAt":"2023-02-23T07:59:57.000Z","value":100,"voucher_value":"0","type":"credit","status":"redeemed","statusId":3,"voucher_code":"0","order":"583502","user":6741000585464},{"id":1890,"createdAt":"2023-02-23T07:59:57.000Z","value":100,"voucher_value":"0","type":"credit","status":"redeemed","statusId":3,"voucher_code":"0","order":"578673","user":6741000585464},{"id":1871,"createdAt":"2022-12-13T08:20:03.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"619104","user":6741000585464}],"balance":500,"lifetime":1200}

class ReferralBalModel {
  ReferralBalModel({
    this.code,
    this.body,
  });

  ReferralBalModel.fromJson(dynamic json) {
    code = json['code'];
    body = json['body'] != null ? Body.fromJson(json['body']) : null;
  }
  String? code;
  Body? body;
  ReferralBalModel copyWith({
    String? code,
    Body? body,
  }) =>
      ReferralBalModel(
        code: code ?? this.code,
        body: body ?? this.body,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    if (body != null) {
      map['body'] = body?.toJson();
    }
    return map;
  }
}

/// ledger : [{"id":2503,"createdAt":"2023-06-01T12:40:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"pending","statusId":1,"voucher_code":"0","order":"922411","user":6741000585464},{"id":2497,"createdAt":"2023-05-31T13:25:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"pending","statusId":1,"voucher_code":"0","order":"920867","user":6741000585464},{"id":2495,"createdAt":"2023-05-31T11:30:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"pending","statusId":1,"voucher_code":"0","order":"920634","user":6741000585464},{"id":2456,"createdAt":"2023-05-30T07:00:07.000Z","value":100,"voucher_value":"0","type":"credit","status":"pending","statusId":1,"voucher_code":"0","order":"918506","user":6741000585464},{"id":2424,"createdAt":"2023-05-26T14:40:38.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"912729","user":6741000585464},{"id":2420,"createdAt":"2023-05-26T10:20:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"912215","user":6741000585464},{"id":2418,"createdAt":"2023-05-26T07:10:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"911730","user":6741000585464},{"id":2324,"createdAt":"2023-05-16T10:25:07.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"892991","user":6741000585464},{"id":2323,"createdAt":"2023-05-16T10:20:09.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"892983","user":6741000585464},{"id":2322,"createdAt":"2023-05-16T10:20:06.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"892989","user":6741000585464},{"id":2166,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"787039","user":6741000585464},{"id":2167,"createdAt":"2023-05-01T10:05:34.000Z","value":500,"voucher_value":"200","type":"debit","status":"redeemed","statusId":3,"voucher_code":"EG2DPH4LR27M8EKR","order":null,"user":6741000585464},{"id":2165,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"774589","user":6741000585464},{"id":2164,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"772389","user":6741000585464},{"id":2163,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"620836","user":6741000585464},{"id":2162,"createdAt":"2023-05-01T10:05:34.000Z","value":100,"voucher_value":"0","type":"credit","status":"rewarded","statusId":2,"voucher_code":"0","order":"595545","user":6741000585464},{"id":2023,"createdAt":"2023-04-18T13:03:55.000Z","value":500,"voucher_value":"100000","type":"debit","status":"redeemed","statusId":3,"voucher_code":"ENJOY PANDAGOWW","order":null,"user":6741000585464},{"id":2019,"createdAt":"2023-04-18T13:03:55.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"772399","user":6741000585464},{"id":1895,"createdAt":"2023-02-23T07:59:57.000Z","value":500,"voucher_value":"200","type":"debit","status":"redeemed","statusId":3,"voucher_code":"aaaassssddddffff","order":null,"user":6741000585464},{"id":1894,"createdAt":"2023-02-23T07:59:57.000Z","value":100,"voucher_value":"0","type":"credit","status":"redeemed","statusId":3,"voucher_code":"0","order":"610241","user":6741000585464},{"id":1892,"createdAt":"2023-02-23T07:59:57.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"578678","user":6741000585464},{"id":1891,"createdAt":"2023-02-23T07:59:57.000Z","value":100,"voucher_value":"0","type":"credit","status":"redeemed","statusId":3,"voucher_code":"0","order":"583502","user":6741000585464},{"id":1890,"createdAt":"2023-02-23T07:59:57.000Z","value":100,"voucher_value":"0","type":"credit","status":"redeemed","statusId":3,"voucher_code":"0","order":"578673","user":6741000585464},{"id":1871,"createdAt":"2022-12-13T08:20:03.000Z","value":100,"voucher_value":"0","type":"credit","status":"rejected","statusId":4,"voucher_code":"0","order":"619104","user":6741000585464}]
/// balance : 500
/// lifetime : 1200

class Body {
  Body({
    this.ledger,
    this.balance,
    this.lifetime,
  });

  Body.fromJson(dynamic json) {
    if (json['ledger'] != null) {
      ledger = [];
      json['ledger'].forEach((v) {
        ledger?.add(Ledger.fromJson(v));
      });
    }
    balance = json['balance'];
    lifetime = json['lifetime'];
  }
  List<Ledger>? ledger;
  num? balance;
  num? lifetime;
  Body copyWith({
    List<Ledger>? ledger,
    num? balance,
    num? lifetime,
  }) =>
      Body(
        ledger: ledger ?? this.ledger,
        balance: balance ?? this.balance,
        lifetime: lifetime ?? this.lifetime,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (ledger != null) {
      map['ledger'] = ledger?.map((v) => v.toJson()).toList();
    }
    map['balance'] = balance;
    map['lifetime'] = lifetime;
    return map;
  }
}

/// id : 2503
/// createdAt : "2023-06-01T12:40:06.000Z"
/// value : 100
/// voucher_value : "0"
/// type : "credit"
/// status : "pending"
/// statusId : 1
/// voucher_code : "0"
/// order : "922411"
/// user : 6741000585464

class Ledger {
  Ledger({
    this.id,
    this.createdAt,
    this.value,
    this.voucherValue,
    this.type,
    this.status,
    this.statusId,
    this.voucherCode,
    this.order,
    this.ledgerCategory,
    this.user,
  });

  Ledger.fromJson(dynamic json) {
    id = json['id'];
    createdAt = json['createdAt'];
    value = json['value'];
    voucherValue = json['voucher_value'];
    type = json['type'];
    status = json['status'];
    statusId = json['statusId'];
    voucherCode = json['voucher_code'];
    order = json['order'];
    user = json['user'];
    ledgerCategory = json['ledger_category'];
  }
  num? id;
  String? createdAt;
  num? value;
  String? voucherValue;
  String? type;
  String? status;
  num? statusId;
  num? ledgerCategory;
  String? voucherCode;
  String? order;
  num? user;
  Ledger copyWith({
    num? id,
    String? createdAt,
    num? value,
    String? voucherValue,
    String? type,
    String? status,
    num? statusId,
    num? ledgerCategory,
    String? voucherCode,
    String? order,
    num? user,
  }) =>
      Ledger(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        value: value ?? this.value,
        voucherValue: voucherValue ?? this.voucherValue,
        type: type ?? this.type,
        ledgerCategory: ledgerCategory ?? this.ledgerCategory,
        status: status ?? this.status,
        statusId: statusId ?? this.statusId,
        voucherCode: voucherCode ?? this.voucherCode,
        order: order ?? this.order,
        user: user ?? this.user,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['createdAt'] = createdAt;
    map['value'] = value;

    map['voucher_value'] = voucherValue;
    map['type'] = type;
    map['status'] = status;
    map['statusId'] = statusId;
    map['voucher_code'] = voucherCode;
    map['order'] = order;
    map['ledger_category'] = ledgerCategory;
    map['user'] = user;
    return map;
  }
}

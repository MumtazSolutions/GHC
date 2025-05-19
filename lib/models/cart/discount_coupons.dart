class DiscountCoupon {
  List<Data>? data;

  DiscountCoupon({this.data});

  DiscountCoupon.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  bool? isDeleted;
  String? sId;
  String? discountCode;
  String? priceRuleId;
  String? startDate;
  String? endDate;

  Data(
      {this.isDeleted,
      this.sId,
      this.discountCode,
      this.priceRuleId,
      this.startDate,
      this.endDate});

  Data.fromJson(Map<String, dynamic> json) {
    isDeleted = json['isDeleted'];
    sId = json['_id'];
    discountCode = json['discountCode'];
    priceRuleId = json['price_rule_id'];
    startDate = json['startDate'];
    endDate = json['endDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isDeleted'] = isDeleted;
    data['_id'] = sId;
    data['discount_code'] = discountCode;
    data['price_rule_id'] = priceRuleId;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    return data;
  }
}
import 'dart:convert';

ReferralCodeModel referralCodeModelFromJson(String str) => ReferralCodeModel.fromJson(json.decode(str));

String referralCodeModelToJson(ReferralCodeModel data) => json.encode(data.toJson());

class ReferralCodeModel {
    String code;
    Body body;

    ReferralCodeModel({
        required this.code,
        required this.body,
    });

    factory ReferralCodeModel.fromJson(Map<String, dynamic> json) => ReferralCodeModel(
        code: json["code"],
        body: Body.fromJson(json["body"]),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "body": body.toJson(),
    };
}

class Body {
    int customerId;
    String referralCode;

    Body({
        required this.customerId,
        required this.referralCode,
    });

    factory Body.fromJson(Map<String, dynamic> json) => Body(
        customerId: json["customer_id"],
        referralCode: json["referral_code"],
    );

    Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "referral_code": referralCode,
    };
}

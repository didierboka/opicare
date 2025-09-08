import 'dart:convert';


class SouscriptionPaymentModel {

  String? code;
  String? message;
  String? amount;
  String? currency;
  String? status;
  String? paymentMethod;
  String? operatorId;
  String? transactionId;
  String? description;

  SouscriptionPaymentModel({this.code, this.message, this.amount, this.currency, this.status, this.paymentMethod, this.operatorId, this.transactionId, this.description,});

  SouscriptionPaymentModel.fromJson(dynamic json) {
    code = json['code'];
    message = json['message'];
    amount = json['amount'];
    currency = json['currency'];
    status = json['status'];
    paymentMethod = json['payment_method'];
    operatorId = json['operator_id'];
    transactionId = json['transaction_id'];
    description = json['description'];
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['message'] = message;
    map['amount'] = amount;
    map['currency'] = currency;
    map['status'] = status;
    map['payment_method'] = paymentMethod;
    map['operator_id'] = operatorId;
    map['transaction_id'] = transactionId;
    map['description'] = description;
    return map;
  }

}
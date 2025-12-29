// ignore_for_file: unnecessary_this

import 'dart:convert';


class SouscriptionPaymentModel {


  final String transactionId;
  final int amount;
  final String customerId;
  final String customerName;
  final String customerSurname;
  final String customerCity;
  final String customerMetadata;
  final String customerEmail;
  final String customerAddress;
  final String customerCountry;
  final String customerZipCode;
  final String customerPhoneNumber;
  final String alternativeCurrency;


  const SouscriptionPaymentModel({
    required this.transactionId,
    required this.amount,
    required this.customerId,
    required this.customerName,
    required this.customerSurname,
    required this.customerMetadata,
    required this.customerCity,
    required this.customerEmail,
    required this.customerAddress,
    required this.customerCountry,
    required this.customerZipCode,
    required this.customerPhoneNumber,
    required this.alternativeCurrency,
  });


  SouscriptionPaymentModel copyWith({
    String? transactionId,
    int? amount,
    String? customerId,
    String? customerName,
    String? customerSurname,
    String? customerCity,
    String? customerEmail,
    String? customerAddress,
    String? customerCountry,
    String? customerZipCode,
    String? customerPhoneNumber,
    String? metadata,
    String? alternativeCurrency,
  }) {
    return SouscriptionPaymentModel(
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerMetadata: metadata ?? this.customerMetadata,
      customerSurname: customerSurname ?? this.customerSurname,
      customerCity: customerCity ?? this.customerCity,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      customerCountry: customerCountry ?? this.customerCountry,
      customerZipCode: customerZipCode ?? this.customerZipCode,
      customerPhoneNumber: customerPhoneNumber ?? this.customerPhoneNumber,
      alternativeCurrency: alternativeCurrency ?? this.alternativeCurrency,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'amount': amount,
      'customerId': customerId,
      'customerName': customerName,
      'customerMeta': customerMetadata,
      'customerSurname': customerSurname,
      'customerCity': customerCity,
      'customerEmail': customerEmail,
      'customerAddress': customerAddress,
      'customerCountry': customerCountry,
      'customerZipCode': customerZipCode,
      'customerPhoneNumber': customerPhoneNumber,
      'alternativeCurrency': alternativeCurrency,
    };
  }


  factory SouscriptionPaymentModel.fromMap(Map<String, dynamic> map) {
    return SouscriptionPaymentModel(
      transactionId: map['transactionId'] as String,
      amount: map['amount'] as int,
      customerMetadata: map['customerMeta'],
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      customerSurname: map['customerSurname'] as String,
      customerCity: map['customerCity'] as String,
      customerEmail: map['customerEmail'] as String,
      customerAddress: map['customerAddress'] as String,
      customerCountry: map['customerCountry'] as String,
      customerZipCode: map['customerZipCode'] as String,
      customerPhoneNumber: map['customerPhoneNumber'] as String,
      alternativeCurrency: map['alternativeCurrency'] as String,
    );
  }
}
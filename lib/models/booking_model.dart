// To parse this JSON data, do
//
//     final bookingModel = bookingModelFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

BookingModel bookingModelFromJson(String str) => BookingModel.fromJson(json.decode(str));

String bookingModelToJson(BookingModel data) => json.encode(data.toJson());

class BookingModel {
  BookingModel({
    required this.userId,
    this.id,
    required this.productId,
    required this.bookingDate,
    required this.bookingTime
  });

  String? id;
  String userId;
  String productId;
  String bookingDate;
  String bookingTime;

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json["id"],
    userId: json["user_id"],
    productId: json["product_id"],
    bookingDate: json["booking_date"],
    bookingTime: json["booking_time"]
  );
  factory BookingModel.fromFirebaseSnapshot(DocumentSnapshot<Map<String, dynamic>> json) => BookingModel(
    id: json.id,
    userId: json["user_id"],
    productId: json["product_id"],
      bookingDate: json["booking_date"],
      bookingTime: json["booking_time"]
  );


  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "id": id,
    "product_id": productId,
    "booking_date":bookingDate,
        "booking_time": bookingTime
  };
}

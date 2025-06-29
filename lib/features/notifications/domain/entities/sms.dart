import 'package:equatable/equatable.dart';

class Sms extends Equatable {
  final String id;
  final String message;
  final String sender;
  final DateTime date;
  final bool isRead;

  const Sms({
    required this.id,
    required this.message,
    required this.sender,
    required this.date,
    required this.isRead,
  });

  @override
  List<Object?> get props => [id, message, sender, date, isRead];
} 
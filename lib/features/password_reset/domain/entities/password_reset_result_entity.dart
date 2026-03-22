import 'package:equatable/equatable.dart';

class PasswordResetResultEntity extends Equatable {
  final bool success;
  final String message;

  const PasswordResetResultEntity({
    required this.success,
    required this.message,
  });

  @override
  List<Object?> get props => [success, message];
}

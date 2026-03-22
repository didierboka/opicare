import 'package:equatable/equatable.dart';

class AjoutFamilleResultEntity extends Equatable {
  final bool success;
  final String message;

  const AjoutFamilleResultEntity({
    required this.success,
    required this.message,
  });

  @override
  List<Object?> get props => [success, message];
}

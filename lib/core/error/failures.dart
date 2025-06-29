import 'package:equatable/equatable.dart';

// Base failure class
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

// Specific failure types
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Erreur serveur']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Erreur de cache']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Erreur de connexion réseau']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Données invalides']) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Erreur d\'authentification']) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission refusée']) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Erreur inconnue']) : super(message);
} 
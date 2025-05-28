part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

class RegisterSubmitted extends RegisterEvent {
  final String nom;
  final String prenoms;
  final String dateNaissance;
  final String telephone;
  final String email;
  final String genre;

  const RegisterSubmitted({
    required this.nom,
    required this.prenoms,
    required this.dateNaissance,
    required this.telephone,
    required this.email,
    required this.genre,
  });

  @override
  List<Object> get props => [
    nom,
    prenoms,
    dateNaissance,
    telephone,
    email,
    genre,
  ];
}
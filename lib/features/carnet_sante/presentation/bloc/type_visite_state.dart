import 'package:opicare/features/carnet_sante/data/models/type_visite_model.dart';

abstract class TypeVisiteState {}

class TypeVisiteInitial extends TypeVisiteState {}

class TypeVisiteLoading extends TypeVisiteState {}

class TypeVisiteLoaded extends TypeVisiteState {
  final List<TypeVisiteModel> typeVisites;
  
  TypeVisiteLoaded({required this.typeVisites});
}

class TypeVisiteFailure extends TypeVisiteState {
  final String message;
  
  TypeVisiteFailure({required this.message});
} 
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/souscribtion/data/models/type_abo_model.dart';
import 'package:opicare/features/souscribtion/data/repositories/subscription_repository.dart';

part 'type_abo_event.dart';
part 'type_abo_state.dart';

// class TypeAboBloc extends Bloc<TypeAboEvent, TypeAboState> {
//   final SubscriptionRepository subscriptionRepository;
//
//
//   TypeAboBloc({required this.subscriptionRepository}) : super(TypeAboInitial()) {
//     on<TypeAboSubmitted>(_onTypeAboSubmitted);
//   }
//
//   Future<void> _onTypeAboSubmitted(
//       TypeAboSubmitted event,
//       Emitter<TypeAboState> emit,
//       ) async {
//     emit(TypeAboLoading());
//
//     try {
//       final res = await subscriptionRepository.getTypeAbo();
//       if (!res.status) {
//         emit(TypeAboFailure(res.message!));
//         return;
//       }
//
//       emit(TypeAboSuccess(list: res.datas!));
//     } catch (e) {
//       print("Erreur TypeAboBloc: ${e.toString()}");
//       emit(TypeAboFailure(e.toString()));
//     }
//   }
// }


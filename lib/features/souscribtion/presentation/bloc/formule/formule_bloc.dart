import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/souscribtion/data/models/formule.dart';
import 'package:opicare/features/souscribtion/data/repositories/subscription_repository.dart';

part 'formule_event.dart';
part 'formule_state.dart';

// class FormuleBloc extends Bloc<FormuleEvent, FormuleState> {
//   final SubscriptionRepository subscriptionRepository;
//
//
//   FormuleBloc({required this.subscriptionRepository}) : super(FormuleInitial()) {
//     on<FormuleSubmitted>(_onFormuleSubmitted);
//   }
//
//   Future<void> _onFormuleSubmitted(
//       FormuleSubmitted event,
//       Emitter<FormuleState> emit,
//       ) async {
//     emit(FormuleLoading());
//
//     try {
//       final res = await subscriptionRepository.getFormule(typeAboId: event.typeAboId);
//       if (!res.status) {
//         emit(FormuleFailure(res.message!));
//         return;
//       }
//
//       emit(FormuleSuccess(list: res.datas!));
//     } catch (e) {
//       print("Erreur FormuleBloc: ${e.toString()}");
//       emit(FormuleFailure(e.toString()));
//     }
//   }
// }
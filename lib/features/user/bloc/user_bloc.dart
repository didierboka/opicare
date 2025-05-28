
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/user/data/models/user_model.dart';
import 'package:opicare/features/user/data/repositories/user_repository.dart';


part 'user_event.dart';
part 'user_state.dart';

// class UserBloc extends Bloc<UserEvent, UserState> {
//   final UserRepository userRepository;
//
//   UserBloc({required this.userRepository}) : super(UserInitial()) {
//     on<LoadUserEvent>((event, emit) async {
//       emit(UserLoading());
//       try {
//         final user = await userRepository.getUser(event.token);
//         emit(UserLoaded(user));
//       } catch (e) {
//         emit(UserError('Échec du chargement des données utilisateur.'));
//       }
//     });
//   }
// }

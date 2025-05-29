// import '../models/user_model.dart';
//
// abstract class UserRepository {
//   Future<UserModel> getUser(String token);
// }
//
// class UserRepositoryImpl implements UserRepository {
//   @override
//   Future<UserModel> getUser(String token) async {
//     // Simulation d'appel API — remplace par un vrai appel HTTP
//     await Future.delayed(const Duration(seconds: 1));
//     return UserModel(
//       id: '12345',
//       name: 'Eren Boka',
//       email: 'eren@example.com',
//       phone: '2250757187963',
//     );
//   }
// }
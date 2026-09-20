import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/auth/data/models/delete_account_response.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:opicare/features/auth/domain/use_cases/update_profile_photo_usecase.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

UserModel _user({String patID = '1143648', String userPic = 'old.jpg'}) {
  return UserModel(
    id: '1',
    patID: patID,
    name: 'Doe',
    surname: 'Jane',
    email: 'jane@example.com',
    phone: '000',
    sex: 'F',
    birthdate: '1990-01-01',
    carnetPhoto: '',
    userPic: userPic,
    dateAbon: 'N/A',
    dateExpiration: 'N/A',
    abonnementLabel: 'BUSINESS',
  );
}

class _FakeLocalStorage implements LocalStorageService {
  UserModel? user;

  @override
  Future<void> saveUser(UserModel user) async {
    this.user = user;
  }

  @override
  Future<UserModel?> getSavedUser() async => user;

  @override
  Future<void> clearUser() async {
    user = null;
  }
}

class _FakeUserApiService extends ApiService<UserModel> {
  _FakeUserApiService() : super(fromJson: UserModel.fromJson);
}

class _RecordingPhotoApiService extends ApiService<Map<String, dynamic>> {
  _RecordingPhotoApiService() : super(fromJson: (json) => json);

  String? lastEndpoint;
  Map<String, dynamic>? lastData;
  bool? lastWrite;
  bool? lastUseFormData;
  CustomResponse<Map<String, dynamic>> next = CustomResponse(status: true);

  @override
  Future<CustomResponse<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool useFormData = true,
    bool likeAgent = false,
    bool likeOrange = false,
    String? overrideD,
    bool write = false,
    Duration? timeout,
    int maxRetries = 3,
  }) async {
    lastEndpoint = endpoint;
    lastData = Map<String, dynamic>.from(data);
    lastWrite = write;
    lastUseFormData = useFormData;
    return next;
  }
}

class _FakeAuthRepository implements AuthRepository {
  String? lastUserId;
  String? lastBase64;
  CustomResponse<UserModel> next = CustomResponse(status: true, message: 'Mise à jour effectuée');

  @override
  Future<CustomResponse<UserModel>> login({
    required String emailOrPhone,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CustomResponse<UserModel>> register({
    required String nom,
    required String prenoms,
    required String dateNaissance,
    required String telephone,
    required String email,
    required String genre,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CustomResponse<DeleteAccountResponse>> deleteAccount({required String userId}) {
    throw UnimplementedError();
  }

  @override
  Future<CustomResponse<UserModel>> updateProfilePhoto({
    required String userId,
    required String base64Image,
  }) async {
    lastUserId = userId;
    lastBase64 = base64Image;
    return next;
  }
}

void main() {
  late Directory tempDir;
  late File imageFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('profile-photo-');
    imageFile = File('${tempDir.path}/photo.jpg');
    await imageFile.writeAsBytes(base64Decode(
      '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAb/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAGf/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPwB//9k=',
    ));
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AuthRepositoryImpl.updateProfilePhoto', () {
    test('POST /update/photo avec id, photo, write et JSON', () async {
      final photoApi = _RecordingPhotoApiService()
        ..next = CustomResponse(
          status: true,
          message: 'Mise à jour effectuée',
          response: const {'code': 0, 'msg': 'Mise à jour effectuée'},
        );

      final repository = AuthRepositoryImpl(
        apiService: _FakeUserApiService(),
        localStorage: _FakeLocalStorage(),
        updatePhotoApiService: photoApi,
      );

      final result = await repository.updateProfilePhoto(
        userId: '1143648',
        base64Image: 'abc123',
      );

      expect(photoApi.lastEndpoint, '/update/photo');
      expect(photoApi.lastWrite, isTrue);
      expect(photoApi.lastUseFormData, isFalse);
      expect(photoApi.lastData?['id'], '1143648');
      expect(photoApi.lastData?['photo'], 'abc123');
      expect(result.status, isTrue);
      expect(result.code, 0);
      expect(result.message, 'Mise à jour effectuée');
    });

    test('échec code 1', () async {
      final photoApi = _RecordingPhotoApiService()
        ..next = CustomResponse(
          status: false,
          message: 'Une erreur est survenue',
          code: 1,
          response: const {'code': 1, 'msg': 'Une erreur est survenue'},
        );

      final repository = AuthRepositoryImpl(
        apiService: _FakeUserApiService(),
        localStorage: _FakeLocalStorage(),
        updatePhotoApiService: photoApi,
      );

      final result = await repository.updateProfilePhoto(
        userId: '1143648',
        base64Image: 'abc123',
      );

      expect(result.status, isFalse);
      expect(result.code, 1);
      expect(result.message, 'Une erreur est survenue');
    });
  });

  group('UpdateProfilePhotoUseCase', () {
    test('encode le fichier en base64 et délègue au repository', () async {
      final fakeRepo = _FakeAuthRepository();
      final useCase = UpdateProfilePhotoUseCase(authRepository: fakeRepo);

      final result = await useCase.execute(
        userId: '1143648',
        imageFile: imageFile,
      );

      expect(fakeRepo.lastUserId, '1143648');
      expect(fakeRepo.lastBase64, isNotNull);
      expect(fakeRepo.lastBase64!.isNotEmpty, isTrue);
      expect(base64Decode(fakeRepo.lastBase64!), isNotEmpty);
      expect(result.status, isTrue);
    });
  });

  group('AuthBloc photo update', () {
    test('succès: persist le chemin local puis AuthAuthenticated', () async {
      final storage = _FakeLocalStorage()..user = _user();
      final fakeRepo = _FakeAuthRepository();
      final bloc = AuthBloc(localStorage: storage, authRepository: fakeRepo);

      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<UpdateProfilePhotoLoading>(),
          isA<UpdateProfilePhotoSuccess>(),
          isA<AuthAuthenticated>(),
        ]),
      );

      bloc.add(UpdateProfilePhotoRequested(imageFile));
      await future;

      expect(fakeRepo.lastUserId, '1143648');
      expect(storage.user?.userPic, imageFile.path);
      expect((bloc.state as AuthAuthenticated).user.userPic, imageFile.path);
      await bloc.close();
    });

    test('échec: restaure AuthAuthenticated sans changer la photo', () async {
      final storage = _FakeLocalStorage()..user = _user();
      final fakeRepo = _FakeAuthRepository()
        ..next = CustomResponse(status: false, message: 'Une erreur est survenue');
      final bloc = AuthBloc(localStorage: storage, authRepository: fakeRepo);

      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<UpdateProfilePhotoLoading>(),
          isA<UpdateProfilePhotoFailure>(),
          isA<AuthAuthenticated>(),
        ]),
      );

      bloc.add(UpdateProfilePhotoRequested(imageFile));
      await future;

      expect(storage.user?.userPic, 'old.jpg');
      expect((bloc.state as AuthAuthenticated).user.userPic, 'old.jpg');
      await bloc.close();
    });
  });
}

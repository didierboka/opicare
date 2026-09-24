import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class CarnetPatientScope {
  static const famillePath = '/famille';
  static const ownCarnetPath = '/carnet_sante';

  static String resolveIds({
    String? routePatId,
    required String authPatId,
  }) {
    final id = routePatId?.trim() ?? '';
    return id.isEmpty ? authPatId : id;
  }

  static bool isOwnCarnet({
    required String patId,
    required String authPatId,
  }) {
    return patId.isEmpty || patId == authPatId;
  }

  static String carnetPath({
    required String patId,
    required String authPatId,
  }) {
    if (isOwnCarnet(patId: patId, authPatId: authPatId)) {
      return ownCarnetPath;
    }
    return '$ownCarnetPath/$patId';
  }

  /// Rebuilds the member carnet while keeping Famille underneath so back works.
  static void openCarnetAfterSubmit(
    BuildContext context, {
    required String patId,
    required String authPatId,
  }) {
    final router = GoRouter.of(context);
    if (isOwnCarnet(patId: patId, authPatId: authPatId)) {
      router.go(ownCarnetPath);
      return;
    }
    router.go(famillePath);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.push(carnetPath(patId: patId, authPatId: authPatId));
    });
  }
}

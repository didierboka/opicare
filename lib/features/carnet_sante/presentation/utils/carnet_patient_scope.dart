class CarnetPatientScope {
  static String resolveIds({
    String? routePatId,
    required String authPatId,
  }) {
    final id = routePatId?.trim() ?? '';
    return id.isEmpty ? authPatId : id;
  }

  static String carnetPath({
    required String patId,
    required String authPatId,
  }) {
    if (patId.isEmpty || patId == authPatId) {
      return '/carnet_sante';
    }
    return '/carnet_sante/$patId';
  }
}

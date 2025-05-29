/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/add-user.png
  AssetGenImage get addUser =>
      const AssetGenImage('assets/images/add-user.png');

  /// File path: assets/images/localisation.png
  AssetGenImage get localisation =>
      const AssetGenImage('assets/images/localisation.png');

  /// File path: assets/images/ma-famille.png
  AssetGenImage get maFamille =>
      const AssetGenImage('assets/images/ma-famille.png');

  /// File path: assets/images/mon-abonnement.png
  AssetGenImage get monAbonnement =>
      const AssetGenImage('assets/images/mon-abonnement.png');

  /// File path: assets/images/mon-carnet-de-sante.png
  AssetGenImage get monCarnetDeSante =>
      const AssetGenImage('assets/images/mon-carnet-de-sante.png');

  /// File path: assets/images/mon-grand-profil.png
  AssetGenImage get monGrandProfil =>
      const AssetGenImage('assets/images/mon-grand-profil.png');

  /// File path: assets/images/photo.jpg
  AssetGenImage get photo => const AssetGenImage('assets/images/photo.jpg');

  /// File path: assets/images/unlock.png
  AssetGenImage get unlock => const AssetGenImage('assets/images/unlock.png');

  /// File path: assets/images/user-profil.png
  AssetGenImage get userProfil =>
      const AssetGenImage('assets/images/user-profil.png');

  /// File path: assets/images/user.png
  AssetGenImage get user => const AssetGenImage('assets/images/user.png');

  /// File path: assets/images/vaccination-sans-bg.png
  AssetGenImage get vaccinationSansBg =>
      const AssetGenImage('assets/images/vaccination-sans-bg.png');

  /// File path: assets/images/vaccination.png
  AssetGenImage get vaccination =>
      const AssetGenImage('assets/images/vaccination.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    addUser,
    localisation,
    maFamille,
    monAbonnement,
    monCarnetDeSante,
    monGrandProfil,
    photo,
    unlock,
    userProfil,
    user,
    vaccinationSansBg,
    vaccination,
  ];
}

class $AssetsLottiesGen {
  const $AssetsLottiesGen();

  /// File path: assets/lotties/loading.json
  String get loading => 'assets/lotties/loading.json';

  /// List of all assets
  List<String> get values => [loading];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLottiesGen lotties = $AssetsLottiesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

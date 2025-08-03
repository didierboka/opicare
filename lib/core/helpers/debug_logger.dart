import 'dart:developer';
import 'package:flutter/foundation.dart';

/// Helper de logging qui s'affiche uniquement en mode debug
/// 
/// Utilisation :
/// ```dart
/// DebugLogger.log('Message de debug');
/// DebugLogger.log('Message avec emoji', emoji: '🔍');
/// DebugLogger.error('Message d\'erreur');
/// DebugLogger.info('Message d\'information');
/// ```
class DebugLogger {
  static const String _defaultEmoji = '📝';

  /// Log un message simple
  static void log(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? _defaultEmoji;
      log('$emojiToUse $message');
    }
  }

  /// Log un message d'erreur
  static void error(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '❌';
      log('$emojiToUse $message');
    }
  }

  /// Log un message d'information
  static void info(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? 'ℹ️';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de succès
  static void success(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '✅';
      log('$emojiToUse $message');
    }
  }

  /// Log un message d'avertissement
  static void warning(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '⚠️';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de debug avec emoji personnalisé
  static void debug(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '🔍';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de performance
  static void performance(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '⚡';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de réseau/API
  static void network(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '🌐';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de base de données
  static void database(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '💾';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de navigation
  static void navigation(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '🧭';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de bloc/state management
  static void bloc(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '🔄';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de validation
  static void validation(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '✅';
      log('$emojiToUse $message');
    }
  }

  /// Log un message de sécurité
  static void security(String message, {String? emoji}) {
    if (kDebugMode) {
      final emojiToUse = emoji ?? '🔒';
      log('$emojiToUse $message');
    }
  }
} 
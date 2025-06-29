import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'failures.dart';

// Extension to handle Either<Failure, T> consistently
extension EitherExtensions<L extends Failure, R> on Either<L, R> {
  R getRight() => (this as Right<L, R>).value;
  L getLeft() => (this as Left<L, R>).value;
  
  // For use in UI to map to different widgets based on success/failure
  Widget when({
    required Widget Function(L failure) failure,
    required Widget Function(R data) success,
  }) {
    return fold(
      (l) => failure(l),
      (r) => success(r),
    );
  }
  
  // Simplify chaining operations that can fail
  Either<L, T> flatMap<T>(Either<L, T> Function(R r) f) {
    return fold(
      (l) => Left(l),
      (r) => f(r),
    );
  }
  
  // Get success value or throw if failure
  R getOrThrow() {
    return fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );
  }
  
  // Get success value or return default value
  R getOrElse(R defaultValue) {
    return fold(
      (failure) => defaultValue,
      (success) => success,
    );
  }
  
  // Check if it's a success
  bool get isSuccess => isRight();
  
  // Check if it's a failure
  bool get isFailure => isLeft();
} 
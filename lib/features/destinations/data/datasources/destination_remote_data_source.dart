import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:opicare/features/destinations/data/models/destination_model.dart';

abstract class DestinationRemoteDataSource {
  Future<List<DestinationModel>> getDestinations();
  Future<DestinationModel> getDestinationDetails(String id);
}

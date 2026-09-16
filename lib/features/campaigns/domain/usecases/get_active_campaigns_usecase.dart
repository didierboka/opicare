import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';
import 'package:opicare/features/campaigns/domain/repositories/campaigns_repository.dart';

class GetActiveCampaignsUseCase {
  final CampaignsRepository repository;

  GetActiveCampaignsUseCase(this.repository);

  Future<Either<Failure, List<CampaignEntity>>> call(String login) {
    return repository.getActiveCampaigns(login);
  }
}

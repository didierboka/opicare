import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';
import 'package:opicare/features/campaigns/domain/repositories/campaigns_repository.dart';
import 'package:opicare/features/campaigns/domain/usecases/acknowledge_campaign_usecase.dart';
import 'package:opicare/features/campaigns/domain/usecases/get_active_campaigns_usecase.dart';
import 'package:opicare/features/campaigns/presentation/campaign_cta_launcher.dart';
import 'package:opicare/features/campaigns/presentation/cubit/campaigns_cubit.dart';
import 'package:opicare/features/iap/presentation/pages/iap_screen.dart';
import 'package:opicare/features/plan_abonnement/presentation/pages/plan_abonnement.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';

class _FakeRepo implements CampaignsRepository {
  Either<Failure, List<CampaignEntity>> listResult = const Right([]);
  final List<CampaignAckAction> acks = [];
  Object? throwOnList;

  @override
  Future<Either<Failure, List<CampaignEntity>>> getActiveCampaigns(String login) async {
    if (throwOnList != null) {
      throw throwOnList!;
    }
    return listResult;
  }

  @override
  Future<void> acknowledge({
    required String campaignId,
    required CampaignAckAction action,
  }) async {
    acks.add(action);
  }
}

CampaignEntity _entity({
  required String id,
  required CampaignType type,
  int priority = 1,
}) {
  return CampaignEntity(
    id: id,
    type: type,
    title: id,
    body: 'body',
    imageUrl: null,
    ctaLabel: 'CTA',
    ctaUrl: 'opicare://iap',
    priority: priority,
    frequency: CampaignFrequency.everyOpen,
    startsAt: null,
    endsAt: null,
    dismissible: true,
  );
}

void main() {
  test('mapDeepLink opicare:// vers routes existantes', () {
    const launcher = CampaignCtaLauncher();
    expect(launcher.mapDeepLink(Uri.parse('opicare://plan')), PlanAbonnementScreen.path);
    expect(
      launcher.mapDeepLink(Uri.parse('opicare://souscription')),
      SouscriptionScreen.path,
    );
    expect(launcher.mapDeepLink(Uri.parse('opicare://iap')), IapScreen.path);
  });

  test('CampaignsCubit ne remonte pas d’erreur API', () async {
    final repo = _FakeRepo()..listResult = const Left(ServerFailure('down'));
    final cubit = CampaignsCubit(
      getActiveCampaigns: GetActiveCampaignsUseCase(repo),
      acknowledgeCampaign: AcknowledgeCampaignUseCase(repo),
    );

    await cubit.load(login: '42897250');
    expect(cubit.state.popup, isNull);
    expect(cubit.state.offers, isEmpty);
    await cubit.close();
  });

  test('CampaignsCubit sépare popup et offres', () async {
    final repo = _FakeRepo()
      ..listResult = Right([
        _entity(id: 'o1', type: CampaignType.offer, priority: 2),
        _entity(id: 'p1', type: CampaignType.popup, priority: 1),
        _entity(id: 'p2', type: CampaignType.popup, priority: 8),
      ]);
    final cubit = CampaignsCubit(
      getActiveCampaigns: GetActiveCampaignsUseCase(repo),
      acknowledgeCampaign: AcknowledgeCampaignUseCase(repo),
    );

    await cubit.load(login: 'user');
    expect(cubit.state.popup?.id, 'p2');
    expect(cubit.state.offers.map((e) => e.id), ['o1']);

    await cubit.clicked(cubit.state.popup!);
    expect(repo.acks, contains(CampaignAckAction.click));
    expect(cubit.state.popup, isNull);
    await cubit.close();
  });
}

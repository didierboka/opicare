import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/sante_infos/presentation/bloc/sante_info_bloc.dart';
import 'package:opicare/features/sante_infos/presentation/widgets/sante_info_dialog.dart';

class SanteInfoCard extends StatelessWidget {
  const SanteInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SanteInfoBloc, SanteInfoState>(
      builder: (context, state) {
        if (state is SanteInfoLoading) {
          return _buildLoadingCard();
        } else if (state is SanteInfoLoaded) {
          return _buildLoadedCard(context, state);
        } else if (state is SanteInfoError) {
          return _buildErrorCard(context, state);
        } else {
          return _buildInitialCard();
        }
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.homeCardSecondaryButtonBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Chargement...', style: TextStyle(color: Colors.white)),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedCard(BuildContext context, SanteInfoLoaded state) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.homeCardSecondaryButtonBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.santeInfo.titre,
                  style: TextStyles.titleMedium.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  state.santeInfo.details,
                  style: TextStyles.bodyRegular.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colours.accentYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SanteInfoDialog(santeInfo: state.santeInfo),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voir plus...', style: TextStyles.bodyBold.copyWith(color: Colours.background)),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_right_alt, color: Colours.background),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Image.asset('assets/images/vaccination.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, SanteInfoError state) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.homeCardSecondaryButtonBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Informations de santé',
                  style: TextStyles.titleMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  'Erreur de chargement',
                  style: TextStyles.bodyRegular.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colours.accentYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    context.read<SanteInfoBloc>().add(const GetSanteInfoEvent());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Réessayer', style: TextStyles.bodyBold.copyWith(color: Colours.background)),
                      const SizedBox(width: 5),
                      Icon(Icons.refresh, color: Colours.background),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Image.asset('assets/images/vaccination.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.homeCardSecondaryButtonBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Informations de santé',
                  style: TextStyles.titleMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  'Chargement des informations...',
                  style: TextStyles.bodyRegular.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colours.accentYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voir plus...', style: TextStyles.bodyBold.copyWith(color: Colours.background)),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_right_alt, color: Colours.background),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Image.asset('assets/images/vaccination.png'),
          ),
        ],
      ),
    );
  }
} 
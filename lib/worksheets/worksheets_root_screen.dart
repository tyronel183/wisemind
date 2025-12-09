import 'package:flutter/material.dart';
import 'package:wisemind/theme/app_theme.dart';
import 'package:wisemind/theme/app_spacing.dart';
import 'package:wisemind/theme/app_card_tile.dart';

import '../analytics/amplitude_service.dart';
import 'chain_analysis_screens.dart';
import 'pros_cons_screens.dart';
import 'fact_check_screens.dart';

class WorksheetsRootScreen extends StatefulWidget {
  const WorksheetsRootScreen({super.key});

  @override
  State<WorksheetsRootScreen> createState() => _WorksheetsRootScreenState();
}

class _WorksheetsRootScreenState extends State<WorksheetsRootScreen> {
  @override
  void initState() {
    super.initState();
    // Логируем открытие экрана рабочих листов
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeService.instance.logWorksheetsScreenOpened();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок экрана — как на других экранах
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenTitleHorizontal,
                vertical: AppSpacing.screenTitleVertical,
              ),
              child: const Center(
                child: Text(
                  'Упражнения',
                  style: AppTypography.screenTitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Контент экрана
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.gapMedium,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sectionTitleTop,
                      bottom: AppSpacing.sectionTitleBottom,
                    ),
                    child: Text(
                      'Рабочие листы по навыкам',
                      style: AppTypography.sectionTitle,
                    ),
                  ),
                  AppCardTile(
                    leadingIcon: Icons.commit,
                    title: 'Анализ нежелательного поведения',
                    subtitle: 'Исследование нежелательного поведения, которое хочется изменить',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChainAnalysisListScreen(),
                        ),
                      );
                    },
                  ),
                  AppCardTile(
                    leadingIcon: Icons.balance,
                    title: 'За и против',
                    subtitle: 'Помогает сделать выбор между нежелательным поведением и осознанным действием',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProsConsListScreen(),
                        ),
                      );
                    },
                  ),
                  AppCardTile(
                    leadingIcon: Icons.fact_check,
                    title: 'Проверка фактов',
                    subtitle: 'Помогает оценить эмоции или мысли на соответствие фактам',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FactCheckListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
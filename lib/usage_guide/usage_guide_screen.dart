import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../analytics/amplitude_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';

class UsageGuideScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const UsageGuideScreen({
    super.key,
    this.onCompleted,
  });

  @override
  State<UsageGuideScreen> createState() => _UsageGuideScreenState();
}

class _UsageGuideScreenState extends State<UsageGuideScreen> {
  static const int _pageCount = 5;

  final _controller = PageController();
  int _currentPage = 0;

  void _completeAndClose() {
    // Логируем завершение минигайда
    AmplitudeService.instance.logHomeGuideCompleted();
    // Вызываем колбэк, если он передан
    widget.onCompleted?.call();
    // Закрываем экран
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    // Логируем просмотр первого шага минигайда
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeService.instance.logHomeGuideStepViewed(stepIndex: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.usageGuideAppBarTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pageCount,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                AmplitudeService.instance
                    .logHomeGuideStepViewed(stepIndex: index + 1);
              },
              itemBuilder: (context, index) {
                final l10n = AppLocalizations.of(context)!;

                String title;
                String body;

                switch (index) {
                  case 0:
                    title = l10n.usageGuideTitle1;
                    body = l10n.usageGuideBody1;
                    break;
                  case 1:
                    title = l10n.usageGuideTitle2;
                    body = l10n.usageGuideBody2;
                    break;
                  case 2:
                    title = l10n.usageGuideTitle3;
                    body = l10n.usageGuideBody3;
                    break;
                  case 3:
                    title = l10n.usageGuideTitle4;
                    body = l10n.usageGuideBody4;
                    break;
                  case 4:
                  default:
                    title = l10n.usageGuideTitle5;
                    body = l10n.usageGuideBody5;
                    break;
                }

                // Determine which image subfolder to use based on current locale
                final languageCode = Localizations.localeOf(context).languageCode;
                const supportedImageLangs = ['ru', 'en'];
                // Fallback to English if the current locale is not explicitly supported
                final imageLang = supportedImageLangs.contains(languageCode) ? languageCode : 'en';

                final imagePath =
                    'assets/images/usage_guide/$imageLang/slide_${index + 1}.png';

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: FractionallySizedBox(
                                widthFactor: 0.8, // на ~20% меньше ширины экрана
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.cardRadius,
                                    ),
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              title,
                              textAlign: TextAlign.left,
                              style: AppTypography.screenTitle.copyWith(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              body,
                              textAlign: TextAlign.left,
                              style: AppTypography.bodySecondary,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildDots(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: _buildBottomButton(_currentPage == _pageCount - 1),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pageCount,
        (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: isActive ? 18 : 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(bool isLastPage) {
    if (isLastPage) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          boxShadow: AppShadows.subtle,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _completeAndClose,
            child: Text(AppLocalizations.of(context)!.usageGuideButtonFillCard),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: AppShadows.subtle,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          child: Text(AppLocalizations.of(context)!.usageGuideButtonNext),
        ),
      ),
    );
  }
}
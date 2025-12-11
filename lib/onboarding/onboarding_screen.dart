import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../analytics/amplitude_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentIndex = 0;
  bool _onboardingStartedLogged = false;

  @override
  void initState() {
    super.initState();
    // Логируем начало онбординга один раз, когда экран впервые показан
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_onboardingStartedLogged) {
        AmplitudeService.instance.logOnboardingStarted();
        _onboardingStartedLogged = true;
      }
    });
  }

  late final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      emoji: '🌊',
      assetName: 'assets/images/onboarding/onboarding_1.png',
      title: 'Часто делаете то, о чём потом жалеете',
      subtitle:
          'Сорвались на близких, напились, накупили лишнего, заели стресс сладким.\n\n'
          'В моменте вроде легче, а потом стыдно и тяжело.\n'
          'И всё повторяется снова и снова.',
    ),
    _OnboardingPageData(
      emoji: '🧠',
      assetName: 'assets/images/onboarding/onboarding_2.png',
      title: 'Wisemind помогает разорвать этот круг',
      subtitle:
          'Приложение на основе DBT — подхода в психотерапии, который учит замечать, что с вами происходит.\n\n'
          'Вы отслеживаете свои реакции, побуждения и импульсы и учитесь влиять на них.',
    ),
    _OnboardingPageData(
      emoji: '📅',
      assetName: 'assets/images/onboarding/onboarding_3.png',
      title: 'Меньше срывов - больше контроля над собой',
      subtitle:
          'С практикой вы раньше замечаете, что «что-то не так» и успеваете остановиться.\n\n'
          'У вас появляется выбор — поддаться побуждению или сделать иначе.\n'
          'Маленькие шаги каждый день постепенно меняют вашу жизнь.',
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    final isLast = _pages[_currentIndex].isLast;
    if (isLast) {
      // Пользователь прошёл онбординг до конца
      AmplitudeService.instance.logOnboardingCompleted();
      widget.onFinished();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onSkip() {
    // steps_total = номер текущего экрана (0‑based) + 1
    final stepsTotal = _currentIndex + 1;
    AmplitudeService.instance.logOnboardingSkipped(stepsTotal: stepsTotal);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель с "Пропустить"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onSkip,
                    child: const Text('Пропустить'),
                  ),
                ],
              ),
            ),

            // Основной контент
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Image.asset(
                                  page.assetName,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          textAlign: TextAlign.left,
                          style: AppTypography.screenTitle,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.left,
                          style: AppTypography.bodySecondary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Индикаторы страниц
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Нижняя кнопка
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  child: Text(
                    _pages[_currentIndex].isLast ? 'Начать' : 'Далее',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String emoji;
  final String assetName;
  final String title;
  final String subtitle;
  final bool isLast;

  _OnboardingPageData({
    required this.emoji,
    required this.assetName,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });
}
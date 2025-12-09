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
      title: 'Когда снова делаете то, о чём потом жалеете',
      subtitle:
          'Сорвались на близких, напились, накупили лишнего, заели стресс сладким. '
          'В моменте вроде легче, а потом стыдно, тяжело и хочется в следующий раз поступить иначе. Но в итоге всё повторяется снова и снова.',
    ),
    _OnboardingPageData(
      emoji: '🧠',
      title: 'Wisemind помогает разорвать этот круг',
      subtitle:
          'Приложение на основе DBT — подхода в психотерапии, который учит замечать, что с вами происходит и как вы реагируете:\n'
          '• практические упражнения для разбора сложных ситуаций "по винтикам"\n'
          '• трекер сна, настроения и поведения - чтобы понимать что повлияло на то, что вы "сорвались"\n'
          '• навыки и медитации — чтобы научиться слышать себя и реагировать на обстоятельства адекватно',
    ),
    _OnboardingPageData(
      emoji: '📅',
      title: 'Меньше срывов. Больше действий в соответствии с вашими целями и желаниями',
      subtitle:
          'С практикой вы начнете раньше замечать, что «что-то не так»: тянетесь к бутылке, к телефону, к корзине покупок, хочется сорваться.'
          'У вас появляется возможность осознанно выбрать - поддаться или нет. Маленькие действия каждый день постепенно меняют поведение, которое впоследствии меняет жизнь.',
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
                      children: [
                        Text(
                          page.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.screenTitle.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
                          ),
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
                child: FilledButton(
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
  final String title;
  final String subtitle;
  final bool isLast;

  _OnboardingPageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });
}
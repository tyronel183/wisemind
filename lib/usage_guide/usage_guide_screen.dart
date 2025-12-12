import 'package:flutter/material.dart';
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

  final _pages = const [
    _GuidePageData(
      title: 'Как Wisemind действительно помогает',
      body:
          'Wisemind не про магию и не про «трекать всё подряд».\n\n'
          'В бесплатной версии уже есть всё, чтобы начать менять поведение: '
          'отмечать состояние, разбирать сложные ситуации и пробовать реагировать по‑новому.\n\n'
          'Но изменения требуют усилий: приложение не сделает работу за вас, '
          'оно помогает идти вперёд шаг за шагом.',
    ),
    _GuidePageData(
      title: 'Шаг 1. Замечать, что с вами происходит',
      body:
          'Менять поведение невозможно, если вы не замечаете, что с вами происходит.\n\n'
          'Поэтому первый блок навыков — «Осознанность» — открыт бесплатно. '
          'С его помощью вы учитесь обращать внимание на:\n'
          '• тело и ощущения\n'
          '• мысли и эмоции\n'
          '• обстановку вокруг\n\n'
          'Так легче вовремя заметить момент, когда обычно начинается срыв.',
    ),
    _GuidePageData(
      title: 'Шаг 2. Определить своё проблемное поведение',
      body:
          'Сначала честно назовите, что именно для вас проблема: алкоголь, '
          'ссоры с близкими, переедание, курение, импульсивные покупки и так далее.\n\n'
          'Затем каждый вечер заполняйте «Карту дня». Со временем вы увидите связи между '
          'недосыпом, стрессом, отсутствием отдыха и другими факторами, которые подталкивают '
          'к срывам и привычному проблемному поведению.',
    ),
    _GuidePageData(
      title: 'Шаг 3. Разбирать срывы и тренировать навыки',
      body:
          'Срывы неизбежны — это не провал, а материал для работы.\n\n'
          'Используйте рабочие листы, чтобы по шагам разобрать, что произошло до, во время '
          'и после эпизода. Навыки DBT разделены на 4 блока:\n'
          '• осознанность\n'
          '• устойчивость к стрессу\n'
          '• регулирование эмоций\n'
          '• межличностная эффективность\n\n'
          'Осваивайте их постепенно, мы рекомендуем по одному навыку в неделю — '
          'и оставляйте в арсенале то, что лучше всего работает именно для вас.',
    ),
    _GuidePageData(
      title: 'Поехали?',
      body:
          'Мы будем добавлять новые инструменты, практики и медитации, '
          'чтобы поддерживать вас на пути изменений.\n\n'
          'А сейчас сделайте первый шаг — заполните первую запись в разделе '
          '«Моё состояние».\n\n'
          'Вы ответите на простые вопросы о сне, самочувствии и эмоциях. '
          'Если возвращаться к этому каждый день, постепенно формируется привычка, '
          'которая со временем меняет поведение.',
      isLast: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Как пользоваться Wisemind'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                AmplitudeService.instance
                    .logHomeGuideStepViewed(stepIndex: index + 1);
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                final imagePath =
                    'assets/images/usage_guide/slide_${index + 1}.png';

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
                              page.title,
                              textAlign: TextAlign.left,
                              style: AppTypography.screenTitle.copyWith(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.body,
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
            child: _buildBottomButton(_pages[_currentPage]),
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
        _pages.length,
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

  Widget _buildBottomButton(_GuidePageData page) {
    if (page.isLast) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          boxShadow: AppShadows.subtle,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _completeAndClose,
            child: const Text('Заполнить карту дня'),
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
          child: const Text('Далее'),
        ),
      ),
    );
  }
}

class _GuidePageData {
  final String title;
  final String body;
  final bool isLast;

  const _GuidePageData({
    required this.title,
    required this.body,
    this.isLast = false,
  });
}
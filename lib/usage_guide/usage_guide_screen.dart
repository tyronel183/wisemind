import 'package:flutter/material.dart';
import '../analytics/amplitude_service.dart';

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
          'Это не магическое решение и не очередной трекер привычек. В бесплатной версии уже есть всё, чтобы начать менять своё поведение: отмечать состояние, разбирать сложные ситуации и пробовать реагировать и поступать по-новому. Но изменения требуют усилий: приложение не сделает работу за вас, но оно сильно поможет вам пройти путь шаг за шагом.',
    ),
    _GuidePageData(
      title: 'Шаг 1. Замечать, что с вами происходит',
      body:
          'Менять поведение невозможно, если вы не замечаете, что с вами происходит. Поэтому первый блок навыков — «Осознанность» — открыт бесплатно. Здесь вы учитесь обращать внимание на тело, мысли и обстановку, чтобы вовремя увидеть момент, когда обычно начинается срыв, переходящий в проблемное поведение.',
    ),
    _GuidePageData(
      title: 'Шаг 2. Определить своё проблемное поведение',
      body:
          'Сначала честно назовите, что именно для вас является проблемой: алкоголь, ссоры с близкими, переедание, курение, импульсивные покупки и так далее. Затем каждый вечер заполняйте «Карту дня». Со временем вы увидите связи: недосып, стресс, отсутствие отдыха и другие факторы, которые подталкивают вас к срывам и проблемному поведению.',
    ),
    _GuidePageData(
      title: 'Шаг 3. Разбирать срывы и тренировать навыки',
      body:
          'Срывы неизбежны — это не провал, а материал для работы. Используйте рабочие листы, чтобы разобрать по шагам, что произошло до, во время и после эпизода. Навыки DBT разделены на 4 блока: осознанность, устойчивость к стрессу, регулирование эмоций, межличностная эффективность. Осваивайте их постепенно, мы рекомендуем по одному навыку в неделю — и оставляйте в своём арсенале те, что лучше всего работают именно для вас.',
    ),
    _GuidePageData(
      title: 'Поехали?',
      body:
          'По мере развития Wisemind мы будем добавлять новые инструменты, практики и медитации, чтобы поддерживать вас на пути изменений. А пока сделайте первый шаг — заполните первую запись в разделе «Моё состояние сегодня». Мы зададим вам простые вопросы о сне, самочувствии и эмоциях, а дальше вы сможете возвращаться к этому каждый день. Так формируется привычка, которая со временем меняет ваше поведение.',
      isLast: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Как пользоваться Wisemind'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _completeAndClose,
          ),
        ],
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
                // Логируем просмотр шага минигайда
                AmplitudeService.instance
                    .logHomeGuideStepViewed(stepIndex: index + 1);
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(page.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      Text(page.body),
                      const Spacer(),
                      _buildBottomButton(page),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildDots(),
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
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentPage ? Colors.blueGrey : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(_GuidePageData page) {
    if (page.isLast) {
      return ElevatedButton(
        onPressed: _completeAndClose,
        child: const Text('Заполнить карту дня'),
      );
    }

    return FilledButton(
      onPressed: () {
        _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: const Text('Далее'),
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
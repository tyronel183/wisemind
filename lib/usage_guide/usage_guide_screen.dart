import 'package:flutter/material.dart';

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

  final _pages = const [
    _GuidePageData(
      title: 'Как Wisemind помогает',
      body: 'Коротко: это тренажёр для Мудрого разума. Ты отмечаешь состояние, разбираешь сложные ситуации и тренируешь навыки DBT.',
    ),
    _GuidePageData(
      title: 'Шаг 1. Карта дня',
      body: 'Каждый день — 1–2 минуты на отметку сна, самочувствия и эмоций. Это даёт тебе историю, а не хаотичные воспоминания.',
    ),
    _GuidePageData(
      title: 'Шаг 2. Рабочие листы',
      body: 'Когда что-то пошло не так — разбираешь через лист: цепочка, за и против, проверка фактов.',
    ),
    _GuidePageData(
      title: 'Шаг 3. Медитации и навыки',
      body: 'Когда накрывает — медитации и навыки помогают вернуться в точку опоры и не улететь в автопилот.',
    ),
    _GuidePageData(
      title: 'Поехали?',
      body: 'Давай начнём с первой «Карты дня». Это займёт пару минут, но заложит основу привычки.',
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
        onPressed: () async {
          // Вызываем колбэк, если он передан
          widget.onCompleted?.call();
          // TODO: позже можно добавить переход на экран "Новая карта дня"
          Navigator.of(context).pop();
        },
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
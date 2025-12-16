import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

import 'meditation.dart';

class MeditationRepository {
  MeditationRepository._();

  static final MeditationRepository _instance = MeditationRepository._();

  static MeditationRepository get instance => _instance;

  // Current in-memory list of meditations.
  // By default it contains the built-in Russian fallback until JSON is loaded.
  List<Meditation> _items = List.unmodifiable(_fallbackAll);

  /// Loads meditations for the given [locale] from bundled JSON.
  /// If loading fails, keeps previously loaded data or falls back to built-in list.
  static Future<List<Meditation>> loadForLocale(Locale locale) {
    return _instance._loadForLocale(locale);
  }

  /// Returns the currently loaded list of meditations.
  /// Initially this is a built-in Russian fallback until [loadForLocale] is called.
  static List<Meditation> getAll() {
    return List.unmodifiable(_instance._items);
  }

  Future<List<Meditation>> _loadForLocale(Locale locale) async {
    final languageCode = locale.languageCode.toLowerCase();
    final assetPath = languageCode == 'en'
        ? 'assets/data/meditations-en.json'
        : 'assets/data/meditations-ru.json';

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final items = jsonList
          .map((e) => Meditation.fromJson(e as Map<String, dynamic>))
          .toList();
      _items = List.unmodifiable(items);
    } catch (e) {
      // If something goes wrong, keep whatever is already in _items
      // (either previous locale or the built-in fallback list).
    }

    return _items;
  }

  // Built-in Russian fallback list, used until JSON is loaded.
  static final List<Meditation> _fallbackAll = [
    Meditation(
      id: 'breath_observation',
      title: 'Наблюдение дыхания',
      situation: 'Успокоиться и вернуть внимание к телу',
      description:
          'Простая практика фокусировки на дыхании, возвращающая к настоящему моменту',
      category: 'Осознанность',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/lplb2qhftfiwa3v5dkrad/1_-_-_-_V2.mp3?rlkey=rf1f7em41g25rzoamfrgxnbff&st=6fkmak1t&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/7qqjl7py8y9ic06r1d7ht/1_-_-_-_-_-_V3.mp3?rlkey=oaj2qz7iplb464yqnk75vdzro&st=7sttbjz3&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/tLshPYsWxKEbvkgezxxX.png',
      isFree: true,
      dbtSkill: 'Наблюдение',
      duration: '6,5 мин',
    ),
    Meditation(
      id: 'mindful_listening',
      title: 'Осознанное слушание',
      situation: 'Остановить внутренний шум',
      description:
          'Фокус на звуках вокруг — способ замедлиться и почувствовать присутствие',
      category: 'Осознанность',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/ezo2znxq09cw5y6fxvgvu/2_-_-_V1.mp3?rlkey=29b99ikbpp7jum26stqvtt72r&st=1liqe7v9&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/tygx9kmmq3p1d2ngd54cg/2_-_-_-_-_V2.mp3?rlkey=wpgy5aqgezeuiy9tknkdpcop5&st=rybr0zsh&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/Doc8gTiRmXToiXoJdxwW.png',
      isFree: true,
      dbtSkill: 'Однозадачность',
      duration: '5,5 мин',
    ),
    Meditation(
      id: 'mindful_thought_observation',
      title: 'Осознанное наблюдение мыслей',
      situation: 'Перестать навязчиво думать о чём-то',
      description:
          'Практика наблюдения за мыслями без вовлечения — как за облаками на небе',
      category: 'Осознанность',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/zif7ka4igmly8vfhkh7ed/3_-_-_-_V1.mp3?rlkey=st6s46tz0o3iy9y62zpnpunn0&st=h49hsfmi&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/uujwbw9gnrnncck6spc51/3_-_-_-_-_-_V2.mp3?rlkey=67p11v6me8938r2ml0ze3nlxz&st=zl75eghg&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/73yjZUvDnh7zUE2lO4QA.png',
      isFree: true,
      dbtSkill: 'Безоценочность',
      duration: '6 мин',
    ),
    Meditation(
      id: 'wise_mind',
      title: 'Мудрый разум',
      situation: 'Принять решение',
      description:
          'Медитация на соединение рационального и эмоционального ума',
      category: 'Осознанность',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/bug1u0js1cscrlxhu3b3b/4_-_-_V1.mp3?rlkey=lxxqgjxdmw5kfngb8igcyniv5&st=shjoeskq&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/di8m57q1kssai7pt7glay/4_-_-_-_-_V2.mp3?rlkey=urr6rgm4gosdxshnitvhgi2rw&st=vsjvpos7&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/5wg8HgAOh8MdKOyyvYCD.png',
      isFree: true,
      dbtSkill: 'Мудрый разум',
      duration: '6 мин',
    ),
    Meditation(
      id: 'mindful_movement',
      title: 'Осознанное движение',
      situation: 'Сосредоточиться',
      description:
          'Ходьба или движение с вниманием к телу и дыханию',
      category: 'Осознанность',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/x9l5dttj31mkmit76bx3s/5_-_-_V1.mp3?rlkey=tg4zpw8lt83z1mb9y0avvpex0&st=umutj7n0&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/vbd882dkdy3f70nbqv5zk/5_-_-_-_-_V2.mp3?rlkey=ebkqltmha03c9indpgsai9wio&st=6yqaqtm3&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/mDj3rWfF5UCGuww1ST4v.png',
      isFree: true,
      dbtSkill: 'Присутствие',
      duration: '4,5 мин',
    ),
    Meditation(
      id: 'nonjudgemental_emotion_acceptance',
      title: 'Принятие эмоций без оценки',
      situation: 'Меня захлестнули чувства',
      description:
          'Помогает принять эмоцию без борьбы и сопротивления',
      category: 'Регуляция эмоций',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/2ebgkay8wlsxy2wrwbvat/6_-_-_-_-_V1.mp3?rlkey=ur1wpqd8tlkbotcs3tslq8lre&st=lja4xf7e&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/hfuif331az6nr8m26z51z/6_-_-_-_-_-_-_V3.mp3?rlkey=wgbg3yjfharzbfm7468sh46bn&st=n90eray8&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/J1G9aEfzisFoNgKkq0Wp.png',
      isFree: true,
      dbtSkill: 'Безоценочность',
      duration: '5 мин',
    ),
    Meditation(
      id: 'letting_go_of_anger',
      title: 'Отпускание злости',
      situation: 'Злюсь или чувствую раздражение',
      description:
          'Медитация отпускания напряжения через дыхание и тело',
      category: 'Регуляция эмоций',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/6wu5prnl9myol5jt5rhy3/11_-_-_7_-_-_V3.mp3?rlkey=m8vyp4a4pc69al01h8jl4q99n&st=bssq8mrw&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/swwsl5w21unfnnxie8ea7/11_-_-_-_-_7_-_-_V4.mp3?rlkey=0ff0dx0q71yh6ljpy963bnafz&st=zlz3nmzt&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/bjLHtXEMUkHNxcV5vLU9.png',
      isFree: true,
      dbtSkill: 'Регуляция',
      duration: '7 мин',
    ),
    Meditation(
      id: 'self_compassion',
      title: 'Сострадание к себе',
      situation: 'Ругаю себя, чувствую вину или стыд',
      description:
          'Развитие доброжелательного отношения к себе',
      category: 'Принятие себя',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/ea39yvkoqgjcoy478vzs1/7_-_-_-_V1.mp3?rlkey=yhp60j1udb1rop11vv6k1sswi&st=18ij1vph&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/7cbr452lo8bukdws4w0vq/7_-_-_-_-_-_V2.mp3?rlkey=00g3bbsdfig7ov4p6gw0me1hl&st=ghyxyl90&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/iDODt1EA4IiT60b9FsAr.png',
      isFree: true,
      dbtSkill: 'Самосострадание',
      duration: '6 мин',
    ),
    Meditation(
      id: 'letting_go_of_self_criticism',
      title: 'Отпускание самокритики',
      situation: 'Чувствую, что ничего  не заслуживаю',
      description:
          'Мягкая практика отпускания внутреннего критика',
      category: 'Принятие себя',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/irwqjz30thzm0hxfn9d3c/8_-_-_V1.mp3?rlkey=wfuy4gnxza8jwxotwublj7593&st=6j2lre50&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/aiif45cufsttse1ox9u8l/8_-_-_-_-_V2.mp3?rlkey=opptwfunp4iyt21jib1i3v5ot&st=n2a7xhog&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/1fFwy1Ix7Tip1Q1b4Tr7.png',
      isFree: true,
      dbtSkill: 'Самопринятие',
      duration: '6 мин',
    ),
    Meditation(
      id: 'accepting_imperfection',
      title: 'Принятие несовершенства',
      situation: 'Сложно принять ошибки',
      description:
          'Медитация о том, что несовершенство — часть человеческого опыта',
      category: 'Принятие себя',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/0v29eke7xp3tnjktujw9h/9_-_-_V1.mp3?rlkey=9v1ifad2eoeqp8b27hrssemrl&st=zw1l1a6t&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/milxvokx00t8vfov8lhf5/9_-_-_-_-_V2.mp3?rlkey=zvi7fv00kzjgqp7iss5jnvkly&st=1kp9c75i&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/q2ttN5tXUKl2fEHWBRdD.png',
      isFree: true,
      dbtSkill: 'Радикальное принятие',
      duration: '6 мин',
    ),
    Meditation(
      id: 'radical_acceptance',
      title: 'Радикальное принятие',
      situation: 'Не могу отпустить ситуацию',
      description:
          'Практика смирения и отпускания контроля',
      category: 'Снижение стресса',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/yct66xqnks58wi09kfg2w/10_-_-_V1.mp3?rlkey=1tydgumtfle6j5skfskhanyuw&st=72tg963z&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/9fvo4ysvecuapgkz1x5yc/10_-_-_-_-_V2.mp3?rlkey=6ohpwufc2000zf7ceyyddhoi6&st=ygj52fiz&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/YMMCuPiSGQJ06Hx7o4I0.png',
      isFree: true,
      dbtSkill: 'Радикальное принятие',
      duration: '7,5 мин',
    ),
    Meditation(
      id: 'safe_place',
      title: 'Безопасное место',
      situation: 'Почувствовать покой',
      description:
          'Визуализация внутреннего пространства безопасности',
      category: 'Снижение стресса',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/dgqoe2fwt35awxbrj6zjp/12_-_-_V3.mp3?rlkey=w9kgiy4s9mebz3is6320ntc0q&st=ya50jwrn&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/s7tw9tayfns4zsltlpxwt/12_-_-_-_-_V4.mp3?rlkey=n2m0cpzmfjtzhq8ftgb4wv9fh&st=fx5u0v73&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/TSBEebXM7UTR2VubD4mw.png',
      isFree: true,
      dbtSkill: 'Самоуспокоение',
      duration: '6,5 мин',
    ),
    Meditation(
      id: 'five_senses',
      title: 'Пять чувств',
      situation: 'Быстро успокоиться и снизить накал эмоций',
      description:
          'Переключение внимания на ощущения через органы чувств',
      category: 'Снижение стресса',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/z4pvt2z1n7p6lwr00y22o/13_-_-_V2.mp3?rlkey=s3rrejd9gkabhxtf52n63ciu1&st=o4sq624q&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/m3vq1u7b6rd6svg66tgkw/13_-_-_-_-_V3.mp3?rlkey=8wycvwzw6knjk6pl9imcxxcc6&st=68av4pph&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/PFoY6HiF6EAm74Dc0N3w.png',
      isFree: true,
      dbtSkill: 'Заземление',
      duration: '6,5 мин',
    ),
    Meditation(
      id: 'letting_go_of_control',
      title: 'Отпускание контроля',
      situation: 'Всё идёт не по плану',
      description:
          'Помогает довериться процессу и отпустить ожидания',
      category: 'Снижение стресса',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/6ebmzzhtxxlov4pyfdgi9/14_-_-_V2.mp3?rlkey=79tpfxw9880nkfrt7iu8c02vb&st=en0whe5d&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/4vetx9nu3g87duimu1opn/14_-_-_-_-_V3.mp3?rlkey=ld7uh26m9jc4sn7i36uhn28gy&st=zidfeu0l&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/OTmz1137PzI1FBbq9qV6.png',
      isFree: true,
      dbtSkill: 'Принятие',
      duration: '5,5 мин',
    ),
    Meditation(
      id: 'anxiety_breathing',
      title: 'Осознанное дыхание при тревоге',
      situation: 'Тревога, паника',
      description:
          'Успокаивающая дыхательная практика при сильном беспокойстве',
      category: 'Регуляция эмоций',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/fgi5oib3b3ynh30up6c5o/15_-_-_-_-_V1.mp3?rlkey=t6lzkf35zytijuyu6snidk6l9&st=bgmkgtwq&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/5cbfm27l95ji6lum7c3jh/15_-_-_-_-_-_-_V2.mp3?rlkey=7z3jijoki0iozvy11ktsrip46&st=h4ebhd3f&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/8BYLyo3olzI7mTmfTqnF.png',
      isFree: true,
      dbtSkill: 'Заземление',
      duration: '4,5 мин',
    ),
    Meditation(
      id: 'being_with_other',
      title: 'Присутствие с другим',
      situation: 'Волнуюсь перед разговором',
      description:
          'Практика внимательного присутствия с другим человеком',
      category: 'Межличностная эффективность',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/rmlad6pr04fw9qnims8cf/16_-_-_-_V1.mp3?rlkey=ldw4yxv01pq8swzsk3qfi2pts&st=dtb5bes3&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/v968d6mq1cycy354in4pp/16_-_-_-_-_-_V2.mp3?rlkey=cj6zbd54578l344m366txbzna&st=vrlg15h1&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/g5Dy3D6HCmCkqttPHviy.png',
      isFree: true,
      dbtSkill: 'Эмпатическое присутствие',
      duration: '7 мин',
    ),
    Meditation(
      id: 'mindful_no',
      title: 'Осознанное “нет”',
      situation: 'Нужно сохранить свои границы',
      description:
          'Медитация на уверенность в отказе без вины',
      category: 'Межличностная эффективность',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/0ozqn8ft0jtoq97lckv82/17_-_-_V1.mp3?rlkey=wtixbwh11skqnfef9wufxowl7&st=gqw6mosm&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/s0u3ids9leuite0l42gqz/17_-_-_-_-_V2.mp3?rlkey=4i6nhh11h9qojw3qumxpqf794&st=omg0tivx&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/E6IcFx3rc4wKW87rZ0We.png',
      isFree: true,
      dbtSkill: 'Самоуважение',
      duration: '6 мин',
    ),
    Meditation(
      id: 'gratitude_and_kindness',
      title: 'Благодарность и доброжелательность',
      situation: 'Хочу вернуть тепло к людям',
      description:
          'Развитие благодарности и мягкости',
      category: 'Межличностная эффективность',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/43wd6m49irvyeehyv3vos/18_-_-_-_V1.mp3?rlkey=0eprb8frxb5qxlovv0ciujjkw&st=j8awf6kp&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/a2vqpy9h01kermyb4qpu7/18_-_-_-_-_-_V2.mp3?rlkey=b7wgbr2dcrrckuexeh2guey15&st=ffjov2t5&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/95DlFg8LbKdlDmGJUMrT.png',
      isFree: true,
      dbtSkill: 'Эмпатия',
      duration: '6,5 мин',
    ),
    Meditation(
      id: 'soft_return_to_self',
      title: 'Мягкое возвращение к себе',
      situation: 'Устал(а), выгорел(а), хочу тепла',
      description:
          'Тёплая медитация на возвращение внимания внутрь',
      category: 'Принятие себя',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/snpd7jo033qnjt8wxt45b/19..wav?rlkey=p176an4oy3846o14uhj3sr7ps&st=uy6m9hfp&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/y01mch7ka6lsd1nyaocpy/19_-_-_-_-_-_-_V2.mp3?rlkey=wngz9792rxi9wjccv2s6kszdu&st=hod6zalt&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/xbsJ1PyZa7SlJBbQyiqL.png',
      isFree: true,
      dbtSkill: 'Нежное присутствие',
      duration: '7 мин',
    ),
    Meditation(
      id: 'mindful_i_am',
      title: 'Осознанное “я есть”',
      situation: 'Хочу вернуть ощущение жизни',
      description:
          'Простое пребывание в ощущении бытия',
      category: 'Принятие себя',
      audioWithVoiceUrl:
          'https://dl.dropbox.com/scl/fi/ofb5d3bo0ft636c2xyui0/20_-_-_-_V1.mp3?rlkey=0znwkq1c5xlgxkxxckh3vloyi&st=bpayn6f6&dl=0',
      audioWithoutVoiceUrl:
          'https://dl.dropbox.com/scl/fi/4czxc81k437rt0ibys6ls/20_-_-_-_-_-_V2.mp3?rlkey=d3fxilac3pif3k8lt2mbqqwu1&st=0f0q1lsk&dl=0',
      imageUrl:
          'https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/EdHBi0YbKHhuXMfjjrzS/pub/F3RtWe5nyXAsEU0hFGaK.png',
      isFree: true,
      dbtSkill: 'Присутствие',
      duration: '8 мин',
    ),
  ];
}
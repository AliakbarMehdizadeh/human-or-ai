import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// One prompt plus the pool of pre-written bot answers for it.
class Question {
  const Question(this.text, this.bots);

  final String text;
  final List<String> bots;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        json['q'] as String,
        (json['bots'] as List).cast<String>(),
      );
}

class QuestionBank {
  static Future<List<Question>> load() async {
    final raw = await rootBundle.loadString('assets/questions.json');
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .where((q) => q.bots.length >= 2)
        .toList();
  }
}

/// One card in the lineup.
class Answer {
  const Answer(this.text, {required this.isHuman});

  final String text;
  final bool isHuman;
}

enum Phase { handToWriter, write, handToGuesser, lineup, reveal, finished }

/// Pass-and-play game state. Two players take turns:
/// the writer answers a prompt, then the guesser sees that answer
/// mixed with two bot answers and has to find the human.
class Game extends ChangeNotifier {
  Game({
    required this.names,
    required this.roundsEach,
    required List<Question> questions,
    Random? rng,
  })  : _rng = rng ?? Random(),
        _deck = List.of(questions) {
    _deck.shuffle(_rng);
    _startTurn();
  }

  static const botsPerLineup = 2;

  final List<String> names;
  final int roundsEach;
  final Random _rng;
  final List<Question> _deck;
  int _cursor = 0;

  int turn = 0;
  final List<int> scores = [0, 0];
  final List<int> spotted = [0, 0];
  final List<int> blended = [0, 0];

  Phase phase = Phase.handToWriter;
  late Question question;
  String humanAnswer = '';
  List<Answer> lineup = const [];
  int? picked;

  int get totalTurns => roundsEach * 2;
  int get writer => turn % 2;
  int get guesser => 1 - writer;
  bool get isLastTurn => turn + 1 >= totalTurns;
  bool get guessedRight => picked != null && lineup[picked!].isHuman;

  /// Index of the leading player, or null on a draw.
  int? get winner {
    if (scores[0] == scores[1]) return null;
    return scores[0] > scores[1] ? 0 : 1;
  }

  void _startTurn() {
    question = _deck[_cursor % _deck.length];
    _cursor++;
    humanAnswer = '';
    lineup = const [];
    picked = null;
    phase = Phase.handToWriter;
  }

  void writerReady() {
    phase = Phase.write;
    notifyListeners();
  }

  void submitAnswer(String text) {
    humanAnswer = text.trim();
    final bots = List.of(question.bots)..shuffle(_rng);
    final cards = <Answer>[
      Answer(humanAnswer, isHuman: true),
      for (final b in bots.take(botsPerLineup)) Answer(b, isHuman: false),
    ]..shuffle(_rng);
    lineup = cards;
    phase = Phase.handToGuesser;
    notifyListeners();
  }

  void guesserReady() {
    phase = Phase.lineup;
    notifyListeners();
  }

  void pick(int index) {
    if (phase != Phase.lineup) return;
    picked = index;
    if (lineup[index].isHuman) {
      scores[guesser]++;
      spotted[guesser]++;
    } else {
      scores[writer]++;
      blended[writer]++;
    }
    phase = Phase.reveal;
    notifyListeners();
  }

  void next() {
    if (isLastTurn) {
      phase = Phase.finished;
    } else {
      turn++;
      _startTurn();
    }
    notifyListeners();
  }

  void rematch() {
    turn = 0;
    for (var i = 0; i < 2; i++) {
      scores[i] = 0;
      spotted[i] = 0;
      blended[i] = 0;
    }
    _startTurn();
    notifyListeners();
  }
}

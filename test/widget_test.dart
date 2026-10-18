import 'package:flutter_test/flutter_test.dart';
import 'package:human_or_ai/game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const qs = [
    Question('Q1?', ['a', 'b', 'c']),
    Question('Q2?', ['d', 'e', 'f']),
  ];

  test('question file loads and every question has enough bots', () async {
    final bank = await QuestionBank.load();
    expect(bank.length, greaterThanOrEqualTo(30));
    for (final q in bank) {
      expect(q.bots.length, greaterThanOrEqualTo(Game.botsPerLineup));
    }
  });

  test('lineup has exactly one human and two bots', () {
    final g = Game(names: ['A', 'B'], roundsEach: 1, questions: qs);
    g.writerReady();
    g.submitAnswer('  teacher ');
    expect(g.lineup.length, 3);
    expect(g.lineup.where((a) => a.isHuman).single.text, 'teacher');
  });

  test('finding the human scores for the guesser, missing scores for the writer', () {
    final g = Game(names: ['A', 'B'], roundsEach: 1, questions: qs);
    g.writerReady();
    g.submitAnswer('vet');
    g.guesserReady();
    g.pick(g.lineup.indexWhere((a) => a.isHuman));
    expect(g.scores, [0, 1]); // turn 1: A writes, B guesses

    g.next();
    g.writerReady();
    g.submitAnswer('pilot');
    g.guesserReady();
    g.pick(g.lineup.indexWhere((a) => !a.isHuman));
    expect(g.scores, [0, 2]); // turn 2: B writes and fools A
    expect(g.isLastTurn, isTrue);
    g.next();
    expect(g.phase, Phase.finished);
    expect(g.winner, 1);
  });
}

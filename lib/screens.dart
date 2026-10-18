import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'game.dart';
import 'theme.dart';

// ---------------------------------------------------------------------------
// Home
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();
  late final Future<List<Question>> _questions = QuestionBank.load();
  int _rounds = 3;

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  String _name(TextEditingController c, String fallback) {
    final t = c.text.trim();
    return t.isEmpty ? fallback : t;
  }

  Future<void> _start() async {
    final questions = await _questions;
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    final game = Game(
      names: [_name(_p1, 'Player 1'), _name(_p2, 'Player 2')],
      roundsEach: _rounds,
      questions: questions,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GameScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            const Logo(),
            const SizedBox(height: 28),
            Text('PASS-AND-PLAY PARTY GAME', style: labelStyle(context)),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Two of these answers are '),
                TextSpan(text: 'bots', style: TextStyle(color: p.bot)),
                const TextSpan(text: '. Find the '),
                TextSpan(text: 'human', style: TextStyle(color: p.human)),
                const TextSpan(text: '.'),
              ]),
              style: text.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: -0.8,
                color: p.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Take turns on one phone. You answer a question, two bots answer too, '
              'and the other player has to pick out the real person.',
              style: text.bodyLarge?.copyWith(color: p.muted, height: 1.4),
            ),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _p1,
                  maxLength: 12,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Player 1', counterText: ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _p2,
                  maxLength: 12,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Player 2', counterText: ''),
                ),
              ),
            ]),
            const SizedBox(height: 18),
            Text('ROUNDS EACH', style: labelStyle(context)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 5, label: Text('5')),
              ],
              selected: {_rounds},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _rounds = s.first),
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<Question>>(
              future: _questions,
              builder: (context, snap) => FilledButton(
                onPressed: snap.hasData ? _start : null,
                child: const Text('Start game'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => showHowToPlay(context),
              child: const Text('How to play'),
            ),
          ],
        ),
      ),
    );
  }
}

void showHowToPlay(BuildContext context) {
  final p = Pal.of(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: p.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to play',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const _Rule(n: '1', text: 'The writer answers a question. Keep it short, like a text message.'),
            const _Rule(n: '2', text: 'Two bots answer the same question.'),
            const _Rule(n: '3', text: 'The guesser sees all three answers and picks the human.'),
            const SizedBox(height: 8),
            _Point(color: p.human, text: '+1 guesser for finding the human'),
            _Point(color: p.bot, text: '+1 writer for hiding among the bots'),
            const SizedBox(height: 12),
            Text(
              'Writer tip: sound like a bot, or answer the opposite of what people expect from you.',
              style: TextStyle(color: p.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Rule extends StatelessWidget {
  const _Rule({required this.n, required this.text});
  final String n, text;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: p.ink,
          child: Text(n,
              style: TextStyle(
                  color: p.bg, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ]),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(Icons.add_circle, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Game
// ---------------------------------------------------------------------------

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.game});
  final Game game;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Game get game => widget.game;

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  Future<void> _confirmQuit() async {
    if (game.phase == Phase.finished) {
      Navigator.of(context).pop();
      return;
    }
    final quit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit this game?'),
        content: const Text('The score will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep playing')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Quit')),
        ],
      ),
    );
    if (quit == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) => PopScope(
        canPop: game.phase == Phase.finished,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _confirmQuit();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Quit game',
              onPressed: _confirmQuit,
            ),
            title: const Logo(size: 18),
            actions: [ScoreChip(game: game), const SizedBox(width: 12)],
          ),
          body: SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, if (current != null) current],
              ),
              child: KeyedSubtree(
                key: ValueKey('${game.turn}-${game.phase}'),
                child: _body(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final g = game;
    final turnLabel = 'TURN ${g.turn + 1} OF ${g.totalTurns}';
    switch (g.phase) {
      case Phase.handToWriter:
        return HandOff(
          eyebrow: turnLabel,
          title: 'Pass the phone to',
          name: g.names[g.writer],
          subtitle: '${g.names[g.guesser]}, look away. You guess next.',
          button: "I'm ${g.names[g.writer]}, show my question",
          onPressed: g.writerReady,
        );
      case Phase.write:
        return WriteView(game: g);
      case Phase.handToGuesser:
        return HandOff(
          eyebrow: turnLabel,
          title: 'Now pass it to',
          name: g.names[g.guesser],
          subtitle: '${g.names[g.writer]}, keep a straight face.',
          button: "I'm ${g.names[g.guesser]}, show the lineup",
          onPressed: g.guesserReady,
        );
      case Phase.lineup:
        return LineupView(game: g);
      case Phase.reveal:
        return RevealView(game: g);
      case Phase.finished:
        return FinishedView(game: g);
    }
  }
}

class HandOff extends StatelessWidget {
  const HandOff({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.name,
    required this.subtitle,
    required this.button,
    required this.onPressed,
  });

  final String eyebrow, title, name, subtitle, button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Icon(Icons.screen_rotation_alt_rounded, size: 48, color: p.accent),
          const SizedBox(height: 20),
          Text(eyebrow, style: labelStyle(context)),
          const SizedBox(height: 8),
          Text(title,
              style: text.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: p.ink)),
          Text(name,
              style: text.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: p.accent,
                  letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Text(subtitle,
              style: text.bodyLarge?.copyWith(color: p.muted, height: 1.4)),
          const Spacer(flex: 2),
          FilledButton(onPressed: onPressed, child: Text(button)),
        ],
      ),
    );
  }
}

class WriteView extends StatefulWidget {
  const WriteView({super.key, required this.game});
  final Game game;

  @override
  State<WriteView> createState() => _WriteViewState();
}

class _WriteViewState extends State<WriteView> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    if (_c.text.trim().length < 2) return;
    FocusScope.of(context).unfocus();
    widget.game.submitAnswer(_c.text);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final p = Pal.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text('${g.names[g.writer].toUpperCase()}, ANSWER AS YOURSELF',
            style: labelStyle(context)),
        const SizedBox(height: 10),
        PromptCard(text: g.question.text),
        const SizedBox(height: 16),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _c,
          builder: (context, value, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _c,
                autofocus: true,
                maxLength: 120,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: 'Type it like a text message',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: value.text.trim().length >= 2 ? _submit : null,
                child: const Text('Lock it in'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.lightbulb_outline, size: 20, color: p.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You score if ${g.names[g.guesser]} picks a bot instead of you. '
              'Bots write short and casual. Blend in, or say something nobody expects from you.',
              style: TextStyle(color: p.muted, height: 1.4),
            ),
          ),
        ]),
      ],
    );
  }
}

class LineupView extends StatefulWidget {
  const LineupView({super.key, required this.game});
  final Game game;

  @override
  State<LineupView> createState() => _LineupViewState();
}

class _LineupViewState extends State<LineupView> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text('${g.names[g.guesser].toUpperCase()}, WHICH ONE IS HUMAN?',
            style: labelStyle(context)),
        const SizedBox(height: 10),
        PromptCard(text: g.question.text),
        const SizedBox(height: 16),
        for (var i = 0; i < g.lineup.length; i++) ...[
          AnswerTile(
            letter: String.fromCharCode(65 + i),
            text: g.lineup[i].text,
            selected: _selected == i,
            onTap: () => setState(() => _selected = i),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        FilledButton(
          onPressed: _selected == null ? null : () => g.pick(_selected!),
          child: const Text("That's the human"),
        ),
      ],
    );
  }
}

class RevealView extends StatelessWidget {
  const RevealView({super.key, required this.game});
  final Game game;

  @override
  Widget build(BuildContext context) {
    final g = game;
    final p = Pal.of(context);
    final right = g.guessedRight;
    final verdict = right
        ? '${g.names[g.guesser]} found the human.'
        : '${g.names[g.writer]} fooled ${g.names[g.guesser]}.';
    final note = right
        ? '+1 to ${g.names[g.guesser]}.'
        : '+1 to ${g.names[g.writer]} for hiding among the bots.';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text('TURN ${g.turn + 1} OF ${g.totalTurns}', style: labelStyle(context)),
        const SizedBox(height: 8),
        Text(verdict,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: right ? p.human : p.bot)),
        const SizedBox(height: 4),
        Text(note, style: TextStyle(color: p.muted)),
        const SizedBox(height: 16),
        PromptCard(text: g.question.text),
        const SizedBox(height: 16),
        for (var i = 0; i < g.lineup.length; i++) ...[
          AnswerTile(
            letter: String.fromCharCode(65 + i),
            text: g.lineup[i].text,
            selected: g.picked == i,
            stamp: g.lineup[i].isHuman ? Stamp.human : Stamp.bot,
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        FilledButton(
          onPressed: g.next,
          child: Text(g.isLastTurn ? 'See final score' : 'Next turn'),
        ),
      ],
    );
  }
}

class FinishedView extends StatelessWidget {
  const FinishedView({super.key, required this.game});
  final Game game;

  @override
  Widget build(BuildContext context) {
    final g = game;
    final p = Pal.of(context);
    final w = g.winner;
    final title = w == null ? "It's a draw." : '${g.names[w]} wins.';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text('FINAL SCORE', style: labelStyle(context)),
        const SizedBox(height: 8),
        Text(title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800, color: p.ink, letterSpacing: -0.5)),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
            },
            children: [
              TableRow(children: [
                _cell(context, 'PLAYER', header: true),
                _cell(context, 'FOUND', header: true, end: true),
                _cell(context, 'FOOLED', header: true, end: true),
                _cell(context, 'TOTAL', header: true, end: true),
              ]),
              for (var i = 0; i < 2; i++)
                TableRow(children: [
                  _cell(context, g.names[i]),
                  _cell(context, '${g.spotted[i]}', end: true),
                  _cell(context, '${g.blended[i]}', end: true),
                  _cell(context, '${g.scores[i]}', end: true, bold: true),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: g.rematch, child: const Text('Rematch')),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('New players'),
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, String s,
      {bool header = false, bool end = false, bool bold = false}) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        s,
        textAlign: end ? TextAlign.right : TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: header
            ? labelStyle(context)
            : TextStyle(
                fontSize: 16,
                color: p.ink,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

TextStyle labelStyle(BuildContext context) => TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: Pal.of(context).muted,
    );

class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Text.rich(
      TextSpan(children: [
        const TextSpan(text: 'Human '),
        TextSpan(text: 'or', style: TextStyle(color: p.accent)),
        const TextSpan(text: ' AI?'),
      ]),
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: p.ink,
      ),
    );
  }
}

class ScoreChip extends StatelessWidget {
  const ScoreChip({super.key, required this.game});
  final Game game;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    String short(String s) => s.length > 6 ? '${s.substring(0, 6)}.' : s;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Text(
        '${short(game.names[0])} ${game.scores[0]}  ·  ${short(game.names[1])} ${game.scores[1]}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.ink,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class PromptCard extends StatelessWidget {
  const PromptCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: p.bg,
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

enum Stamp { human, bot }

class AnswerTile extends StatelessWidget {
  const AnswerTile({
    super.key,
    required this.letter,
    required this.text,
    this.selected = false,
    this.onTap,
    this.stamp,
  });

  final String letter, text;
  final bool selected;
  final VoidCallback? onTap;
  final Stamp? stamp;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final borderColor = selected ? p.accent : p.line;
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: selected ? 2.5 : 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  14, 16, 16, stamp == null ? 16 : 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: selected ? p.accent : p.ink,
                    child: Text(letter,
                        style: TextStyle(
                            color: selected ? p.onAccent : p.bg,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text,
                        style: TextStyle(
                            fontSize: 18, height: 1.35, color: p.ink)),
                  ),
                ],
              ),
            ),
            if (stamp != null)
              Positioned(
                right: 12,
                bottom: 10,
                child: StampMark(stamp: stamp!),
              ),
          ],
        ),
      ),
    );
  }
}

class StampMark extends StatelessWidget {
  const StampMark({super.key, required this.stamp});
  final Stamp stamp;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final color = stamp == Stamp.human ? p.human : p.bot;
    final label = stamp == Stamp.human ? 'HUMAN' : 'BOT';
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final mark = Transform.rotate(
      angle: -0.14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5)),
      ),
    );
    if (reduceMotion) return mark;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 2.2, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Opacity(
        opacity: ((2.2 - scale) / 1.2).clamp(0.0, 1.0),
        child: Transform.scale(scale: scale, child: child),
      ),
      child: mark,
    );
  }
}

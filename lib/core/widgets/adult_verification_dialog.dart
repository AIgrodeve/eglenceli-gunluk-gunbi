import 'package:flutter/material.dart';

Future<bool> showAdultVerificationDialog({
  required BuildContext context,
  required String title,
  required String question,
  required String expectedAnswer,
  required String wrongAnswerMessage,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _AdultVerificationDialog(
      title: title,
      question: question,
      expectedAnswer: expectedAnswer,
      wrongAnswerMessage: wrongAnswerMessage,
    ),
  );

  return result ?? false;
}

class _AdultVerificationDialog extends StatefulWidget {
  const _AdultVerificationDialog({
    required this.title,
    required this.question,
    required this.expectedAnswer,
    required this.wrongAnswerMessage,
  });

  final String title;
  final String question;
  final String expectedAnswer;
  final String wrongAnswerMessage;

  @override
  State<_AdultVerificationDialog> createState() =>
      _AdultVerificationDialogState();
}

class _AdultVerificationDialogState extends State<_AdultVerificationDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    // Bu geçici kontrol gerçek PIN veya güçlü ebeveyn doğrulamasının yerine
    // geçmez. İleride daha güçlü bir doğrulama eklenebilir.
    if (_controller.text.trim() == widget.expectedAnswer) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _errorText = widget.wrongAnswerMessage);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.question, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Cevap',
                errorText: _errorText,
              ),
              onSubmitted: (_) => _verify(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(onPressed: _verify, child: const Text('Devam et')),
      ],
    );
  }
}

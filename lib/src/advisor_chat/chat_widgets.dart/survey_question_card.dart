import 'package:flutter/material.dart';

enum SurveyResponses { yes, almost, no }

class SurveyQuestionCard extends StatefulWidget {
  final String messageContent;
  final Function(String) handleResponseCallback;

  const SurveyQuestionCard({
    Key? key,
    required this.messageContent,
    required this.handleResponseCallback,
  }) : super(key: key);

  @override
  _SurveyQuestionCardState createState() => _SurveyQuestionCardState();
}

class _SurveyQuestionCardState extends State<SurveyQuestionCard> {
  String? _selectedResponse;
  bool _isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.messageContent,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: SurveyResponses.values
                  .map((response) => _buildOptionButton(
                      context, response.name, response == _selectedResponse))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      BuildContext context, String text, bool isSelected) {
    return OutlinedButton(
      onPressed: _isButtonDisabled ? null : () => _handleButtonPress(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black,
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        side: BorderSide(color: Colors.grey.shade300, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _handleButtonPress(String text) {
    setState(() {
      _selectedResponse = text;
      _isButtonDisabled = true;
    });
    widget.handleResponseCallback(text);
  }
}

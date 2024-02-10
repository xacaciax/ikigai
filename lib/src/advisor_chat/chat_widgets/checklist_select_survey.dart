import 'package:flutter/material.dart';
import 'package:ikigai_advisor/src/advisor_chat/advisory_prompts.dart';
import '../../models/chat_interest_area.dart';

class ChecklistSelectSurvey extends StatefulWidget {
  final List<InterestArea> surveyOptions;
  final Function(List<String>) onSurveyOptionsSelected;

  ChecklistSelectSurvey({
    Key? key,
    required this.surveyOptions,
    required this.onSurveyOptionsSelected,
  }) : super(key: key);

  @override
  _ChecklistSelectSurveyState createState() => _ChecklistSelectSurveyState();
}

class _ChecklistSelectSurveyState extends State<ChecklistSelectSurvey> {
  late Map<String, List<String>> _options;
  List<String> _interests = [];
  bool _hasBeenSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initializeSurveyOptions();
  }

  void _initializeSurveyOptions() {
    _options = {};
    for (var area in widget.surveyOptions) {
      _options[area.areaOfInterest] = area.subInterests;
    }
  }

  void _handleCheckboxChanged(bool? isChecked, String value) {
    if (isChecked == null) return;
    setState(() {
      if (isChecked) {
        _interests.add(value);
      } else {
        _interests.remove(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 550,
      child: Card(
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
              Flexible(
                child: ListView.builder(
                  itemCount: widget.surveyOptions.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      initiallyExpanded: index == 0,
                      title: Text(widget.surveyOptions[index].areaOfInterest),
                      children: widget.surveyOptions[index].subInterests
                          .map((child) => CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(child),
                                value: _interests.contains(child),
                                onChanged: (isChecked) =>
                                    _handleCheckboxChanged(isChecked, child),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                        TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.purple.shade600),
                    ),
                    onPressed: _hasBeenSubmitted
                        ? null
                        : () {
                            widget.onSurveyOptionsSelected(_interests);
                            // Navigator.pop(context);
                            setState(() {
                              _hasBeenSubmitted = true;
                            });
                          },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

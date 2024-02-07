import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';

class CarouselPage extends StatefulWidget {
  static const routeName = '/intro';
  @override
  _CarouselPageState createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  final PageController _pageController = PageController(initialPage: 0);

  final RichText text1 = RichText(
    text: TextSpan(
      style: const TextStyle(
        fontSize: 18.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        TextSpan(
            text: 'IKIGAI ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: 'means \n\nto do what you '),
        TextSpan(
            text: 'love\n',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
          text: 'to do ',
        ),
        TextSpan(
            text: 'what you are good at\n',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
          text: 'to do what the ',
        ),
        TextSpan(
            text: 'world needs\n',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
          text: 'and to do what you can get',
        ),
        TextSpan(
            text: ' paid ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: 'for\n\n'),
        TextSpan(
          text: '... in other words, a great',
        ),
        TextSpan(
            text: ' career!',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  final text2 = RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        TextSpan(text: 'Building a great career is a process that takes a '),
        TextSpan(
            text: 'lifetime', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
            text:
                '. \n\nSome careers have predetermined paths, like becoming an astronaut, while others are more unique! \n\nCareers are built '),
        TextSpan(
            text: 'one step at a time',
            style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
            text:
                '. \n\nIn the process we often don’t know where we will end up.\n'),
      ],
    ),
  );

  final text3 = RichText(
    text: TextSpan(
      style: const TextStyle(
        fontSize: 18.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        TextSpan(
            text: 'IKIGAI Advisor',
            style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
            text:
                ' is here to help you discover different career options based on your unique interests, passions, and capabilities.\n\n'
                'It will ask you some questions about yourself and based on the answers, suggest different career options.\n\n'
                'The goal is to explore a first next step that fits who you are.\n\n'),
      ],
    ),
  );

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navToChat() {
    Navigator.of(context).pushNamed('/chat');
  }

  Widget page(
      {required RichText text,
      required String lottiePath,
      required String buttonText,
      String? heading,
      VoidCallback? buttonCallback}) {
    // Sizes for responsive sizing if needed
    // final screenSize = MediaQuery.of(context).size;
    // final screenWidth = screenSize.width;
    // final screenHeight = screenSize.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (heading != null)
          Text(heading, style: Theme.of(context).textTheme.headlineMedium),
        if (heading != null)
          SizedBox(
            height: 30,
          ),
        Lottie.asset(
          lottiePath,
        ),
        Center(
          child: Padding(padding: EdgeInsets.all(30), child: text),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade100,
            textStyle: TextStyle(fontSize: 20, color: Colors.white),
          ),
          onPressed: buttonCallback ?? _nextPage,
          child: Text(buttonText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                page(
                  text: text1,
                  lottiePath: 'assets/lotties/boat.json',
                  buttonText: 'Next',
                  heading: 'Welcome to\nIkigai Advisor',
                ),
                page(
                  text: text2,
                  lottiePath: 'assets/lotties/boat_views.json',
                  buttonText: 'Next',
                ),
                page(
                  text: text3,
                  lottiePath: 'assets/lotties/night_boat.json',
                  buttonText: 'Start Chat',
                  buttonCallback: navToChat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselPage extends StatefulWidget {
  static const routeName = '/intro';
  @override
  _CarouselPageState createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  PageController _pageController = PageController(initialPage: 0);

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
        TextSpan(text: 'means \nto do what you '),
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
                '. Some careers have predetermined paths, like becoming an astronaut, while others are more unique! \n\nCareers are built '),
        TextSpan(
            text: 'one step at a time',
            style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
            text:
                '. In the process we often don’t know where we will end up.\n'),
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
                ' helps you discover different career options based on your unique interests, passions, and capabilities.\n\n'
                'It will ask you some questions about yourself and based on the answers suggest different career options.\n\n'
                'The goal is to explore a first next step that fits who you are.\n\n'),
      ],
    ),
  );

  final introHeading = RichText(
    text: TextSpan(
      style: const TextStyle(
        fontSize: 24.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        TextSpan(
          text: 'Welcome to\n',
        ),
        TextSpan(
            text: 'IKIGAI Advisor',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
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
      String? buttonText,
      RichText? heading,
      VoidCallback? buttonCallback}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (heading != null)
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: heading,
          ),
        Lottie.asset(
          lottiePath,
        ),
        Flexible(
          child: Center(
            child: SingleChildScrollView(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                  ),
                  child: text,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                page(
                  text: text1,
                  lottiePath: 'assets/lotties/boat.json',
                  buttonText: 'Next',
                  heading: introHeading,
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
          SizedBox(
            height: 10,
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: 3,
            effect: ScrollingDotsEffect(
              dotColor: Colors.orange.shade600,
              activeDotColor: Colors.orange.shade800,
              dotHeight: 14,
              dotWidth: 14,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            onPressed: navToChat,
            child: Text('Start Chat'),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}

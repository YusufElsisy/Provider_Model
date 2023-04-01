import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Store')),
      body: Container(
        color: Theme.of(context).secondaryHeaderColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Loading',
                    style: TextStyle(
                        fontSize: 30, color: Theme.of(context).primaryColor)),
                AnimatedTextKit(
                    pause: const Duration(seconds: 3),
                    repeatForever: true,
                    animatedTexts: [
                      TyperAnimatedText('.....',
                          textStyle: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).primaryColor))
                    ])
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MainLogo extends StatelessWidget {
  const MainLogo({super.key});

  @override
  Widget build(BuildContext context) {
     TextStyle logoStyle = TextStyle(
      fontSize: 40.0,
      color: Theme.of(context).colorScheme.secondary,
      fontWeight: FontWeight.normal,
      height: 1,
      fontFamily: 'Comfortaa',
    );

    return  Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clean',
            style: logoStyle,
          ),
          Text(
            'City',
            style: logoStyle,
          ),
        ],
      ),
    );
  }
}

class SimpleLogo extends StatelessWidget {
  const SimpleLogo({super.key});

  @override
  Widget build(BuildContext context) {
     TextStyle logoStyle = TextStyle(
      fontSize: 22.0,
      color: Theme.of(context).colorScheme.secondary,
      fontWeight: FontWeight.normal,
      height: 1,
      fontFamily: 'Comfortaa',
    );

    return  Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CleanCity',
            style: logoStyle,
          ),
        ],
      ),
    );
  }
}

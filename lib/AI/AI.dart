import 'package:flutter/material.dart';


class SubstringHighlight extends StatelessWidget {
  final String text;
  final List<String> terms;
  final TextStyle textStyle;
  final TextStyle textStyleHighlight;

  SubstringHighlight({
    this.text = "",
    required this.terms,
    this.textStyle = const TextStyle(
      color: Colors.black,
    ),
    this.textStyleHighlight = const TextStyle(
      color: Colors.red,
    ),
  });

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) {
      return Text(text, style: textStyle);
    } else {
      final matchingTerms =
          terms.where((term) => text.toLowerCase().contains(term)).toList();
      if (matchingTerms.isEmpty) return Text(text, style: textStyle);
      final termMatch = matchingTerms.first;
      final termLC = termMatch.toLowerCase();

      final List<InlineSpan> children = [];

      final List<String> spanList = text.toLowerCase().split(termLC);
      int i = 0;
      spanList.forEach((v) {
        if (v.isNotEmpty) {
          children.add(TextSpan(
              text: text.substring(i, i + v.length), style: textStyle));
          i += v.length;
        }
        if (i < text.length) {
          children.add(TextSpan(
              text: text.substring(i, i + termMatch.length),
              style: textStyleHighlight));
          i += termMatch.length;
        }
      });
      return RichText(text: TextSpan(children: children));
    }
  }
}

// class PersistentWidget extends StatefulWidget {
//   @override
//   PersistentState createState() => PersistentState();
// }

// class PersistentState extends State<PersistentWidget> {
//   String text = '';
//   bool isListening = false;

//   @override
//   Widget build(BuildContext context) => Builder(
//   builder: (context)=>
//   Row(mainAxisAlignment: MainAxisAlignment.start,
//     children: [
//     AvatarGlow(
//     animate: isListening,
//     endRadius: 35,
//     glowColor: Color.fromARGB(255, 255, 17, 1),
//     child: FloatingActionButton(
//     backgroundColor: isListening ? Colors.greenAccent : Colors.blue,
//     child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 20),
//     onPressed: toggleRecording,
//     ),
//     ),  
//     Container(
//     width: 100,
//     height: 300,
//     child: SingleChildScrollView(
//     reverse: true,  
//     child:
//     SubstringHighlight(
//     text: text,
//     terms: Command.all,
//     textStyle: TextStyle(fontSize: 10.0, color: Theme.of(context).hintColor, fontFamily: 'BrandonLI'),
//     textStyleHighlight: TextStyle( fontSize: 10.0, color: Colors.red, fontFamily: 'BrandonBI'),
//     ))),
//     ],));
  

//    Future toggleRecording() => SpeechApi().toggleRecording(
//         onResult: (text) => setState(() {
//           this.text = text;
//           Future.delayed(Duration(milliseconds: 1), () {
//             Utils().scanText(text, context);
//           });
//         }),
//         onListening: (isListening) {
//           setState(() => this.isListening = isListening);
//          // print("####################################" + isListening.toString());
//           // if (!isListening) {
//           //   Future.delayed(Duration(seconds: 5), () {
//           //     Utils().scanText(text, context);
//           //   });
//           // }
//         },
//       );
  
// }


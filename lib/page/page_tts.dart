import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/app_bar.dart';

class TextToSpeech extends StatefulWidget {
  const TextToSpeech({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TextToSpeech();
  }
}

class _TextToSpeech extends State<TextToSpeech> {
  List<String> itemList = List.empty(growable: true);
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
        title: 'TTS 여기서 해라',
        center: true,
      ),
      body: const Center(child: Text('대충만들어놨다 알아서 바꿔 풀푸쉬 잘하고')),
    );
  }
}

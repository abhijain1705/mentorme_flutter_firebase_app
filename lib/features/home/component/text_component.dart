import 'dart:io';

import 'package:flutter/material.dart';

class TextComponent extends StatefulWidget {
  final TextEditingController caption;
  final File? image;
  final TextEditingController describe;
  const TextComponent(
      {Key? key,
      required this.image,
      required this.describe,
      required this.caption})
      : super(key: key);

  @override
  State<TextComponent> createState() => _TextComponentState();
}

class _TextComponentState extends State<TextComponent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: widget.caption,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: "What do you want to talk about...",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: widget.describe,
              maxLength: 2000,
              maxLines: 20,
              decoration: InputDecoration(
                hintText: "Write here...",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: widget.image == null
                ? Text("")
                : Image.file(widget.image!.absolute),
          )
        ],
      ),
    );
  }
}

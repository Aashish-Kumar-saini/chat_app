import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.pickedImage});

  final void Function(File imagePath) pickedImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async{
    var pickedImage = await ImagePicker().pickImage(source: .camera, maxWidth: 150, imageQuality: 70);

    if(pickedImage == null)return;
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.pickedImage(_pickedImageFile!);

  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImageFile == null ? null : FileImage(_pickedImageFile!),
        ),
        TextButton.icon(onPressed: _pickImage, icon: Icon(Icons.image), label: Text('Add Image'),)
      ],
    );
  }
}
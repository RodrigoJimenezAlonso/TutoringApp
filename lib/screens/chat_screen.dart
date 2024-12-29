import 'package:flutter/material.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proyecto_rr_principal/mysql.dart';

Future<void> _uploadMediaToServer(String groupId, File file, String mediaType) async{
  try{
    final directory = await getApplicationDocumentsDirectory();
    final uploadPath = join(directory.path, 'uploads', groupId);
    final uploadDir = Directory(uploadPath);
    if(!uploadDir.existsSync()){
      uploadDir.createSync(recursive: true);
    }
    final fileName = basename(file.path);
    final savedFile = File(join(uploadPath, fileName));
    await file.copy(savedFile.path);

    final conn = await MySQLHelper.connect();
    await conn.query(
      'INSERT INTO messages(id, sender_id, media_url, timestamp, type, group_id) VALUES(?,?,?,?,?)',
      [
        UniqueKey().toString(),
        'sender_id_placeholder',
        savedFile.path,
        DateTime.now().toIso8601String(),
        mediaType,
        groupId,
      ]
    );
  }catch(e){
    throw Exception('Error saving the file $e');
  }
}



Future<void> _selectMediaToUpload(String groupId, BuildContext context) async {
  try {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await _uploadMediaToServer(groupId, file, 'image');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload media: $e')),
    );
  }
}

Future<void> _selectDocumentToUpload(String groupId, BuildContext context) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      final file = File(result.files.single.path!);
      await _uploadMediaToServer(groupId, file, 'document');
    }
  }catch(e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload Document: $e'))
    );
  }
}
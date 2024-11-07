import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> _selectMediaToUpload(String groupId, BuildContext context) async {
  try {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final filePath = 'public/$groupId/${file.uri.pathSegments.last}';
      await Supabase.instance.client.storage
          .from('chat_media')
          .upload(filePath, file);
      final downloadUrlResponse = Supabase.instance.client.storage
          .from('chat_media')
          .getPublicUrl(filePath);
      final downloadUrl = downloadUrlResponse;

      if (downloadUrl.isEmpty) {
        throw Exception('Failed to retrieve download URL');
      }
      await Supabase.instance.client.from('messages').insert({
        'sender_id': Supabase.instance.client.auth.currentUser!.id,
        'media_url': downloadUrl,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'image',
        'group_id': groupId,
      });
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
      File file = File(result.files.single.path!);
      final filePath = 'public/$groupId/${file.uri.pathSegments.last}';
      await Supabase.instance.client.storage
          .from('chat_files')
          .upload(filePath, file);
      final downloadUrl = Supabase.instance.client.storage
          .from('chat_files')
          .getPublicUrl(filePath);

      if (downloadUrl.isEmpty) {
        throw Exception('Failed to retrieve download URL');
      }

      await Supabase.instance.client.from('messages').insert({
        'sender_id': Supabase.instance.client.auth.currentUser!.id,
        'media_url': downloadUrl,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'document',
        'group_id': groupId,
      });
    }
  }catch(e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload Document: $e'))
    );
  }
}
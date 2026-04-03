import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Upload a list of local files to Firebase Storage and return their download URLs
  Future<List<String>> uploadPhotos(String coupleId, List<String> localPaths) async {
    List<String> downloadUrls = [];

    for (String localPath in localPaths) {
      // If it's already a network URL, just add it back
      if (localPath.startsWith('http')) {
        downloadUrls.add(localPath);
        continue;
      }

      File file = File(localPath);
      if (!await file.exists()) continue;

      try {
        String fileName = '${_uuid.v4()}${path.extension(localPath)}';
        String storagePath = 'couples/$coupleId/diary/$fileName';

        TaskSnapshot snapshot = await _storage.ref(storagePath).putFile(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Upload photo error: $e');
        // If upload fails, just keep the local path for offline use
        downloadUrls.add(localPath);
      }
    }

    return downloadUrls;
  }

  /// Delete photos from Firebase Storage
  Future<void> deletePhotos(List<String> imageUrls) async {
    for (String url in imageUrls) {
      if (!url.startsWith('http')) continue;
      
      try {
        await _storage.refFromURL(url).delete();
      } catch (e) {
        print('Delete photo error: $e');
      }
    }
  }
}

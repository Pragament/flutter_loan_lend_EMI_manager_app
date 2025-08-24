import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static const _scopes = [drive.DriveApi.driveFileScope];

  static Future<void> uploadBackupFile(String filename, String content) async {
  
  final jsonString = await rootBundle.loadString('assets/client_secret.json');
  final jsonMap = json.decode(jsonString);

  final clientId = ClientId(
    jsonMap['installed']['client_id'],
    jsonMap['installed']['client_secret'],
  );

  await clientViaUserConsent(clientId, _scopes, (url) {
    print(' Please open this URL in your browser:\n$url');
  }).then((AuthClient client) async {
    print(' Auth successful, uploading to Google Drive...');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);

    final driveApi = drive.DriveApi(client);
    final driveFile = drive.File()..name = filename;

    await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
    );

    print(' Upload complete!');
  }).catchError((e) {
    print(' Upload failed: $e');
  });
}
}

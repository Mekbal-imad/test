import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class ApkInstaller {
  final Dio _dio = Dio();

  Future<void> downloadAndInstall({
    required String apkUrl,
    required Function(double progress) onProgress,
    required Function(String error) onError,
    required Function() onSuccess,
  }) async {
    try {
      // 1. Demander la permission
      await _requestPermissions();

      // 2. Chemin de sauvegarde
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/app_update.apk';

      // 3. Télécharger l'APK
      await _dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      // 4. Lancer l'installer
      final result = await OpenFile.open(savePath);

      if (result.type == ResultType.done) {
        onSuccess();
      } else {
        onError('Erreur installer : ${result.message}');
      }
    } on DioException catch (e) {
      onError('Échec téléchargement : ${e.message}');
    } catch (e) {
      onError('Erreur : $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.requestInstallPackages.request();
      if (status.isDenied) {
        throw Exception('Permission refusée');
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'apk_installer.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  double _progress = 0;
  bool _isDownloading = false;
  String _status = '';

  final String apkUrl =
      'https://github.com/7aji676/ProjectS4/releases/download/v1.0.1/app-release.apk';

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _status = 'Téléchargement en cours...';
      _progress = 0;
    });

    await ApkInstaller().downloadAndInstall(
      apkUrl: apkUrl,
      onProgress: (progress) {
        setState(() {
          _progress = progress;
          _status = '${(progress * 100).toStringAsFixed(0)}%';
        });
      },
      onError: (error) {
        setState(() {
          _isDownloading = false;
          _status = '❌ $error';
        });
      },
      onSuccess: () {
        setState(() {
          _isDownloading = false;
          _status = '✅ Prêt à installer !';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mise à jour')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Nouvelle version disponible !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              if (_isDownloading) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 16),
                Text(_status, style: const TextStyle(fontSize: 18)),
              ] else ...[
                if (_status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_status, style: const TextStyle(fontSize: 16)),
                  ),
                ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger et installer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

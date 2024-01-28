import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    super.reassemble();
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Donjul QR Scanner'),
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                await pref.remove('isAdmin');
                await pref.remove('auth_token');
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: ((QRViewController controller) {
              setState(() => this.controller = controller);
              controller.scannedDataStream.listen((scanData) async {
                if (Platform.isAndroid) {
                  controller.pauseCamera();
                }
                await Navigator.pushNamed(context, '/result', arguments: {
                  'result': scanData,
                });
                if (Platform.isAndroid) {
                  controller.resumeCamera();
                }
              });
            }),
            overlay: QrScannerOverlayShape(
              borderColor: Theme.of(context).colorScheme.primary,
              borderRadius: 10,
              borderWidth: 15,
              borderLength: 30,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          Positioned(
              child: Container(
                color: Colors.black12,
                child: const Text('Scan the Donjul QR Code',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ),
        ],
      ),
    );
  }
}

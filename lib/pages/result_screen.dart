import 'package:flutter/material.dart';
import 'package:marriage_app/functional_classes/post_data.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Result extends StatefulWidget {
  const Result({super.key});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  Map<String, Barcode>? qrdata;
  Map<String, dynamic>? data;

  Future<void> decodeQRString(String qrString) async {
    PostData qrToken = PostData(username: '', password: '');
    var res = await qrToken.sendQRToken(qrString);
    if (res['status'] != 200) return;
    data = res['qrdata'];
  }

  @override
  Widget build(BuildContext context) {
    qrdata = ModalRoute.of(context)!.settings.arguments as Map<String, Barcode>?;
    decodeQRString(qrdata!['result']!.code!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: data == null
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Name: '),
                              Text(data?['actual_name'] ?? '???'),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Table Number: '),
                              Text(data?['table_number'] ?? '???'),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Telephone Number: '),
                              Text(data?['telephone'] ?? '???'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(flex: 1,child: Row(
                      children: [
                        ElevatedButton(onPressed: data?['telephone'] ? () {} : null, child: const Text('Mark as Present')),
                      ],
                    )),
                  ],
      ),
    );
  }
}

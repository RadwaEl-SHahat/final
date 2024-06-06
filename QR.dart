import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QR extends StatefulWidget {
  @override
  _QRState createState() => _QRState();
}

class _QRState extends State<QR> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
        elevation: 2,
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              result != null ? 'Result: ${result!.code}' : 'Scanning...',
              style: TextStyle(fontSize: 20,color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        // Call your security check function here
        checkSecurity(result?.code ?? '');
      });
    });
  }

  void checkSecurity(String scannedContent) {
    // Extract the URL from the scanned content
    Uri? url = Uri.tryParse(scannedContent);
    if (url == null) {
      // If the scanned content is not a valid URL
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Scan Result'),
          content: Text('Scanned content is not a valid URL: $scannedContent'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Check if the URL is safe
      bool isSafe = isURLSafe(url);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Scan Result'),
          content: Text('Scanned content: $scannedContent\n\nIs safe: $isSafe\nURL: $url'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool isURLSafe(Uri url) {
    // Implement your security check logic here
    // For demonstration, let's just check if the URL starts with 'https'
    return url.scheme == 'https';
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
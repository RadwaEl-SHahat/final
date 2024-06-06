import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
//import 'package:url_launcher/url_launcher.dart';

// Define your VirusTotal API key
const String apiKey =
    '7fb7b44531e46d8030a77e7ef7bebbb9e2a0205ebfa5a363053c9eeada818a69';

Future<void> _uploadFile() async {
  // Open file picker
  final result = await FilePicker.platform.pickFiles();

  if (result != null) {
    // Get the selected file
    final file = result.files.first;

    // Perform file scan using VirusTotal API
    final apiUrl = 'https://www.virustotal.com/vtapi/v2/file/scan';
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..fields['apikey'] = apiKey
      ..files.add(http.MultipartFile.fromBytes('file', file.bytes!,
          filename: file.name));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(responseBody);
      print('Scan Result: ${data['verbose_msg']}');
    } else {
      print('Failed to scan file. Please try again.');
    }
  }
}

Future<void> _submitURL(BuildContext context) async {
  // Prompt user to enter URL
  final url = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Submit URL'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Enter URL'),
          onChanged: (value) => Navigator.of(context).pop(value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );

  // Handle the submitted URL (you can print it for now)
  if (url != null && url.isNotEmpty) {
    // Perform URL scan using VirusTotal API
    final apiUrl = 'https://www.virustotal.com/vtapi/v2/url/scan';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'apikey': apiKey, 'url': url},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('Scan Result: ${data['verbose_msg']}');
    } else {
      print('Failed to submit URL. Please try again.');
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEEPO APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: URL(),
    );
  }
}

class URL extends StatefulWidget {
  const URL({Key? key}) : super(key: key);

  @override
  State<URL> createState() => _URLState();
}

class _URLState extends State<URL> {
  TextEditingController _urlController = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Scan URL',
          style: GoogleFonts.robotoCondensed(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Image.asset('assets/logo.png', height: 60, width: 60),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 130.0, right: 30, left: 30),
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/url1.png',
                  height: 230,
                ),
                SizedBox(height: 20),
                Text(
                  'Enter the URL',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.http),
                    hintText: 'Enter URL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _checkURL(_urlController.text);
                  },
                  child: Text('Check URL'),
                ),
                SizedBox(height: 20),
                Text(
                  _status,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkURL(String url) async {
    final apiUrl = 'https://www.virustotal.com/vtapi/v2/url/report';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'apikey': apiKey, 'resource': url},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      int? positives = data['positives'];
      if (positives != null && positives > 0) {
        setState(() {
          _status = 'URL is suspicious: $url';
        });
      } else {
        setState(() {
          _status = 'URL is safe: $url';
        });
      }
    } else {
      setState(() {
        _status = 'Failed to check URL. Please try again.';
      });
    }
  }
}

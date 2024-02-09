import 'dart:html';

import 'package: firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
void main() async {
  WidgetsFlutterBinding. ensureInitialized(); await Firebase.initializeApp();
  runApp (const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
// MaterialApp
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  }
  class _HomeScreenState extends State<HomeScreen> {
    final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> pdfData = [];

    Future<String> uploadPdf(String fileName, File file) async {
      final refrence = FirebaseStorage.instance.ref().child(
          "pdfs/$fileName.pdf");
      final uploadTask = refrence.putFile(file);
      await uploadTask.whenComplete(() {});
      final downloadLink = await refrence.getDownloadURL();
      return downloadLink;
    }

    void pickfile() async {
      final pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (pickedFile != null) {
        String fileName = pickedFile.files[0].name;
        File file = File(pickedFile.files[0].path!);
        final downloadLink = await uploadPdf(fileName, file);

        await _firebaseFirestore.collection("pdfs").add({

          "name": fileName,
          "url": downloadLink,
        });
        print("Pdf uploaded Sucessfully");
      }
    }
    void getAllpdf() async {
    final results = await _firebaseFirestore.collection("pdfs").get();
    pdfData = results.docs.map((e) => e.data()).tolist();
      setState((){});
  }
    @override
    void initState() {
// TODO: implement initState,
      super.initState();
      getAllPdf();
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Pdfs"),
          ), // AppBar
          body: GridView.builder(
            itemCount: pdfData.length,
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              PdfViewerScreen(pdfUrl: pdfData[index]['url'])),);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ), // BoxDecoration
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          "assets/pdf.png",
                          height: 120,
                          width: 100,
                        ),
                        Text(
                          pdfData[index]['name'],
                          style: TextStyle(
                            fontSize: 18,
                          ), // TextStyle
                        ), // Text
                      ],
                    ), // Column
                  ), // Container
                ), // InkWell
              ); // Padding
            },
          ), // GridView.builder
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.upload_file),
              onPressed: pickFile,
      ),
      );
    }
  }
class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

  class _PdfViewerScreenState extends State<PdfViewerScreen> {
    PDFDocument? document;

    void initialisePdf() async {
      document = await PDFDocument.fromURL(widget.pdfUrl);
      setState(() {});
    }
    @override
    void initState() {
// TODO: impLement initState
    super.initState();
    initialisePdf();
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: document != null
            ? PDFViewer(
                 document: document!,
        )
        : Center(
          child: CircularProgressIndicator(),
        ),// PDFViewer
      ); // Scaffold
    }
  }
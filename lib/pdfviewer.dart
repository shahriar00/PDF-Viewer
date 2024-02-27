

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PdfViewerScreen extends StatefulWidget {

  final String pdfurl;
  const PdfViewerScreen({super.key,required this.pdfurl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {

   PDFDocument? pdfDocument;

  void initiasePDF() async{ 
    pdfDocument = await PDFDocument.fromURL(widget.pdfurl);

    setState(() {
      
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiasePDF();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body:pdfDocument != null ? PDFViewer(document: pdfDocument!):
      Center(child: CircularProgressIndicator(),)
    );
  }
}
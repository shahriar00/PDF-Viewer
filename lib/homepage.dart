import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdfviewer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String,dynamic>> pdfData = [];

  // Future<String?>UploadFile(String filename , File file)async{
 
  //   final reference = FirebaseStorage.instance.ref().child("pdfs/$filename.pdf") ;
  //   final uploadTrack = reference.putFile(file);
  //   await uploadTrack.whenComplete((){});
  //   final downloadLink = await reference.getDownloadURL();
  //   return downloadLink;
  // }

Future<String?> UploadFile(String filename, File file) async {
  final reference = FirebaseStorage.instance.ref().child("pdfs/$filename.pdf");
  final uploadTask = reference.putFile(file);
  final snapshot = await uploadTask.whenComplete(() {});

  // Get the download URL
  final downloadLink = await reference.getDownloadURL();

  // Get the timestamp when the file was uploaded
  final currentTime = Timestamp.now();

  // Upload the download URL and upload time to Firestore
  await firebaseFirestore.collection("pdfs").add({
    "name": filename,
    "url": downloadLink,
    "uploadTime": currentTime,
  });

  print("PDF uploaded successfully");

  return downloadLink;
}


  void pickFile()async{ 
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if(pickedFile!= null){ 
      String filename = pickedFile.files[0].name;
      File file = File(pickedFile.files[0].path!);
     final downloadLink = await UploadFile(filename, file);

     await firebaseFirestore.collection("pdfs").add({ 
      "name":filename,
      "url":downloadLink,

     });

     print("PDF uploaded successfully");
    }

  }


  void getAllPDF() async{ 
    final results = await firebaseFirestore.collection("pdfs").get();

    pdfData = results.docs.map((e) => e.data()).toList();

    setState(() {
      
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllPDF();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: Text("PDF"),
        centerTitle: true,
      ),
        body: GridView.builder(
            itemCount: pdfData.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) {
              final uploadTime = pdfData[index]['uploadTime'] as Timestamp;
        final formattedUploadTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(uploadTime.toDate());
              return Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                  onTap: (){ 
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PdfViewerScreen(pdfurl: pdfData[index]['url'],)));
                  },
                  child: Container(
                    decoration: BoxDecoration( 
                      border: Border.all()
                    ),
                    child: Column( 
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [ 
                        Image.asset("images/pdf.png",height: 120,width: 100,),
                        Text(pdfData[index]['name'],style: TextStyle(  
                          fontSize: 20
                        ),),

                        Text('Upload Time: $formattedUploadTime'), // Display upload time

                      ],
                    ),
                  ),
                ),
              );
            }),

            floatingActionButton: FloatingActionButton(onPressed: pickFile,child: Icon(Icons.upload_file),),
            
            
            );

          
  }
  
}

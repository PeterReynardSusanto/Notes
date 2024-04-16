import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final TextEditingController _titlecontroller = TextEditingController();
  final TextEditingController _descriptioncontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: const NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                // Content merupakan isi utama dari dialog
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add'),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Title:',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _titlecontroller,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Description:',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _descriptioncontroller,
                    ),
                  ],
                ),
                // Action berisi kumpulan button
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel')),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Map<String, dynamic> newNote = {};
                        // ini adalah alternatif dari yang di atas
                        // Map<String, dynamic> newNote =
                        //     new Map<String, dynamic>();
                        newNote['title'] = _titlecontroller.text;
                        newNote['description'] = _descriptioncontroller.text;

                        FirebaseFirestore.instance
                            .collection('notes')
                            .add(newNote)
                            .whenComplete(() {
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Text('Save')),
                ],
              );
            },
          );
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('note').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Errorr : ${snapshot.error}');
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: snapshot.data.docs.map((document) {
            return Card(
              child: ListTile(
                title: Text(document['title']),
                subtitle: Text(document['description']),
                trailing: InkWell(
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection('notes')
                        .doc(document.id)
                        .delete()
                        .catchError((e) {
                      print(e);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: const Icon(Icons.delete),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
//
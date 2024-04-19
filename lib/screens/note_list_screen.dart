import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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
                      controller: _titleController,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Description:',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
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
                        newNote['title'] = _titleController.text;
                        newNote['description'] = _descriptionController.text;

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
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('note').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Errorr : ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: snapshot.data!.docs.map((document) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController titleController =
                              TextEditingController(text: document['title']);
                          TextEditingController descriptionController =
                              TextEditingController(
                                  text: document['description']);
                          return AlertDialog(
                            // Content merupakan isi utama dari dialog
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Title:',
                                  textAlign: TextAlign.start,
                                ),
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    hintText: document['title'],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Description:',
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                TextField(
                                  controller: descriptionController,
                                ),
                              ],
                            ),
                            // Action berisi kumpulan button
                            actions: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel')),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Map<String, dynamic> updateNote = {};
                                    // ini adalah alternatif dari yang di atas
                                    // Map<String, dynamic> newNote =
                                    //     new Map<String, dynamic>();
                                    updateNote['title'] = titleController.text;
                                    updateNote['description'] =
                                        descriptionController.text;

                                    FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(document.id)
                                        .update(updateNote)
                                        .whenComplete(() {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: const Text('Update')),
                            ],
                          );
                        },
                      );
                    },
                    title: Text(document['title']),
                    subtitle: Text(document['description']),
                    trailing: InkWell(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection('notes')
                            .doc(document.id)
                            .delete();
                      },
                      child: const Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Icon(Icons.delete),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }
}

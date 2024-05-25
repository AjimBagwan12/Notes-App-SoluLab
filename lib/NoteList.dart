import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NoteDetail.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<Map<String, String>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.notes, color: Colors.white),
          onPressed: () {},
        ),
        elevation: 0, // Removes the shadow
        title: Text('Notes', style: TextStyle(color: Colors.white)), // Title color
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 1.0,
                color: Colors.black, // Black line below the AppBar
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4, // Add shadow to the card
                      margin: EdgeInsets.all(8), // Add margin for spacing between cards
                      child: ListTile(
                        title: Text(_notes[index]['title'] ?? ''),
                        subtitle: Text(_notes[index]['description'] ?? ''),
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetail(note: _notes[index], index: index)));
                          if (result != null) {
                            setState(() {
                              _notes[index] = {'title': result['title'], 'description': result['description']};
                            });
                            _saveNotes();
                          }
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 530.0,
            right: 16.0,
            child: Container(
              height: 70.0, // Set the height of the floating button
              width: 70.0, // Set the width of the floating button to make it square
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetail()));
                  if (result != null) {
                    setState(() {
                      _notes.add({'title': result['title'], 'description': result['description']});
                    });
                    _saveNotes();
                  }
                },
                child: Icon(Icons.add, size: 30), // Adjust icon size
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesStringList = prefs.getStringList('notes');
    if (notesStringList != null) {
      setState(() {
        _notes = notesStringList.map((noteString) => Map<String, String>.from(json.decode(noteString))).toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesStringList = _notes.map((note) => json.encode(note)).toList();
    await prefs.setStringList('notes', notesStringList);
  }

  Future<void> _showDeleteConfirmationDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this note?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  _notes.removeAt(index);
                });
                _saveNotes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}

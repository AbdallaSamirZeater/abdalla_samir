import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/message_bubbel.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (ctx, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              final doc = chatSnapshot.data.docs;

              return ListView.builder(
                reverse: true,
                itemCount: doc.length,
                itemBuilder: (ctx, index) => MessageBubbel(
                  doc[index].get('text'),
                  doc[index].get('username'),
                  doc[index].get('userImage'),
                  doc[index].get('userId') == FirebaseAuth.instance.currentUser.uid,
                  key: ValueKey(doc[index].documentID),
                ),
              );
            },
          );

  }
}

import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (cntx, chatSnapShot) {
        if (chatSnapShot.connectionState == .waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!chatSnapShot.hasData || chatSnapShot.data!.docs.isEmpty) {
          return Center(child: Text("No message yet!"));
        }
        if (chatSnapShot.hasError) {
          return Center(child: Text("Something went wromg..."));
        }

        final loadedMessgaes = chatSnapShot.data!.docs;

        return ListView.builder(
          itemCount: loadedMessgaes.length,
          padding: EdgeInsets.only(bottom: 30, left: 15, right: 15),
          reverse: true,
          itemBuilder: (ctx, index) {
            final currentMessage = loadedMessgaes[index].data();
            final nextMessage = index + 1 < loadedMessgaes.length
                ? loadedMessgaes[index + 1].data()
                : null;

            final currentUserId = currentMessage['userId'];
            final nextUserId = nextMessage == null
                ? null
                : nextMessage['userId'];

            final nextUserIsSame = currentUserId == nextUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: currentMessage['text'],
                isMe: authenticatedUser.uid == currentMessage['userId'],
              );
            } else {
              return MessageBubble.first(
                userImage: currentMessage['userImage'],
                username: currentMessage['userName'],
                message: currentMessage['text'],
                isMe: authenticatedUser.uid == currentMessage['userId'],
              );
            }
          },
        );
      },
    );

    //  Center(child: Text("No message yet"));
  }
}

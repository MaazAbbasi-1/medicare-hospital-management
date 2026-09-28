import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String userRole; // 'doctor' or 'patient'

  const ChatScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.userRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentUserId;
  late String _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = AuthService.currentUser?.uid ?? '';
    _currentUserName = await AuthService.getUserName();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final chatMessage = ChatMessage(
      id: const Uuid().v4(),
      senderId: _currentUserId,
      senderName: _currentUserName,
      senderRole: widget.userRole,
      recipientId: widget.recipientId,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      // Save to a conversation collection
      final conversationId = '${_currentUserId}_${widget.recipientId}'
          .replaceAll('.', '_');

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(chatMessage.id)
          .set(chatMessage.toMap());

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationId = '${_currentUserId}_${widget.recipientId}'.replaceAll(
      '.',
      '_',
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipientName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            Text(
              'Online',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('conversations')
                  .doc(conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Start a conversation!',
                      style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = ChatMessage.fromMap(
                      messages[index].data() as Map<String, dynamic>,
                    );
                    final isOwn = msg.senderId == _currentUserId;

                    return Align(
                      alignment: isOwn
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isOwn ? AppTheme.primary : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: isOwn
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.message,
                              style: GoogleFonts.poppins(
                                color: isOwn ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: isOwn
                                    ? Colors.white70
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () => _sendMessage(_messageController.text),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

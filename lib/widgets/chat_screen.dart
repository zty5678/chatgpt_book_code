import 'package:chatgpt/injection.dart';
import 'package:chatgpt/models/message.dart';
import 'package:chatgpt/states/chat_ui_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../states/messge_state.dart';

class ChatScreen extends HookConsumerWidget {
  final _textController = TextEditingController();
  ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messageProvider);
    final chatUIState = ref.watch(chatUiProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              // 聊天消息列表
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return MessageItem(message: messages[index]);
                },
                itemCount: messages.length, // 消息数量
                separatorBuilder: (context, index) => const Divider(
                  // 分割线
                  height: 16,
                ),
              ),
            ),
            // 输入框
            TextField(
              enabled: !chatUIState.requestLoading,
              controller: _textController,
              decoration: InputDecoration(
                  hintText: 'Type a message', // 显示在输入框内的提示文字
                  suffixIcon: IconButton(
                    onPressed: () {
                      // 这里处理发送事件
                      if (_textController.text.isNotEmpty) {
                        _sendMessage(ref, _textController.text);
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // 增加WidgetRef
  _sendMessage(WidgetRef ref, String content) {
    final message = Message(
      id: uuid.v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    ref.read(messageProvider.notifier).upsertMessage(message); // 添加消息
    _textController.clear();
    _requestChatGPT(ref, content);
  }

  _requestChatGPT(WidgetRef ref, String content) async {
    ref.read(chatUiProvider.notifier).setRequestLoading(true);
    try {
      final id = uuid.v4();
      await chatgpt.streamChat(
        content,
        onSuccess: (text) {
          final message = Message(
            id: id,
            content: text,
            isUser: false,
            timestamp: DateTime.now(),
          );
          ref.read(messageProvider.notifier).upsertMessage(message);
        },
      );
    } catch (err) {
      logger.e("requestChatGPT error: $err", err);
    } finally {
      ref.read(chatUiProvider.notifier).setRequestLoading(false);
    }
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: message.isUser ? Colors.blue : Colors.blueGrey,
          child: Text(
            message.isUser ? 'A' : 'GPT',
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 12, right: 48),
            child: Text(message.content),
          ),
        ),
      ],
    );
  }
}

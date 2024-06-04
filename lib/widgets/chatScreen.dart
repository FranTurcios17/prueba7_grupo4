import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:message_app/types/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  late IO.Socket socket;
  late StreamController<List<Message>> controller;
  TextEditingController textController = TextEditingController();

  late List<Message> mensajes;
@override
  void initState() {
    
    super.initState();

mensajes = [];
controller = StreamController<List<Message>>();
controller.add(mensajes);

    socket = IO.io('https://sqdd1n1w-3000.use2.devtunnels.ms/', {
        'transports' : ['websocket'],
        'autoConnect' : false
    });

    socket.connect();
    socket.on('connect',(_){
      print('sockect conectado');
    });

    socket.on('receive_message', (ms){
        print('usuario: ${ms['user']} envio: ${ms['text']}');

        mensajes.add(Message(ms['user'], ms['text']));
        controller.add(mensajes);
    });
  }

void sendMessage(String ms)
{
    socket.emit('send_message', {'user' : 'Grupo 4', 'text': ms});
}



@override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajeria'),
      ),

      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(14),
          child: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'mensaje',
              border: OutlineInputBorder()
            ),
          ),),

          ElevatedButton(onPressed: ()
          {
            if(textController.text.isNotEmpty)
            {
              sendMessage(textController.text);
              textController.clear();
            }
          }, 
          child: const Text('Enviar')),

          Expanded(
            child: StreamBuilder(
                stream: controller.stream,
                builder:(context, snapshot) {
                  if(snapshot.hasError)
                  {
                    return const Center(child: Text('ocurrio un error'),);
                  }

                  if(!snapshot.hasData || snapshot.data!.isEmpty)
                  {
                    return const Center(child: Text('bandeja de mensajes vacia'),);
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.account_circle_rounded),
                        ),
                        title: Text(snapshot.data![index].user),
                        subtitle: Text(snapshot.data![index].text),
                      );
                    },
                  );

                },
            )
            )
        ],
      ),
    );
  }
}
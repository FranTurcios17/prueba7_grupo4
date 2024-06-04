

const io = require('socket.io')(3000, {
    cors: {
      origin: '*',
    }
  });
  
  io.on('connection', socket => {
    console.log('Nuevo Usuario Conectado');

   
  
    socket.on('send_message', message => {
      console.log('Mensaje recibido:', message);
      io.emit('receive_message', {user: message.user, text: message.text});
    });
    
    socket.on('disconnect', () => {
      console.log('Usuario desconectado');
    });
  });
  
  console.log('Socket.io server running on port 3000');
import Main from './src/Main.elm';
import { registerSW } from 'virtual:pwa-register';
import * as Tone from 'tone'; // Importamos Tone.js

registerSW({ immediate: true });

const app = Main.init({
  node: document.getElementById('elm-app')
});


const socket = new WebSocket('wss://echo.websocket.org');

socket.onopen = () => {
  console.log('Conexión WebSocket establecida en JS');
};

// 3. PUERTO DE ENTRADA (JS -> Elm): Escuchar mensajes del servidor y enviarlos a Elm
socket.onmessage = (event) => {
  // Aseguramos que pasamos un String limpio a Elm
  if (typeof event.data === 'string') {
    app.ports.recibirMensaje.send(event.data);
  }
};

socket.onerror = (error) => {
  console.error('Error en WebSocket:', error);
};

// 4. PUERTO DE SALIDA (Elm -> JS): Escuchar lo que Elm quiere enviar al servidor
if (app.ports && app.ports.enviarMensaje) {
  app.ports.enviarMensaje.subscribe((mensaje) => {
    if (socket.readyState === WebSocket.OPEN) {
      socket.send(mensaje);
    } else {
      console.warn('El WebSocket no está listo para enviar:', mensaje);
    }
  });
}

// Crear un sintetizador básico y conectarlo a la salida principal (altavoces)
const synth = new Tone.Synth().toDestination();

// 2. Escuchar el puerto de salida de Elm
if (app.ports && app.ports.reproducirTono) {
  app.ports.reproducirTono.subscribe(async (nota) => {
    // Asegurar que el contexto de audio está activo (exigencia de los browsers)
    if (Tone.context.state !== 'running') {
      await Tone.start();
      console.log('Contexto de audio de Tone.js activado');
    }
    
    // Reproducir la nota recibida (ej: "C4", "E4") con una duración de un cuarto de nota ("8n")
    synth.triggerAttackRelease(nota, '8n');
  });
}
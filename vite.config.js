import { defineConfig } from 'vite';
import elm from 'vite-plugin-elm-watch'; // Importación por defecto corregida
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    elm(), // Se ejecuta la función por defecto directamente
    VitePWA({
      registerType: 'autoUpdate',
      manifest: {
        name: 'Jamófono',
        short_name: 'Jamófono',
        description: 'Aplicación rítmica funcional',
        theme_color: '#60B5CC',
        display: 'fullscreen', 
        orientation: 'portrait'
      }
    })
  ],
  server: {
    allowedHosts: [
      'jamofono.loca.lt', // Permite este dominio específico de LocalTunnel
      '.loca.lt'                  // OPCIONAL: Permite cualquier subdominio de localtunnel
    ]
  }
});
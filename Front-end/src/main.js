
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

import './assets/styles/global.css'
import './assets/styles/home.css'
import './assets/styles/login.css'
import './assets/styles/simulacao.css'
createApp(App)
  .use(router)
  .mount('#app')

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

// BC control add-in frames don't ship a pre-built HTML file, so there is no
// <div id="root"> in the document.  Create it dynamically before React mounts.
let rootElement = document.getElementById('root')
if (!rootElement) {
  rootElement = document.createElement('div')
  rootElement.id = 'root'
  rootElement.style.height = '100%'
  document.body.style.margin = '0'
  document.body.style.height = '100%'
  document.body.appendChild(rootElement)
}

createRoot(rootElement).render(
  <StrictMode>
    <App />
  </StrictMode>,
)

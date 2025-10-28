import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import ErrorBoundary from './components/ErrorBoundary.tsx'
import { ToastProvider } from './contexts/ToastContext.tsx'

createRoot(document.getElementById('root')!).render(
	<StrictMode>
		<ErrorBoundary>
			<ToastProvider>
				<App />
			</ToastProvider>
		</ErrorBoundary>
	</StrictMode>
)

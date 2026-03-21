import { useEffect } from 'react';
import { Navigation } from './components/Navigation';
import { Footer } from './components/Footer';
import { HomePage } from './components/HomePage';
import { Impressum } from './components/Impressum';
import { Datenschutz } from './components/Datenschutz';
import { ProductInfo } from './components/ProductInfo';
import  Modal from 'react-modal';
import {
  BrowserRouter as Router,
  Routes,
  Route,
  useNavigate,
  useLocation,
} from 'react-router-dom';

export default function App() {
  return (
    <Router>
      <Main />
    </Router>
  );
}


Modal.setAppElement('#root'); // Setzt das App-Element für die Modal-Komponente

function Main() {
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }, [location.pathname]);

  return (
    <div className="min-h-screen">
      <Navigation />

      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route
          path="/product/:id"
          element={<ProductInfo onBack={() => navigate('/')} />}
        />
        <Route
          path="/impressum"
          element={<Impressum onBack={() => navigate('/')} />}
        />
        <Route
          path="/datenschutz"
          element={<Datenschutz onBack={() => navigate('/')} />}
        />
      </Routes>

      <Footer
        onNavigate={(page) => {
          switch (page) {
            case 'home':
              navigate('/');
              break;
            case 'impressum':
              navigate('/impressum');
              break;
            case 'datenschutz':
              navigate('/datenschutz');
              break;
          }
        }}
      />
    </div>
  );
}

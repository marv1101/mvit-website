import { useState } from 'react';
import { Navigation } from './components/Navigation';
import { Footer } from './components/Footer';
import { HomePage } from './components/HomePage';
import { Impressum } from './components/Impressum';
import { Datenschutz } from './components/Datenschutz';
import { ProductInfo } from './components/ProductInfo';

export default function App() {
 
  const [currentPage, setCurrentPage] = useState<'home' | 'impressum' | 'datenschutz' | 'ProductInfo'>('home');

  const handleNavigate = (page: 'home' | 'impressum' | 'datenschutz' | 'ProductInfo') => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <div className="min-h-screen">
      <Navigation />
      
      {currentPage === 'home' && <HomePage onNavigate={handleNavigate} />}
      {currentPage === 'ProductInfo' && <ProductInfo onBack={() => handleNavigate('home')} />}
      {currentPage === 'impressum' && <Impressum onBack={() => handleNavigate('home')} />}
      {currentPage === 'datenschutz' && <Datenschutz onBack={() => handleNavigate('home')} />}
      
      <Footer onNavigate={handleNavigate} />
    </div>
  );
}
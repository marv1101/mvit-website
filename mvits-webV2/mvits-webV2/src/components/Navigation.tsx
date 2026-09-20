import { Code2, Menu, X, Moon, Monitor, Sun } from 'lucide-react';
import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useTheme } from '../hooks/useTheme';

export function Navigation() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const { mode, isDarkMode, setTheme } = useTheme();
  const navigate = useNavigate();
  const location = useLocation();

  const cycleThemeMode = () => {
    setTheme(mode === 'system' ? 'dark' : mode === 'dark' ? 'light' : 'system');
  };

  const scrollToSection = (id: string) => {
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
      setIsMenuOpen(false);
    }
  };

  const handleLogoClick = () => {
    if (location.pathname === '/') {
      scrollToSection('hero');
    } else {
      navigate('/');
    }
  };
  
  return (
    <nav className="fixed top-0 left-0 right-0 bg-card/80 backdrop-blur-lg border-b border-border z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center gap-2 cursor-pointer" onClick={handleLogoClick}>
            <Code2 className="w-8 h-8 text-primary" />
            <span className="text-lg">MVIT Solutions</span>
          </div>
          
          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-8">
            <button 
              onClick={() => scrollToSection('offerings')}
              className="hover:text-primary transition-colors"
            >
              Leistungen
            </button>
            <button 
              onClick={() => scrollToSection('contact')}
              className="hover:text-primary transition-colors"
            >
              Kontakt
            </button>
            <button
              onClick={cycleThemeMode}
              className="p-2 rounded-lg hover:bg-muted transition-colors"
              aria-label={mode === 'system' ? 'Schema: System' : mode === 'dark' ? 'Schema: Dunkel' : 'Schema: Hell'}
              title={mode === 'system' ? 'Schema: System' : mode === 'dark' ? 'Schema: Dunkel' : 'Schema: Hell'}
            >
              {mode === 'system' ? <Monitor className="w-5 h-5" /> : isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
            </button>
          </div>

          {/* Mobile Menu Button */}
          <div className="md:hidden flex items-center gap-2">
            <button
              onClick={cycleThemeMode}
              className="p-2 rounded-lg hover:bg-muted transition-colors"
              aria-label={mode === 'system' ? 'Schema: System' : mode === 'dark' ? 'Schema: Dunkel' : 'Schema: Hell'}
              title={mode === 'system' ? 'Schema: System' : mode === 'dark' ? 'Schema: Dunkel' : 'Schema: Hell'}
            >
              {mode === 'system' ? <Monitor className="w-5 h-5" /> : isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
            </button>
            <button 
              className="md:hidden"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
            >
              {isMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
        
        {/* Mobile Navigation */}
        {isMenuOpen && (
          <div className="md:hidden pb-4 space-y-3">
            <button 
              onClick={() => scrollToSection('offerings')}
              className="block w-full text-left py-2 hover:text-primary transition-colors"
            >
              Produkte
            </button>
            <button hidden
              onClick={() => scrollToSection('blog')}
              className="block w-full text-left py-2 hover:text-primary transition-colors"
            >
              Blog
            </button>
            <button 
              onClick={() => scrollToSection('contact')}
              className="block w-full text-left py-2 hover:text-primary transition-colors"
            >
              Kontakt
            </button>
          </div>
        )}
      </div>
    </nav>
  );
}
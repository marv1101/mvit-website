import { Code2, Mail, Github, Linkedin, Twitter } from 'lucide-react';

interface FooterProps {
  onNavigate: (page: 'home' | 'impressum' | 'datenschutz') => void;
}

export function Footer({ onNavigate }: FooterProps) {
  const currentYear = new Date().getFullYear();
  
  return (
    <footer className="bg-card border-t border-border mt-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="col-span-1 md:col-span-2">
            <div className="flex items-center gap-2 mb-4">
              <Code2 className="w-8 h-8 text-primary" />
              <span className="text-lg">MVIT Solutions</span>
            </div>
            <p className="text-muted-foreground mb-4">
              Professionelle Software-Lösungen für moderne Unternehmen. 
              Wir entwickeln maßgeschneiderte Produkte, die Ihre Arbeit effizienter machen.
            </p>
            <div className="flex items-center gap-4">
              <a href="https://github.com/marv1101" target="_blank" className="text-muted-foreground hover:text-primary transition-colors">
                <Github className="w-5 h-5" />
              </a>
            </div>
          </div>
          
          {/* Quick Links */}
          <div>
            <h4 className="mb-4">Quick Links</h4>
            <ul className="space-y-2">
              <li>
                <button 
                  onClick={() => {
                    onNavigate('home');
                    setTimeout(() => document.getElementById('offerings')?.scrollIntoView({ behavior: 'smooth' }), 100);
                  }}
                  className="text-muted-foreground hover:text-primary transition-colors"
                >
                  Produkte
                </button>
              </li>
              <li>
                <button hidden
                  onClick={() => {
                    onNavigate('home');
                    setTimeout(() => document.getElementById('blog')?.scrollIntoView({ behavior: 'smooth' }), 100);
                  }}
                  className="text-muted-foreground hover:text-primary transition-colors"
                >
                  Blog
                </button>
              </li>
              <li>
                <a href="#" className="text-muted-foreground hover:text-primary transition-colors">
                  Über uns
                </a>
              </li>
              <li>
                <button 
                  onClick={() => {
                    onNavigate('home');
                    setTimeout(() => document.getElementById('contact')?.scrollIntoView({ behavior: 'smooth' }), 100);
                  }}
                  className="text-muted-foreground hover:text-primary transition-colors"
                >
                  Kontakt
                </button>
              </li>
            </ul>
          </div>
          
          {/* Contact */}
          <div>
            <h4 className="mb-4">Kontakt</h4>
            <div className="space-y-2">
              <a 
                href="mailto:contact@mvit-solutions.de" 
                className="flex items-center gap-2 text-muted-foreground hover:text-primary transition-colors"
              >
                <Mail className="w-4 h-4" />
                <span>marvphoto@web.de</span>
              </a>
            </div>
          </div>
        </div>
        
        <div className="border-t border-border mt-8 pt-8 text-center text-muted-foreground text-sm">
          <p>&copy; {currentYear} MVIT Solutions. Alle Rechte vorbehalten.</p>
          <div className="flex items-center justify-center gap-4 mt-2">
            <button 
              onClick={() => onNavigate('impressum')}
              className="hover:text-primary transition-colors"
            >
              Impressum
            </button>
            <span>|</span>
            <button 
              onClick={() => onNavigate('datenschutz')}
              className="hover:text-primary transition-colors"
            >
              Datenschutz
            </button>
          </div>
        </div>
      </div>
    </footer>
  );
}
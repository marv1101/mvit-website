import { ArrowLeft } from 'lucide-react';

interface ProductPageProps {
  onBack: () => void;
}

export function ProductInfo({ onBack }: ProductPageProps) {
  return (
    <div className="min-h-screen pt-24 pb-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        <button
          onClick={onBack}
          className="flex items-center gap-2 text-primary hover:text-accent transition-colors mb-8"
        >
          <ArrowLeft className="w-5 h-5" />
          Zurück zur Startseite
        </button>

        <h1 className="mb-8">Produktname</h1>

        
      </div>
    </div>
  );
}

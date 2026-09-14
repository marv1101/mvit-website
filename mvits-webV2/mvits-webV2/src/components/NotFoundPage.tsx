import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Compass } from 'lucide-react';
import { useDocumentMeta } from '../hooks/useDocumentMeta';

export function NotFoundPage() {
  const navigate = useNavigate();

  useDocumentMeta({
    title: 'Seite nicht gefunden | mvit Solutions',
    description: 'Die aufgerufene Seite existiert nicht. Kehren Sie zur Startseite von mvit Solutions zurück.',
  });

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-4 gap-4 pt-20 text-center">
      <div className="w-16 h-16 rounded-full bg-secondary flex items-center justify-center">
        <Compass className="w-8 h-8 text-muted-foreground" />
      </div>
      <h1 className="text-3xl md:text-4xl font-bold text-foreground">404</h1>
      <p className="text-muted-foreground max-w-md">
        Die aufgerufene Seite konnte nicht gefunden werden. Bitte prüfen Sie die Adresse oder kehren Sie zur
        Startseite zurück.
      </p>
      <button
        onClick={() => navigate('/')}
        className="mt-2 inline-flex items-center gap-2 rounded-lg bg-primary text-primary-foreground px-4 py-2 hover:opacity-90 transition"
      >
        <ArrowLeft className="w-4 h-4" />
        Zurück zur Startseite
      </button>
    </div>
  );
}

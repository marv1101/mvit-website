import { ArrowLeft, ExternalLink } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import DOMPurify from 'dompurify';
import type { Reference } from '../types/Reference';
import api from '../lib/api';

interface ReferencePageProps {
  onBack: () => void;
}

export function ReferenceInfo({ onBack }: ReferencePageProps) {
  // read the `id` parameter from the URL
  const { id } = useParams<{ id: string }>();
  const [reference, setReference] = useState<Reference | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) {
      setError('Referenz-ID fehlt');
      setLoading(false);
      return;
    }

    setLoading(true);
    api
      .get<Reference>(`/references/${id}`)
      .then((r) => {
        setReference(r);
      })
      .catch((err) => {
        console.error('failed loading reference', err);
        setError('Referenz existiert nicht oder konnte nicht geladen werden');
      })
      .finally(() => setLoading(false));
  }, [id]);

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

        {loading && <p>Lädt...</p>}
        {error && <p className="text-red-500">{error}</p>}
        {!loading && !error && reference && (
          <>
            <div className="flex items-center gap-4 mb-8">
              {reference.logo_url ? (
                <img
                  src={reference.logo_url}
                  alt={`${reference.company} Logo`}
                  className="h-16 w-auto object-contain"
                />
              ) : (
                <div className="w-16 h-16 rounded-lg bg-gradient-to-br from-primary to-accent flex items-center justify-center">
                  <span className="text-2xl font-bold text-primary-foreground">
                    {reference.company.charAt(0)}
                  </span>
                </div>
              )}
              <div>
                <h1 className="mb-2">{reference.company}</h1>
                {reference.company_url && (
                  <a
                    href={reference.company_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-primary hover:text-accent transition-colors"
                  >
                    <ExternalLink className="w-4 h-4" />
                    Zur Website von {reference.company}
                  </a>
                )}
              </div>
            </div>

            <p className="text-muted-foreground mb-4">{reference.summary}</p>

            <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(reference.story || '') }}></div>
          </>
        )}

        {!loading && !error && !reference && <p>Keine Referenz gefunden.</p>}
      </div>
    </div>
  );
}

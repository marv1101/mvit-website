import { ExternalLink } from 'lucide-react';
import type { Reference } from '../types/Reference';
import { useNavigate } from 'react-router-dom';

interface ReferenceCardProps {
  reference: Reference;
}

export function ReferenceCard({ reference }: ReferenceCardProps) {
  const navigate = useNavigate();

  return (
    <div className="bg-card rounded-lg border border-border overflow-hidden hover:shadow-lg transition-shadow duration-300">
      <div className="bg-gradient-to-br from-primary to-accent p-8 flex items-center justify-center h-32">
        {reference.logo_url ? (
          <img
            src={reference.logo_url}
            alt={`${reference.company} Logo`}
            className="max-h-16 w-auto object-contain"
          />
        ) : (
          <span className="text-4xl font-bold text-primary-foreground">
            {reference.company.charAt(0)}
          </span>
        )}
      </div>

      <div className="p-6">
        <div className="flex items-center gap-2 mb-2">
          <h3 className="mb-0">{reference.company}</h3>
          {reference.company_url && (
            <a
              href={reference.company_url}
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary hover:text-accent transition-colors"
              aria-label={`Website von ${reference.company} öffnen`}
            >
              <ExternalLink className="w-4 h-4" />
            </a>
          )}
        </div>

        <p className="text-muted-foreground mb-4 mt-4">
          {reference.summary}
        </p>

        <button
          onClick={() => navigate(`/reference/${reference.id}`)}
          className="w-full px-6 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-accent transition-colors duration-200"
        >
          Zur User-Story
        </button>
      </div>
    </div>
  );
}

import { ArrowLeft } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { sanitizeHtml } from '../lib/sanitize';
import type { Product } from '../types/Product';
import api from '../lib/api';
import { useDocumentMeta, SITE_NAME } from '../hooks/useDocumentMeta';
import { useRouteSSRData } from '../lib/ssrData';
import { LoadingSpinner } from './ui/loading-spinner';

interface ProductPageProps {
  onBack: () => void;
}

export function ProductInfo({ onBack }: ProductPageProps) {
  // read the `id` parameter from the URL
  const { id } = useParams<{ id: string }>();
  const ssr = useRouteSSRData();
  // SSR-Daten des Servers vorab übernehmen, sonst klassischer Ladefluss
  const [product, setProduct] = useState<Product | null>(ssr?.product ?? null);
  const [loading, setLoading] = useState(id != null && !ssr?.product);
  const [error, setError] = useState<string | null>(null);

  useDocumentMeta({
    title: product ? `${product.name} | ${SITE_NAME}` : 'Produkt wird geladen | mvit Solutions',
    description:
      product?.description ??
      'Lösung von mvit Solutions: individuelle IT-Dienstleistungen und Software zu fairen Konditionen.',
  });

  useEffect(() => {
    if (!id) {
      setError('Produkt‑ID fehlt');
      setLoading(false);
      return;
    }

    setLoading(true);
    api
      .get<Product>(`/offerings/${id}`)
      .then((p) => {
        setProduct(p);
      })
      .catch((err) => {
        console.error('failed loading product', err);
        setError('Produkt existiert nicht oder konnte nicht geladen werden');
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

        {loading && <LoadingSpinner className="py-8" />}
        {error && <p className="text-red-500">{error}</p>}
        {!loading && !error && product && (
          <>
            <h1 className="mb-8">{product.name}</h1>
            <p className="text-muted-foreground mb-4">{product.description}</p>
            
            <div           dangerouslySetInnerHTML={{ __html: sanitizeHtml(product.description_page || '') }}></div>

          </>
        )}

        {!loading && !error && !product && <p>Kein Produkt gefunden.</p>}
      </div>
    </div>
  );
}

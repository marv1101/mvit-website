import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import DOMPurify from 'dompurify';
import { ArrowLeft, Calendar, Clock } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { replaceDrupalImgTagsWithSrc } from '../utils/DrupalImageTools';
import api from '../lib/api';
import type { Blogpost } from '@/types/Blogpost';

export function BlogPostPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [post, setPost] = useState<Blogpost | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) {
      setError('Kein Blogpost gefunden');
      setLoading(false);
      return;
    }

    let mounted = true;
    setLoading(true);
    setError(null);

    api.get<Blogpost>(`/blogposts/${id}`)
      .then((data) => {
        if (!mounted) return;
        setPost({
          ...data,
          content: data.content ? replaceDrupalImgTagsWithSrc(data.content) : '',
        });
      })
      .catch((err) => {
        if (!mounted) return;
        console.error('Failed to load blogpost', err);
        setError('Der Blogpost konnte nicht geladen werden.');
      })
      .finally(() => {
        if (mounted) setLoading(false);
      });

    return () => { mounted = false; };
  }, [id]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center pt-20">
        <div className="animate-pulse text-muted-foreground">Laden...</div>
      </div>
    );
  }

  if (error || !post) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center pt-20 gap-4">
        <p className="text-muted-foreground">{error ?? 'Blogpost nicht gefunden'}</p>
        <button
          onClick={() => navigate('/')}
          className="flex items-center gap-2 text-primary hover:underline"
        >
          <ArrowLeft className="w-4 h-4" />
          Zurück zur Startseite
        </button>
      </div>
    );
  }

  return (
    <article className="pt-24 pb-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-3xl mx-auto">
        <button
          onClick={() => navigate('/')}
          className="flex items-center gap-2 text-primary hover:gap-3 transition-all duration-200 mb-8"
        >
          <ArrowLeft className="w-4 h-4" />
          Zurück zur Startseite
        </button>

        <header className="mb-8">
          <h1 className="text-3xl md:text-4xl font-bold text-foreground mb-4">{post.title}</h1>
          <div className="flex items-center gap-3 text-sm text-muted-foreground">
            <span className="inline-block px-2.5 py-0.5 bg-secondary text-secondary-foreground rounded text-xs font-medium uppercase">
              {post.langcode}
            </span>
            <time dateTime={new Date(post.created * 1000).toISOString()}>
              {new Date(post.created * 1000).toLocaleDateString('de-DE', {
                weekday: 'short',
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
              })}
            </time>
          </div>
        </header>

        {post.title_image_url && (
          <div className="aspect-video rounded-lg overflow-hidden mb-8">
            <ImageWithFallback
              src={post.title_image_url}
              alt={post.title}
              className="w-full h-full object-cover"
            />
          </div>
        )}

        {post.content && (
          <div
            className="blog-content max-w-none text-muted-foreground"
            dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(post.content) }}
          />
        )}
      </div>
    </article>
  );
}

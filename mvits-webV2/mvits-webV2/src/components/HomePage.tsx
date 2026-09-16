import { useEffect, useState } from 'react';
import { ProductCard } from './ProductCard';
import type { Product } from '../types/Product';
import { BlogCard, type BlogPost } from './BlogCard';
import { ReferenceCard } from './ReferenceCard';
import { ContactForm } from './ContactForm';
import { replaceDrupalImgTagsWithSrc, getFirstImageUrlFromHtml } from '../utils/DrupalImageTools';
import { CONFIG } from '../utils/ConfigLoader';
import api from '../lib/api';
import type { Blogpost } from '@/types/Blogpost';
import type { Reference } from '@/types/Reference';
import { useDocumentMeta, useJsonLd, SITE_URL, SITE_NAME } from '../hooks/useDocumentMeta';
import { LoadingSpinner } from './ui/loading-spinner';

const useHomeDocumentMeta = () => {
  useDocumentMeta({
    title: 'mvit Solutions – IT-Dienstleistungen & individuelle Software',
    description:
      'mvit Solutions entwickelt individuelle Softwarelösungen von der KI-gestützten Dienstplanung über Cloud-Migration bis zur IT-Beratung zu fairen Preis-Leistungs-Konditionen.',
  });

  useJsonLd('jsonld-organization', {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: SITE_NAME,
    url: SITE_URL,
    logo: `${SITE_URL}/res/icons/icon-512x512.png`,
  });
};

const initialOfferings: Product[] = [
  {
    id: '2',
    name: 'PlanBar',
    description: 'Intelligente Dienstplanung für Apotheken. Optimieren Sie Ihre Schichtpläne mit KI-gestützter Automatisierung.',
    category: 'Software',
    price: '',
    features: [
      'Mitarbeiterverwaltung mit Arbeitszeiten & Pausen',
      'KI-gestützte Schichtoptimierung',
      'Mitarbeiterwunsch-Verwaltung',
      'Dashboard mit Echtzeit-Statistiken',
    ],
    icon: "CalendarDays",
  },
  {
    id: '1',
    name: 'Cloud migration',
    description: 'Die Cloud hat sich zu einem zentralen Bestandteil der modernen IT-Infrastuktur entwickelt. Wir helfen ihnen diese effektiv zu nutzen.',
    category: 'Cloud',
    price: '',
    features: [
      'Datensicherung',
      'E-Mail',
      'IT-Beratungsleistungen',
    ],
    icon: "Cloud",
  },
  {
    id: '3',
    name: 'Applikationsbetrieb',
    description: 'Ob im eigenen Gebäude oder in der Cloud, wir kümmern uns um ihre IT-Systeme.',
    category: 'Applikationsbetreuung',
    price: '',
    features: [
      'Betrieb und Wartung aus einer Hand',
      'Sicher',
      'Leistungsstark',
    ],
    icon: "Server",
  },
  {
    id: '4',
    name: 'Individuelle Schnittstellen',
    description: 'Individuell entwickelte Schnittstellen, die zu ihren Systemen passen und einen nahtlosen Betrieb ermöglichen.',
    category: 'Entwicklung',
    price: '',
    features: [
      'Leistungsfähig',
      'Individuell',
      'Passend',
    ],
    icon: "Database",
  },
  {
    id: '5',
    name: 'Individualsoftware-Entwicklung',
    description: 'Software, auf die Bedürfnisse ihres Unternehmens zugeschnitten.',
    category: 'Entwicklung',
    price: '',
    features: [
      'Individuelle',
      'Effizient',
      'Agil',
    ],
    icon: "Code",
  },
];

const initialBlogPosts: Blogpost[] = [
  {
    nid: 1,
    vid: 1,
    title: 'Die Zukunft der IT: Trends und Entwicklungen',
    summary: 'Entdecken Sie die neuesten Trends und Entwicklungen in der IT-Branche, von Künstlicher Intelligenz bis hin zu Cloud Computing.',
    created: 123456789,
    changed: 123456789,
    title_image_url: undefined,
    langcode: 'de',
    content: '',
  },
];

export function HomePage() {
  useHomeDocumentMeta();

  // null = lädt, [] = leer/Fehler (Fallback), Array = echte Daten
  const [offerings, setOfferings] = useState<Product[] | null>(null);
  const [blogposts, setBlogposts] = useState<Blogpost[] | null>(null);
  const [references, setReferences] = useState<Reference[] | null>(null);

  useEffect(() => {
    let mounted = true;
    api.get<Product[]>('/offerings/')
      .then((data) => {
        if (!mounted) return;
        setOfferings(Array.isArray(data) ? data : initialOfferings);
      })
      .catch((err) => {
         console.error('Failed to load offerings', err);
         if (mounted) setOfferings(initialOfferings);
      });
    return () => { mounted = false; };
  }, []);

  useEffect(() => {
    let mounted = true;
    api.get<Blogpost[]>('/blogposts/')
      .then((data) => {
        if (!mounted) return;
        if (Array.isArray(data)){

          const modifiedData = data.map((post) => {
            return {
              ...post,
              content: post.content ? replaceDrupalImgTagsWithSrc(post.content) : "",
              title_image_url: post.title_image_url ?? (post.content ? getFirstImageUrlFromHtml(post.content) : undefined),
            };
          });

          setBlogposts(modifiedData);
        } else {
          setBlogposts(initialBlogPosts);
        }
      })
      .catch((err) => {
         console.error('Failed to load blogposts', err);
         if (mounted) setBlogposts(initialBlogPosts);
      });
    return () => { mounted = false; };
  }, []);

  useEffect(() => {
    let mounted = true;
    api.get<Reference[]>('/references/')
      .then((data) => {
        if (!mounted) return;
        setReferences(Array.isArray(data) ? data : []);
      })
      .catch((err) => {
         console.error('Failed to load references', err);
         if (mounted) setReferences([]);
      });
    return () => { mounted = false; };
  }, []);

  return (
    <>
      {/* Hero Section */}
      <section id="hero" className="pt-32 pb-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto text-center">
          <h1 className="text-5xl md:text-6xl mb-6 pb-4 bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
            MVIT - IT in guten Händen.
          </h1>
          <p className="text-xl text-muted-foreground mb-8 max-w-3xl mx-auto">
            Moderne, skalierbare und sichere Software-Produkte für Ihr Unternehmen. 
            Entwickelt von Experten, gebaut für die Zukunft.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button 
              onClick={() => document.getElementById('offerings')?.scrollIntoView({ behavior: 'smooth' })}
              className="px-8 py-4 bg-primary text-primary-foreground rounded-lg hover:bg-accent transition-colors"
            >
              Leistungen entdecken
            </button>
            <button hidden
              onClick={() => document.getElementById('blog')?.scrollIntoView({ behavior: 'smooth' })}
              className="px-8 py-4 bg-secondary text-secondary-foreground rounded-lg hover:bg-accent/10 transition-colors"
            >
              Blog lesen
            </button>
          </div>
        </div>
      </section>
      
      {/* offerings Section */}
      <section id="offerings" className="py-20 px-4 sm:px-6 lg:px-8 bg-muted/30">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="mb-4">Unsere Leistungen</h2>
            <p className="text-muted-foreground max-w-2xl mx-auto">
              Leistungen, die ihr Unternehmen und ihre Prozesse voranbringen.
            </p>
          </div>
          
          {offerings === null ? (
            <LoadingSpinner className="py-12" />
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {offerings.map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          )}
        </div>
      </section>

      {/* References Section */}
      {(references === null || references.length > 0) && (
        <section id="references" className="py-20 px-4 sm:px-6 lg:px-8">
          <div className="max-w-7xl mx-auto">
            <div className="text-center mb-12">
              <h2 className="mb-4">Referenzen</h2>
              <p className="text-muted-foreground max-w-2xl mx-auto">
                Was unsere Kunden über die Zusammenarbeit mit uns sagen.
              </p>
            </div>

            {references === null ? (
              <LoadingSpinner className="py-12" />
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                {references.map((reference) => (
                  <ReferenceCard key={reference.id} reference={reference} />
                ))}
              </div>
            )}
          </div>
        </section>
      )}

      {/* Blog Section */}
      <section id="blog" className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="mb-4">Aktuelles aus unserem Blog</h2>
            <p className="text-muted-foreground max-w-2xl mx-auto">
              Bleiben Sie auf dem Laufenden mit Projekten im Bereich der Digitalisierung und Automatisierung von Geschäftsprozessen.
            </p>
          </div>

          {blogposts === null ? (
            <LoadingSpinner className="py-12" />
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {blogposts.map((blogpost) => (
                <BlogCard key={blogpost.nid} post={blogpost} />
              ))}
            </div>
          )}
          
          <div className="text-center mt-12">
            <button onClick={() => window.location.href=CONFIG.DRUPAL_BASE_URL} className="px-8 py-3 border-2 border-primary text-primary rounded-lg hover:bg-primary hover:text-primary-foreground transition-all">
              Alle Artikel anzeigen
            </button>
          </div>
        </div>
      </section>
      
      {/* Contact Form Section */}
      <ContactForm />
      
      {/* CTA Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-primary to-accent">
        <div className="max-w-4xl mx-auto text-center text-primary-foreground">
          <h2 className="mb-6">
            Bereit, Ihre IT effizienter zu gestalten?
          </h2>
          <p className="text-xl mb-8 opacity-90">
            Kontaktieren Sie uns noch heute und erfahren Sie, wie unsere Software-Lösungen 
            Ihr Unternehmen transformieren können.
          </p>
          <button 
            onClick={() => document.getElementById('contact')?.scrollIntoView({ behavior: 'smooth' })}
            className="px-8 py-4 bg-card text-foreground rounded-lg hover:shadow-xl transition-all"
          >
            Jetzt Kontakt aufnehmen
          </button>
        </div>
      </section>
    </>
  );
}

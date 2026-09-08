import { Calendar, Clock, ArrowRight } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { ImageWithFallback } from './figma/ImageWithFallback';
import type { Blogpost } from '@/types/Blogpost';

export interface BlogPost {
  id: string;
  title: string;
  excerpt: string;
  date: string;
  readTime: string;
  category: string;
  imageUrl: string;
}

const imageUrl = "test.jpg";

interface BlogCardProps {
  post: Blogpost;
}

export function BlogCard({ post }: BlogCardProps) {
  const navigate = useNavigate();

  return (
    <article className="bg-card rounded-lg border border-border overflow-hidden hover:shadow-lg transition-all duration-300 group">
      <div className="aspect-video overflow-hidden">
        <ImageWithFallback
          src={post.title_image_url}
          alt={post.title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
        />
      </div>
      
      <div className="p-6">
        <div className="flex items-center gap-2 mb-3">
          <span className="inline-block px-3 py-1 bg-secondary text-secondary-foreground rounded-full text-sm">
            {post.langcode}
          </span>
        </div>
        
        <h3 className="mb-3 group-hover:text-primary transition-colors">
          {post.title}
        </h3>
        
        <p className="text-muted-foreground mb-4">
          {post.summary}
        </p>
        
        <div className="flex items-center gap-4 text-sm text-muted-foreground mb-4">
          <div className="flex items-center gap-1">
            <Calendar className="w-4 h-4" />
            <span>{new Date(post.created * 1000).toLocaleDateString('de-DE')}</span>
          </div>
          <div className="flex items-center gap-1">
            <Clock className="w-4 h-4" />
            <span>{new Date(post.changed * 1000).toLocaleDateString('de-DE')}</span>
          </div>
        </div>
        
        <button
          onClick={() => navigate(`/blog/${post.nid}`)}
          className="flex items-center gap-2 text-primary hover:gap-3 transition-all duration-200"
        >
          Weiterlesen
          <ArrowRight className="w-4 h-4" />
        </button>
      </div>
    </article>
  );
}

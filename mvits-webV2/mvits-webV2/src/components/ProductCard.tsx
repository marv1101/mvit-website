import { Code, Download, Star } from 'lucide-react';
import { ProductInfo } from './ProductInfo';

export interface Product {
  id: string;
  name: string;
  description: string;
  category: string;
  price: string;
  features: string[];
  icon: typeof Code;
}

interface ProductCardProps {
  product: Product;
  productNavigation: (page: 'home' | 'ProductInfo') => void;
}

export function ProductCard({ product, productNavigation }: ProductCardProps) {
  const Icon = product.icon;
  
  return (
    <div className="bg-card rounded-lg border border-border overflow-hidden hover:shadow-lg transition-shadow duration-300">
      <div className="bg-gradient-to-br from-primary to-accent p-8">
        <Icon className="w-12 h-12 text-primary-foreground" />
      </div>
      
      <div className="p-6">
        <div className="flex items-start justify-between mb-2">
          <div>
            <h3 className="mb-1">{product.name}</h3>
            <span className="inline-block px-3 py-1 bg-secondary text-secondary-foreground rounded-full text-sm">
              {product.category}
            </span>
          </div>
          <div className="text-primary">
            {product.price}
          </div>
        </div>
        
        <p className="text-muted-foreground mb-4 mt-4">
          {product.description}
        </p>
        
        <div className="space-y-2 mb-4">
          {product.features.map((feature, index) => (
            <div key={index} className="flex items-center gap-2 text-sm">
              <div className="w-1.5 h-1.5 rounded-full bg-accent"></div>
              <span>{feature}</span>
            </div>
          ))}
        </div>
        
        <div className="flex items-center gap-4 text-sm text-muted-foreground border-t border-border pt-4 mb-4">
          <div className="flex items-center gap-1">
 
          </div>
          <div className="flex items-center gap-1">
            
          </div>
        </div>
        
        <button onClick={() => productNavigation('ProductInfo')}
        className="w-full px-6 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-accent transition-colors duration-200">
          Mehr erfahren
        </button>
      </div>
    </div>
  );
}

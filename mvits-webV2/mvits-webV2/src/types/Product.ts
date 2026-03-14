export interface Product {
  id: string;
  name: string;
  description: string;
  description_page?: string;
  category: string;
  price: string;
  features: string[];
  icon: string;
}
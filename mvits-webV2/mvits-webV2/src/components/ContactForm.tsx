import { Mail, Phone, MapPin, Send } from 'lucide-react';
import { useState } from 'react';
import toast, { Toaster } from 'react-hot-toast';
import { ContactModal } from './ContactModal';
import { UseContact } from '../hooks/UseContact';

export function ContactForm() {

  const [modalIsOpen, setIsOpen] = useState(false);
  const [allowedToSubmitContactInfo, setAllowedToSubmitContactInfo] = useState(false);
  const { submit, loading, error } = UseContact();

  function openModal() {
    setIsOpen(true);
  }

  function closeModal() {
    setIsOpen(false);
  }

  function closeModalWithoutConsent() {
    setAllowedToSubmitContactInfo(false);
    setIsOpen(false);

    toast.error('Ihre Nachricht konnte nicht gesendet werden, da Sie der Verarbeitung Ihrer Daten nicht zugestimmt haben.');
  }

  async function closeModalWithConsent() {
    setAllowedToSubmitContactInfo(true);
    setIsOpen(false);

    const result = await submit(formData);

    if (!result) {
      toast.error('Beim senden Ihrer Nachricht ist ein Fehler aufgetreten. Bitte versuchen Sie es später erneut.');
    }else{
      toast.success('Ihre Nachricht wurde erfolgreich gesendet!');
    }

    setFormData({ name: '', email: '', subject: '', message: '' });
  }

  function afterOpenModal() {
  }


  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    openModal(); // Öffnet das Modal nach dem Absenden des Formulars

  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <section id="contact" className="py-20 px-4 sm:px-6 lg:px-8">
      <ContactModal modalIsOpen={modalIsOpen} onConsent={closeModalWithConsent} onNoConsent={closeModalWithoutConsent} onClose={ closeModal } />

      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="mb-4">Kontaktieren Sie uns</h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            Haben Sie Fragen zu unseren Leistungen? Wir helfen Ihnen gerne weiter.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          {/* Contact Information */}
          <div className="space-y-8">
            <div>
              <h3 className="mb-6">Kontaktinformationen</h3>
              <div className="space-y-6">
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                    <Mail className="w-6 h-6 text-primary" />
                  </div>
                  <div>
                    <h4 className="mb-1">E-Mail</h4>
                    <p className="text-muted-foreground">contact@mvit-solutions.de</p>
                  </div>
                </div>

                <div className="hidden flex items-start gap-4">
                  <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                    <Phone className="w-6 h-6 text-primary" />
                  </div>
                  <div>
                    <h4 className="mb-1">Telefon</h4>
                    <p className="text-muted-foreground">+49 (0) 123 456789</p>
                    <p className="text-muted-foreground">Mo-Fr: 9:00 - 17:00 Uhr</p>
                  </div>
                </div>

                <div className="hidden flex items-start gap-4">
                  <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                    <MapPin className="w-6 h-6 text-primary" />
                  </div>
                  <div>
                    <h4 className="mb-1">Adresse</h4>
                    <p className="text-muted-foreground">Musterstraße 123</p>
                    <p className="text-muted-foreground">12345 Berlin, Deutschland</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gradient-to-br from-primary to-accent p-8 rounded-lg text-primary-foreground">
              <h4 className="mb-3">Schnell los legen!</h4>
              <p className="opacity-90">
                Wir antworten in der Regel innerhalb von 48 Stunden auf alle Anfragen. 
                Bei dringenden Anliegen rufen Sie uns bitte direkt an.
              </p>
            </div>
          </div>

          {/* Contact Form */}
          <div className="bg-card rounded-lg border border-border p-8">
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label htmlFor="name" className="block mb-2">
                  Name *
                </label>
                <input
                  type="text"
                  id="name"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 bg-input-background border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="Ihr Name"
                />
              </div>

              <div>
                <label htmlFor="email" className="block mb-2">
                  E-Mail *
                </label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 bg-input-background border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="ihre.email@beispiel.de"
                />
              </div>

              <div>
                <label htmlFor="subject" className="block mb-2">
                  Betreff *
                </label>
                <input
                  type="text"
                  id="subject"
                  name="subject"
                  value={formData.subject}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 bg-input-background border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="Worum geht es?"
                />
              </div>

              <div>
                <label htmlFor="message" className="block mb-2">
                  Nachricht *
                </label>
                <textarea
                  id="message"
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  required
                  rows={6}
                  className="w-full px-4 py-3 bg-input-background border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                  placeholder="Ihre Nachricht..."
                />
              </div>

              <button
                type="submit"
                className="w-full px-6 py-4 bg-primary text-primary-foreground rounded-lg hover:bg-accent transition-colors flex items-center justify-center gap-2"
              >
                <Send className="w-5 h-5" />
                Nachricht senden
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
}

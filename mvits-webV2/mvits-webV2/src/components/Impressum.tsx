import { ArrowLeft } from 'lucide-react';

interface ImpressumProps {
  onBack: () => void;
}

export function Impressum({ onBack }: ImpressumProps) {
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

        <h1 className="mb-8">Impressum</h1>

        <div className="bg-card rounded-lg border border-border p-8 space-y-8">
          <section>
            <h3 className="mb-4">Angaben gemäß § 5 TMG</h3>
            <p>
              mvit<br />
              Deutschland
            </p>
          </section>

          <section>
            <h3 className="mb-4">Vertreten durch</h3>
            <p>
              Marian<br />
            </p>
          </section>

          <section>
            <h3 className="mb-4">Kontakt</h3>
            <p>
              E-Mail: marvphoto@web.de<br />
              Website: www.mvit.de
            </p>
          </section>

          <section>
            <h3 className="mb-4">Umsatzsteuer-ID</h3>
            <p>
              Umsatzsteuer-Identifikationsnummer gemäß § 27 a Umsatzsteuergesetz:<br />
              n.a.
            </p>
          </section>

          <section>
            <h3 className="mb-4">Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV</h3>
            <p>
              Marian<br />
            </p>
          </section>

          <section>
            <h3 className="mb-4">EU-Streitschlichtung</h3>
            <p className="text-muted-foreground">
              Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit:{' '}
              <a 
                href="https://ec.europa.eu/consumers/odr" 
                target="_blank" 
                rel="noopener noreferrer"
                className="text-primary hover:underline"
              >
                https://ec.europa.eu/consumers/odr
              </a>
              .<br />
              Unsere E-Mail-Adresse finden Sie oben im Impressum.
            </p>
          </section>

          <section>
            <h3 className="mb-4">Verbraucherstreitbeilegung/Universalschlichtungsstelle</h3>
            <p className="text-muted-foreground">
              Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer 
              Verbraucherschlichtungsstelle teilzunehmen.
            </p>
          </section>

          <section>
            <h3 className="mb-4">Haftung für Inhalte</h3>
            <p className="text-muted-foreground">
              Als Diensteanbieter sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte auf diesen Seiten 
              nach den allgemeinen Gesetzen verantwortlich. Nach §§ 8 bis 10 TMG sind wir als 
              Diensteanbieter jedoch nicht verpflichtet, übermittelte oder gespeicherte fremde 
              Informationen zu überwachen oder nach Umständen zu forschen, die auf eine rechtswidrige 
              Tätigkeit hinweisen.
            </p>
            <p className="text-muted-foreground mt-4">
              Verpflichtungen zur Entfernung oder Sperrung der Nutzung von Informationen nach den 
              allgemeinen Gesetzen bleiben hiervon unberührt. Eine diesbezügliche Haftung ist jedoch 
              erst ab dem Zeitpunkt der Kenntnis einer konkreten Rechtsverletzung möglich. Bei 
              Bekanntwerden von entsprechenden Rechtsverletzungen werden wir diese Inhalte umgehend 
              entfernen.
            </p>
          </section>

          <section>
            <h3 className="mb-4">Haftung für Links</h3>
            <p className="text-muted-foreground">
              Unser Angebot enthält Links zu externen Websites Dritter, auf deren Inhalte wir keinen 
              Einfluss haben. Deshalb können wir für diese fremden Inhalte auch keine Gewähr 
              übernehmen. Für die Inhalte der verlinkten Seiten ist stets der jeweilige Anbieter oder 
              Betreiber der Seiten verantwortlich. Die verlinkten Seiten wurden zum Zeitpunkt der 
              Verlinkung auf mögliche Rechtsverstöße überprüft. Rechtswidrige Inhalte waren zum 
              Zeitpunkt der Verlinkung nicht erkennbar.
            </p>
            <p className="text-muted-foreground mt-4">
              Eine permanente inhaltliche Kontrolle der verlinkten Seiten ist jedoch ohne konkrete 
              Anhaltspunkte einer Rechtsverletzung nicht zumutbar. Bei Bekanntwerden von 
              Rechtsverletzungen werden wir derartige Links umgehend entfernen.
            </p>
          </section>

          <section>
            <h3 className="mb-4">Urheberrecht</h3>
            <p className="text-muted-foreground">
              Die durch die Seitenbetreiber erstellten Inhalte und Werke auf diesen Seiten unterliegen 
              dem deutschen Urheberrecht. Die Vervielfältigung, Bearbeitung, Verbreitung und jede Art 
              der Verwertung außerhalb der Grenzen des Urheberrechtes bedürfen der schriftlichen 
              Zustimmung des jeweiligen Autors bzw. Erstellers. Downloads und Kopien dieser Seite sind 
              nur für den privaten, nicht kommerziellen Gebrauch gestattet.
            </p>
            <p className="text-muted-foreground mt-4">
              Soweit die Inhalte auf dieser Seite nicht vom Betreiber erstellt wurden, werden die 
              Urheberrechte Dritter beachtet. Insbesondere werden Inhalte Dritter als solche 
              gekennzeichnet. Sollten Sie trotzdem auf eine Urheberrechtsverletzung aufmerksam werden, 
              bitten wir um einen entsprechenden Hinweis. Bei Bekanntwerden von Rechtsverletzungen 
              werden wir derartige Inhalte umgehend entfernen.
            </p>
          </section>
        </div>
      </div>
    </div>
  );
}

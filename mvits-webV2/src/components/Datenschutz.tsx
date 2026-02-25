import { ArrowLeft } from 'lucide-react';

interface DatenschutzProps {
  onBack: () => void;
}

export function Datenschutz({ onBack }: DatenschutzProps) {
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

        <h1 className="mb-8">Datenschutzerklärung</h1>

        <div className="bg-card rounded-lg border border-border p-8 space-y-8">
          <section>
            <h3 className="mb-4">1. Datenschutz auf einen Blick</h3>
            
            <h4 className="mb-3 mt-6">Allgemeine Hinweise</h4>
            <p className="text-muted-foreground">
              Die folgenden Hinweise geben einen einfachen Überblick darüber, was mit Ihren 
              personenbezogenen Daten passiert, wenn Sie diese Website besuchen. Personenbezogene 
              Daten sind alle Daten, mit denen Sie persönlich identifiziert werden können. 
              Ausführliche Informationen zum Thema Datenschutz entnehmen Sie unserer unter diesem 
              Text aufgeführten Datenschutzerklärung.
            </p>

            <h4 className="mb-3 mt-6">Datenerfassung auf dieser Website</h4>
            <p className="text-muted-foreground mb-4">
              <strong>Wer ist verantwortlich für die Datenerfassung auf dieser Website?</strong>
            </p>
            <p className="text-muted-foreground">
              Die Datenverarbeitung auf dieser Website erfolgt durch den Websitebetreiber. Dessen 
              Kontaktdaten können Sie dem Impressum dieser Website entnehmen.
            </p>

            <p className="text-muted-foreground mb-4 mt-6">
              <strong>Wie erfassen wir Ihre Daten?</strong>
            </p>
            <p className="text-muted-foreground">
              Ihre Daten werden zum einen dadurch erhoben, dass Sie uns diese mitteilen. Hierbei kann 
              es sich z. B. um Daten handeln, die Sie in ein Kontaktformular eingeben.
            </p>
            <p className="text-muted-foreground mt-4">
              Andere Daten werden automatisch oder nach Ihrer Einwilligung beim Besuch der Website 
              durch unsere IT-Systeme erfasst. Das sind vor allem technische Daten (z. B. 
              Internetbrowser, Betriebssystem oder Uhrzeit des Seitenaufrufs). Die Erfassung dieser 
              Daten erfolgt automatisch, sobald Sie diese Website betreten.
            </p>

            <p className="text-muted-foreground mb-4 mt-6">
              <strong>Wofür nutzen wir Ihre Daten?</strong>
            </p>
            <p className="text-muted-foreground">
              Ein Teil der Daten wird erhoben, um eine fehlerfreie Bereitstellung der Website zu 
              gewährleisten. Andere Daten können zur Analyse Ihres Nutzerverhaltens verwendet werden.
            </p>

            <p className="text-muted-foreground mb-4 mt-6">
              <strong>Welche Rechte haben Sie bezüglich Ihrer Daten?</strong>
            </p>
            <p className="text-muted-foreground">
              Sie haben jederzeit das Recht, unentgeltlich Auskunft über Herkunft, Empfänger und Zweck 
              Ihrer gespeicherten personenbezogenen Daten zu erhalten. Sie haben außerdem ein Recht, 
              die Berichtigung oder Löschung dieser Daten zu verlangen. Wenn Sie eine Einwilligung zur 
              Datenverarbeitung erteilt haben, können Sie diese Einwilligung jederzeit für die Zukunft 
              widerrufen. Außerdem haben Sie das Recht, unter bestimmten Umständen die Einschränkung 
              der Verarbeitung Ihrer personenbezogenen Daten zu verlangen. Des Weiteren steht Ihnen ein 
              Beschwerderecht bei der zuständigen Aufsichtsbehörde zu.
            </p>
          </section>

          <section>
            <h3 className="mb-4">2. Hosting</h3>
            <p className="text-muted-foreground">
              Wir hosten die Inhalte unserer Website bei folgendem Anbieter:
            </p>
            
            <h4 className="mb-3 mt-6">Externes Hosting</h4>
            <p className="text-muted-foreground">
              Diese Website wird extern gehostet. Die personenbezogenen Daten, die auf dieser Website 
              erfasst werden, werden auf den Servern des Hosters gespeichert. Hierbei kann es sich v. a. 
              um IP-Adressen, Kontaktanfragen, Meta- und Kommunikationsdaten, Vertragsdaten, 
              Kontaktdaten, Namen, Websitezugriffe und sonstige Daten, die über eine Website generiert 
              werden, handeln.
            </p>
            <p className="text-muted-foreground mt-4">
              Das externe Hosting erfolgt zum Zwecke der Vertragserfüllung gegenüber unseren 
              potenziellen und bestehenden Kunden (Art. 6 Abs. 1 lit. b DSGVO) und im Interesse einer 
              sicheren, schnellen und effizienten Bereitstellung unseres Online-Angebots durch einen 
              professionellen Anbieter (Art. 6 Abs. 1 lit. f DSGVO).
            </p>
          </section>

          <section>
            <h3 className="mb-4">3. Allgemeine Hinweise und Pflichtinformationen</h3>
            
            <h4 className="mb-3 mt-6">Datenschutz</h4>
            <p className="text-muted-foreground">
              Die Betreiber dieser Seiten nehmen den Schutz Ihrer persönlichen Daten sehr ernst. Wir 
              behandeln Ihre personenbezogenen Daten vertraulich und entsprechend den gesetzlichen 
              Datenschutzvorschriften sowie dieser Datenschutzerklärung.
            </p>
            <p className="text-muted-foreground mt-4">
              Wenn Sie diese Website benutzen, werden verschiedene personenbezogene Daten erhoben. 
              Personenbezogene Daten sind Daten, mit denen Sie persönlich identifiziert werden können. 
              Die vorliegende Datenschutzerklärung erläutert, welche Daten wir erheben und wofür wir 
              sie nutzen. Sie erläutert auch, wie und zu welchem Zweck das geschieht.
            </p>

            <h4 className="mb-3 mt-6">Hinweis zur verantwortlichen Stelle</h4>
            <p className="text-muted-foreground">
              Die verantwortliche Stelle für die Datenverarbeitung auf dieser Website ist:
            </p>
            <p className="text-muted-foreground mt-4">
              DevSolutions GmbH<br />
              Musterstraße 123<br />
              12345 Berlin<br />
              Deutschland
            </p>
            <p className="text-muted-foreground mt-4">
              Telefon: +49 (0) 123 456789<br />
              E-Mail: info@devsolutions.de
            </p>
            <p className="text-muted-foreground mt-4">
              Verantwortliche Stelle ist die natürliche oder juristische Person, die allein oder 
              gemeinsam mit anderen über die Zwecke und Mittel der Verarbeitung von personenbezogenen 
              Daten (z. B. Namen, E-Mail-Adressen o. Ä.) entscheidet.
            </p>

            <h4 className="mb-3 mt-6">Speicherdauer</h4>
            <p className="text-muted-foreground">
              Soweit innerhalb dieser Datenschutzerklärung keine speziellere Speicherdauer genannt 
              wurde, verbleiben Ihre personenbezogenen Daten bei uns, bis der Zweck für die 
              Datenverarbeitung entfällt. Wenn Sie ein berechtigtes Löschersuchen geltend machen oder 
              eine Einwilligung zur Datenverarbeitung widerrufen, werden Ihre Daten gelöscht, sofern 
              wir keine anderen rechtlich zulässigen Gründe für die Speicherung Ihrer personenbezogenen 
              Daten haben (z. B. steuer- oder handelsrechtliche Aufbewahrungsfristen); im 
              letztgenannten Fall erfolgt die Löschung nach Fortfall dieser Gründe.
            </p>

            <h4 className="mb-3 mt-6">Widerruf Ihrer Einwilligung zur Datenverarbeitung</h4>
            <p className="text-muted-foreground">
              Viele Datenverarbeitungsvorgänge sind nur mit Ihrer ausdrücklichen Einwilligung möglich. 
              Sie können eine bereits erteilte Einwilligung jederzeit widerrufen. Die Rechtmäßigkeit 
              der bis zum Widerruf erfolgten Datenverarbeitung bleibt vom Widerruf unberührt.
            </p>

            <h4 className="mb-3 mt-6">Auskunft, Löschung und Berichtigung</h4>
            <p className="text-muted-foreground">
              Sie haben im Rahmen der geltenden gesetzlichen Bestimmungen jederzeit das Recht auf 
              unentgeltliche Auskunft über Ihre gespeicherten personenbezogenen Daten, deren Herkunft 
              und Empfänger und den Zweck der Datenverarbeitung und ggf. ein Recht auf Berichtigung 
              oder Löschung dieser Daten. Hierzu sowie zu weiteren Fragen zum Thema personenbezogene 
              Daten können Sie sich jederzeit an uns wenden.
            </p>
          </section>

          <section>
            <h3 className="mb-4">4. Datenerfassung auf dieser Website</h3>
            
            <h4 className="mb-3 mt-6">Kontaktformular</h4>
            <p className="text-muted-foreground">
              Wenn Sie uns per Kontaktformular Anfragen zukommen lassen, werden Ihre Angaben aus dem 
              Anfrageformular inklusive der von Ihnen dort angegebenen Kontaktdaten zwecks Bearbeitung 
              der Anfrage und für den Fall von Anschlussfragen bei uns gespeichert. Diese Daten geben 
              wir nicht ohne Ihre Einwilligung weiter.
            </p>
            <p className="text-muted-foreground mt-4">
              Die Verarbeitung dieser Daten erfolgt auf Grundlage von Art. 6 Abs. 1 lit. b DSGVO, 
              sofern Ihre Anfrage mit der Erfüllung eines Vertrags zusammenhängt oder zur Durchführung 
              vorvertraglicher Maßnahmen erforderlich ist. In allen übrigen Fällen beruht die 
              Verarbeitung auf unserem berechtigten Interesse an der effektiven Bearbeitung der an uns 
              gerichteten Anfragen (Art. 6 Abs. 1 lit. f DSGVO) oder auf Ihrer Einwilligung (Art. 6 
              Abs. 1 lit. a DSGVO) sofern diese abgefragt wurde.
            </p>
            <p className="text-muted-foreground mt-4">
              Die von Ihnen im Kontaktformular eingegebenen Daten verbleiben bei uns, bis Sie uns zur 
              Löschung auffordern, Ihre Einwilligung zur Speicherung widerrufen oder der Zweck für die 
              Datenspeicherung entfällt (z. B. nach abgeschlossener Bearbeitung Ihrer Anfrage). 
              Zwingende gesetzliche Bestimmungen – insbesondere Aufbewahrungsfristen – bleiben 
              unberührt.
            </p>

            <h4 className="mb-3 mt-6">Anfrage per E-Mail, Telefon oder Telefax</h4>
            <p className="text-muted-foreground">
              Wenn Sie uns per E-Mail, Telefon oder Telefax kontaktieren, wird Ihre Anfrage inklusive 
              aller daraus hervorgehenden personenbezogenen Daten (Name, Anfrage) zum Zwecke der 
              Bearbeitung Ihres Anliegens bei uns gespeichert und verarbeitet. Diese Daten geben wir 
              nicht ohne Ihre Einwilligung weiter.
            </p>
            <p className="text-muted-foreground mt-4">
              Die Verarbeitung dieser Daten erfolgt auf Grundlage von Art. 6 Abs. 1 lit. b DSGVO, 
              sofern Ihre Anfrage mit der Erfüllung eines Vertrags zusammenhängt oder zur Durchführung 
              vorvertraglicher Maßnahmen erforderlich ist. In allen übrigen Fällen beruht die 
              Verarbeitung auf unserem berechtigten Interesse an der effektiven Bearbeitung der an uns 
              gerichteten Anfragen (Art. 6 Abs. 1 lit. f DSGVO) oder auf Ihrer Einwilligung (Art. 6 
              Abs. 1 lit. a DSGVO) sofern diese abgefragt wurde.
            </p>
          </section>

          <section>
            <h3 className="mb-4">5. Ihre Rechte</h3>
            
            <p className="text-muted-foreground">
              Sie haben das Recht:
            </p>
            <ul className="list-disc list-inside text-muted-foreground mt-4 space-y-2">
              <li>
                gemäß Art. 15 DSGVO Auskunft über Ihre von uns verarbeiteten personenbezogenen Daten 
                zu verlangen
              </li>
              <li>
                gemäß Art. 16 DSGVO unverzüglich die Berichtigung unrichtiger oder Vervollständigung 
                Ihrer bei uns gespeicherten personenbezogenen Daten zu verlangen
              </li>
              <li>
                gemäß Art. 17 DSGVO die Löschung Ihrer bei uns gespeicherten personenbezogenen Daten 
                zu verlangen
              </li>
              <li>
                gemäß Art. 18 DSGVO die Einschränkung der Verarbeitung Ihrer personenbezogenen Daten 
                zu verlangen
              </li>
              <li>
                gemäß Art. 20 DSGVO Ihre personenbezogenen Daten, die Sie uns bereitgestellt haben, 
                in einem strukturierten, gängigen und maschinenlesbaren Format zu erhalten
              </li>
              <li>
                gemäß Art. 7 Abs. 3 DSGVO Ihre einmal erteilte Einwilligung jederzeit gegenüber uns 
                zu widerrufen
              </li>
              <li>
                gemäß Art. 77 DSGVO sich bei einer Aufsichtsbehörde zu beschweren
              </li>
            </ul>
          </section>

          <section>
            <h3 className="mb-4">Kontakt bei Datenschutzfragen</h3>
            <p className="text-muted-foreground">
              Bei Fragen zur Erhebung, Verarbeitung oder Nutzung Ihrer personenbezogenen Daten, bei 
              Auskünften, Berichtigung, Sperrung oder Löschung von Daten sowie Widerruf erteilter 
              Einwilligungen wenden Sie sich bitte an:
            </p>
            <p className="text-muted-foreground mt-4">
              DevSolutions GmbH<br />
              Datenschutzbeauftragter<br />
              Musterstraße 123<br />
              12345 Berlin<br />
              E-Mail: datenschutz@devsolutions.de
            </p>
          </section>

          <p className="text-sm text-muted-foreground mt-8">
            Stand: Dezember 2024
          </p>
        </div>
      </div>
    </div>
  );
}

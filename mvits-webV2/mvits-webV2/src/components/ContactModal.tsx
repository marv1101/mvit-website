import Modal from 'react-modal';
import { useState } from 'react';
import toast, { Toaster } from 'react-hot-toast';

type ContactModalProps = {
    modalIsOpen: boolean;
    onClose: () => void;
    onConsent: () => void;
    onNoConsent: () => void;
};

export function ContactModal({ modalIsOpen, onClose, onConsent, onNoConsent }: ContactModalProps) {

    const customStyles = {
        content: {
            top: '50%',
            left: '50%',
            right: 'auto',
            bottom: 'auto',
            marginRight: '-50%',
            transform: 'translate(-50%, -50%)',
        },
    };

    Modal.setAppElement('#root'); // Setzt das App-Element für die Modal-Komponente

    //Modal als Komponente
    return (
        <section>
            <Toaster position="top-right" reverseOrder={false} />
            <Modal
                isOpen={modalIsOpen}
                style={customStyles}
                contentLabel="Submit Modal"
              >
        
                <h2>Vielen Dank für Ihre Nachricht!</h2>
                <p> Aufgrund der DSGVO müssen sie hier bestätigen, dass wir ihre angegebenen Daten verarbeiten dürfen. Dies Betrifft ihren Namen, ihre E-Mail-Adresse und ihre Nachricht.</p>
                <p> Für weitere Informationen kontaktieren Sie uns unter marvphoto@web.de oder besuchen Sie unsere Datenschutz Seite. Diese finden sie unter <a href="/datenschutz" className="text-primary hover:underline">Datenschutz</a>.</p>
        
                <button onClick={onConsent} className="mt-4 px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark">
                  Ich stimme der Verarbeitung zu
                </button>
                <button onClick={onNoConsent} className="mt-4 ml-2 px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400">
                  Ich stimme der Verarbeitung nicht zu
                </button>
              </Modal>
        </section>
    );
}
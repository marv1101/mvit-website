import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, MessagesSquare } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Badge } from "./ui/badge";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "./ui/table";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from "./ui/dialog";
import { fetchAllContactRequests, updateContactStatus, type ContactRequest, type ContactStatus } from "../services/contactAdminService";

const dateFormatter = new Intl.DateTimeFormat("de-DE", { dateStyle: "medium", timeStyle: "short" });

export function ContactManager() {
    const navigate = useNavigate();
    const [contacts, setContacts] = useState<ContactRequest[]>([]);
    const [loading, setLoading] = useState(true);
    const [updatingId, setUpdatingId] = useState<number | null>(null);
    const [error, setError] = useState("");
    const [messageContact, setMessageContact] = useState<ContactRequest | null>(null);

    const loadContacts = async () => {
        try {
            setLoading(true);
            const data = await fetchAllContactRequests();
            setContacts(data);
        } catch (err) {
            setError("Fehler beim Laden der Kontaktanfragen");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadContacts();
    }, []);

    const handleToggleStatus = async (contact: ContactRequest) => {
        const newStatus: ContactStatus = contact.status === "open" ? "handled" : "open";
        setUpdatingId(contact.id);
        try {
            const updated = await updateContactStatus(contact.id, newStatus);
            setContacts(contacts.map((c) => (c.id === contact.id ? updated : c)));
        } catch (err) {
            setError("Fehler beim Aktualisieren des Status");
            console.error(err);
        } finally {
            setUpdatingId(null);
        }
    };

    return (
        <div className="min-h-screen bg-background p-6 pt-20">
            <div className="max-w-6xl mx-auto">
                <div className="flex items-center gap-4 mb-6">
                    <Button variant="ghost" size="icon" onClick={() => navigate("/admin")}>
                        <ArrowLeft className="h-5 w-5" />
                    </Button>
                    <div className="flex-1">
                        <h1 className="text-2xl font-bold">Kontaktanfragen</h1>
                        <p className="text-muted-foreground">Übersicht über alle eingegangenen Kontaktanfragen</p>
                    </div>
                </div>

                {error && (
                    <div className="p-4 mb-6 rounded-md bg-destructive/10 border border-destructive text-destructive text-sm">
                        {error}
                    </div>
                )}

                {loading ? (
                    <div className="flex justify-center py-12">
                        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
                    </div>
                ) : contacts.length === 0 ? (
                    <Card>
                        <CardContent className="flex flex-col items-center justify-center py-12">
                            <MessagesSquare className="h-12 w-12 text-muted-foreground mb-4" />
                            <p className="text-muted-foreground">Noch keine Kontaktanfragen vorhanden</p>
                        </CardContent>
                    </Card>
                ) : (
                    <Card>
                        <CardHeader>
                            <CardTitle>Alle Anfragen</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>Erhalten</TableHead>
                                        <TableHead>Name</TableHead>
                                        <TableHead>Email</TableHead>
                                        <TableHead>Betreff</TableHead>
                                        <TableHead>Status</TableHead>
                                        <TableHead>Aktionen</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {contacts.map((contact) => (
                                        <TableRow key={contact.id}>
                                            <TableCell>{dateFormatter.format(new Date(contact.createdAt))}</TableCell>
                                            <TableCell className="font-medium">{contact.name}</TableCell>
                                            <TableCell>{contact.email}</TableCell>
                                            <TableCell className="max-w-48 truncate">{contact.subject}</TableCell>
                                            <TableCell>
                                                <Badge variant={contact.status === "open" ? "destructive" : "secondary"}>
                                                    {contact.status === "open" ? "Offen" : "Erledigt"}
                                                </Badge>
                                            </TableCell>
                                            <TableCell>
                                                <div className="flex gap-2">
                                                    <Button
                                                        variant="outline"
                                                        size="sm"
                                                        onClick={() => setMessageContact(contact)}
                                                    >
                                                        Nachricht
                                                    </Button>
                                                    <Button
                                                        variant="outline"
                                                        size="sm"
                                                        onClick={() => handleToggleStatus(contact)}
                                                        disabled={updatingId === contact.id}
                                                    >
                                                        {updatingId === contact.id
                                                            ? "Speichert..."
                                                            : contact.status === "open"
                                                                ? "Als erledigt markieren"
                                                                : "Als offen markieren"}
                                                    </Button>
                                                </div>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </CardContent>
                    </Card>
                )}

                <Dialog open={messageContact !== null} onOpenChange={(open) => !open && setMessageContact(null)}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Nachricht von {messageContact?.name}</DialogTitle>
                            <DialogDescription>
                                {messageContact && dateFormatter.format(new Date(messageContact.createdAt))} · {messageContact?.email}
                            </DialogDescription>
                        </DialogHeader>
                        <div className="whitespace-pre-wrap text-sm max-h-72 overflow-y-auto">
                            {messageContact?.message}
                        </div>
                    </DialogContent>
                </Dialog>
            </div>
        </div>
    );
}

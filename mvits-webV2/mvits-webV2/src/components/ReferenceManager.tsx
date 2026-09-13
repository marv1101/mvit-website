import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Plus, Pencil, Trash2, ArrowLeft, Quote } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "./ui/dialog";
import { getAllReferences, deleteReference, type ReferenceFormData } from "../services/referenceAdminService";

export function ReferenceManager() {
    const navigate = useNavigate();
    const [references, setReferences] = useState<ReferenceFormData[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [referenceToDelete, setReferenceToDelete] = useState<ReferenceFormData | null>(null);
    const [deleting, setDeleting] = useState(false);

    const loadReferences = async () => {
        try {
            setLoading(true);
            const data = await getAllReferences();
            setReferences(data);
        } catch (err) {
            setError("Fehler beim Laden der Referenzen");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadReferences();
    }, []);

    const handleDeleteClick = (reference: ReferenceFormData) => {
        setReferenceToDelete(reference);
        setDeleteDialogOpen(true);
    };

    const handleDeleteConfirm = async () => {
        if (!referenceToDelete?.id) return;
        try {
            setDeleting(true);
            await deleteReference(referenceToDelete.id);
            setReferences(references.filter((r) => r.id !== referenceToDelete.id));
            setDeleteDialogOpen(false);
            setReferenceToDelete(null);
        } catch (err) {
            setError("Fehler beim Löschen");
            console.error(err);
        } finally {
            setDeleting(false);
        }
    };

    return (
        <div className="min-h-screen bg-background p-6 pt-20">
            <div className="max-w-4xl mx-auto">
                <div className="flex items-center gap-4 mb-6">
                    <Button variant="ghost" size="icon" onClick={() => navigate("/admin")}>
                        <ArrowLeft className="h-5 w-5" />
                    </Button>
                    <div className="flex-1">
                        <h1 className="text-2xl font-bold">Referenzen verwalten</h1>
                        <p className="text-muted-foreground">Erstelle, bearbeite und lösche Referenzen</p>
                    </div>
                    <Button onClick={() => navigate("/admin/references/new")}>
                        <Plus className="h-4 w-4 mr-2" />
                        Neue Referenz
                    </Button>
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
                ) : references.length === 0 ? (
                    <Card>
                        <CardContent className="flex flex-col items-center justify-center py-12">
                            <Quote className="h-12 w-12 text-muted-foreground mb-4" />
                            <p className="text-muted-foreground mb-4">Noch keine Referenzen vorhanden</p>
                            <Button onClick={() => navigate("/admin/references/new")}>
                                <Plus className="h-4 w-4 mr-2" />
                                Erste Referenz erstellen
                            </Button>
                        </CardContent>
                    </Card>
                ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {references.map((reference) => (
                            <Card key={reference.id} className="hover:shadow-md transition-shadow">
                                <CardContent className="flex items-center gap-4 p-4">
                                    <div className="flex-1 min-w-0">
                                        <div className="flex items-center gap-2 mb-1">
                                            <h3 className="font-semibold truncate">{reference.company}</h3>
                                            {reference.logo_url && (
                                                <img
                                                    src={reference.logo_url}
                                                    alt={reference.company}
                                                    className="h-6 w-6 object-contain shrink-0"
                                                />
                                            )}
                                        </div>
                                        <p className="text-sm text-muted-foreground line-clamp-2">{reference.summary}</p>
                                    </div>
                                    <div className="flex gap-2 shrink-0">
                                        <Button
                                            variant="outline"
                                            size="icon"
                                            onClick={() => navigate(`/admin/references/${reference.id}/edit`)}
                                        >
                                            <Pencil className="h-4 w-4" />
                                        </Button>
                                        <Button
                                            variant="outline"
                                            size="icon"
                                            onClick={() => handleDeleteClick(reference)}
                                        >
                                            <Trash2 className="h-4 w-4 text-destructive" />
                                        </Button>
                                    </div>
                                </CardContent>
                            </Card>
                        ))}
                    </div>
                )}

                <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Referenz löschen</DialogTitle>
                            <DialogDescription>
                                Möchtest du die Referenz &quot;{referenceToDelete?.company}&quot; wirklich löschen?
                                Diese Aktion kann nicht rückgängig gemacht werden.
                            </DialogDescription>
                        </DialogHeader>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setDeleteDialogOpen(false)} disabled={deleting}>
                                Abbrechen
                            </Button>
                            <Button variant="destructive" onClick={handleDeleteConfirm} disabled={deleting}>
                                {deleting ? "Löscht..." : "Löschen"}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </div>
    );
}

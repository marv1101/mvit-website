import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Plus, Pencil, Trash2, ArrowLeft, Package } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Badge } from "./ui/badge";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "./ui/dialog";
import { getAllOfferings, deleteOffering, type OfferingFormData } from "../services/offeringAdminService";

export function OfferingManager() {
    const navigate = useNavigate();
    const [offerings, setOfferings] = useState<OfferingFormData[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [offeringToDelete, setOfferingToDelete] = useState<OfferingFormData | null>(null);
    const [deleting, setDeleting] = useState(false);

    const loadOfferings = async () => {
        try {
            setLoading(true);
            const data = await getAllOfferings();
            setOfferings(data);
        } catch (err) {
            setError("Fehler beim Laden der Leistungen");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadOfferings();
    }, []);

    const handleDeleteClick = (offering: OfferingFormData) => {
        setOfferingToDelete(offering);
        setDeleteDialogOpen(true);
    };

    const handleDeleteConfirm = async () => {
        if (!offeringToDelete?.id) return;
        try {
            setDeleting(true);
            await deleteOffering(offeringToDelete.id);
            setOfferings(offerings.filter((o) => o.id !== offeringToDelete.id));
            setDeleteDialogOpen(false);
            setOfferingToDelete(null);
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
                        <h1 className="text-2xl font-bold">Leistungen verwalten</h1>
                        <p className="text-muted-foreground">Erstelle, bearbeite und lösche Leistungen</p>
                    </div>
                    <Button onClick={() => navigate("/admin/offerings/new")}>
                        <Plus className="h-4 w-4 mr-2" />
                        Neue Leistung
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
                ) : offerings.length === 0 ? (
                    <Card>
                        <CardContent className="flex flex-col items-center justify-center py-12">
                            <Package className="h-12 w-12 text-muted-foreground mb-4" />
                            <p className="text-muted-foreground mb-4">Noch keine Leistungen vorhanden</p>
                            <Button onClick={() => navigate("/admin/offerings/new")}>
                                <Plus className="h-4 w-4 mr-2" />
                                Erste Leistung erstellen
                            </Button>
                        </CardContent>
                    </Card>
                ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {offerings.map((offering) => (
                            <Card key={offering.id} className="hover:shadow-md transition-shadow">
                                <CardContent className="flex items-center gap-4 p-4">
                                    <div className="flex-1 min-w-0">
                                        <div className="flex items-center gap-2 mb-1">
                                            <h3 className="font-semibold truncate">{offering.title}</h3>
                                            <Badge variant="secondary">{offering.price === 0 ? "Projektbasiert" : `${offering.price}€`}</Badge>
                                        </div>
                                        <p className="text-sm text-muted-foreground truncate">{offering.description}</p>
                                        {offering.features.length > 0 && (
                                            <div className="flex gap-1 mt-2 flex-wrap">
                                                {offering.features.slice(0, 3).map((f, i) => (
                                                    <Badge key={i} variant="outline" className="text-xs">
                                                        {f}
                                                    </Badge>
                                                ))}
                                                {offering.features.length > 3 && (
                                                    <Badge variant="outline" className="text-xs">
                                                        +{offering.features.length - 3}
                                                    </Badge>
                                                )}
                                            </div>
                                        )}
                                    </div>
                                    <div className="flex gap-2 shrink-0">
                                        <Button
                                            variant="outline"
                                            size="icon"
                                            onClick={() => navigate(`/admin/offerings/${offering.id}/edit`)}
                                        >
                                            <Pencil className="h-4 w-4" />
                                        </Button>
                                        <Button
                                            variant="outline"
                                            size="icon"
                                            onClick={() => handleDeleteClick(offering)}
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
                            <DialogTitle>Leistung löschen</DialogTitle>
                            <DialogDescription>
                                Möchtest du die Leistung &quot;{offeringToDelete?.title}&quot; wirklich löschen?
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

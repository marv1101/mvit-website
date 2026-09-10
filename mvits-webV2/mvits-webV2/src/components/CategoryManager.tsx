import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Plus, Pencil, Trash2, ArrowLeft, Tags, X, Save } from "lucide-react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "./ui/dialog";
import { getAllCategories, createCategory, updateCategory, deleteCategory, type OfferingCategory } from "../services/offeringAdminService";

export function CategoryManager() {
    const navigate = useNavigate();
    const [categories, setCategories] = useState<OfferingCategory[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [createDialogOpen, setCreateDialogOpen] = useState(false);
    const [editDialogOpen, setEditDialogOpen] = useState(false);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [selectedCategory, setSelectedCategory] = useState<OfferingCategory | null>(null);
    const [categoryName, setCategoryName] = useState("");
    const [categoryDescription, setCategoryDescription] = useState("");
    const [saving, setSaving] = useState(false);

    const loadCategories = async () => {
        try {
            setLoading(true);
            const data = await getAllCategories();
            setCategories(data);
        } catch (err) {
            setError("Fehler beim Laden der Kategorien");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadCategories();
    }, []);

    const resetForm = () => {
        setCategoryName("");
        setCategoryDescription("");
        setSelectedCategory(null);
    };

    const handleCreateClick = () => {
        resetForm();
        setCreateDialogOpen(true);
    };

    const handleEditClick = (category: OfferingCategory) => {
        setSelectedCategory(category);
        setCategoryName(category.name);
        setCategoryDescription(category.description || "");
        setEditDialogOpen(true);
    };

    const handleDeleteClick = (category: OfferingCategory) => {
        setSelectedCategory(category);
        setDeleteDialogOpen(true);
    };

    const handleSaveCreate = async () => {
        if (!categoryName.trim()) {
            setError("Name ist erforderlich");
            return;
        }
        try {
            setSaving(true);
            await createCategory({
                name: categoryName.trim(),
                description: categoryDescription.trim(),
            });
            await loadCategories();
            setCreateDialogOpen(false);
            resetForm();
        } catch (err) {
            setError("Fehler beim Erstellen der Kategorie");
            console.error(err);
        } finally {
            setSaving(false);
        }
    };

    const handleSaveEdit = async () => {
        if (!selectedCategory || !categoryName.trim()) {
            setError("Name ist erforderlich");
            return;
        }
        try {
            setSaving(true);
            await updateCategory(selectedCategory.id, {
                name: categoryName.trim(),
                description: categoryDescription.trim(),
            });
            await loadCategories();
            setEditDialogOpen(false);
            resetForm();
        } catch (err) {
            setError("Fehler beim Aktualisieren der Kategorie");
            console.error(err);
        } finally {
            setSaving(false);
        }
    };

    const handleDeleteConfirm = async () => {
        if (!selectedCategory) return;
        try {
            setSaving(true);
            await deleteCategory(selectedCategory.id);
            await loadCategories();
            setDeleteDialogOpen(false);
            resetForm();
        } catch (err) {
            setError("Fehler beim Löschen der Kategorie");
            console.error(err);
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="min-h-screen bg-background p-6">
            <div className="max-w-4xl mx-auto">
                <div className="flex items-center gap-4 mb-6">
                    <Button variant="ghost" size="icon" onClick={() => navigate("/admin")}>
                        <ArrowLeft className="h-5 w-5" />
                    </Button>
                    <div className="flex-1">
                        <h1 className="text-2xl font-bold">Kategorien verwalten</h1>
                        <p className="text-muted-foreground">Erstelle und verwalte Kategorien für Leistungen</p>
                    </div>
                    <Button onClick={handleCreateClick}>
                        <Plus className="h-4 w-4 mr-2" />
                        Neue Kategorie
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
                ) : categories.length === 0 ? (
                    <Card>
                        <CardContent className="flex flex-col items-center justify-center py-12">
                            <Tags className="h-12 w-12 text-muted-foreground mb-4" />
                            <p className="text-muted-foreground mb-4">Noch keine Kategorien vorhanden</p>
                            <Button onClick={handleCreateClick}>
                                <Plus className="h-4 w-4 mr-2" />
                                Erste Kategorie erstellen
                            </Button>
                        </CardContent>
                    </Card>
                ) : (
                    <div className="space-y-3">
                        {categories.map((category) => (
                            <Card key={category.id} className="hover:shadow-md transition-shadow">
                                <CardContent className="flex items-center gap-4 p-4">
                                    <div className="flex-1 min-w-0">
                                        <h3 className="font-semibold">{category.name}</h3>
                                        {category.description && (
                                            <p className="text-sm text-muted-foreground truncate">{category.description}</p>
                                        )}
                                    </div>
                                    <div className="flex gap-2 shrink-0">
                                        <Button
                                            variant="outline"
                                            size="icon"
                                            onClick={() => handleEditClick(category)}
                                        >
                                            <Pencil className="h-4 w-4" />
                                        </Button>
                                        <Button
                                            variant="outline"
                                            size="icon"
                                            onClick={() => handleDeleteClick(category)}
                                        >
                                            <Trash2 className="h-4 w-4 text-destructive" />
                                        </Button>
                                    </div>
                                </CardContent>
                            </Card>
                        ))}
                    </div>
                )}

                {/* Create Dialog */}
                <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Neue Kategorie erstellen</DialogTitle>
                            <DialogDescription>
                                Erstelle eine neue Kategorie für Leistungen.
                            </DialogDescription>
                        </DialogHeader>
                        <div className="space-y-4 py-4">
                            <div>
                                <Label htmlFor="cat-name-create">Name *</Label>
                                <Input
                                    id="cat-name-create"
                                    value={categoryName}
                                    onChange={(e) => setCategoryName(e.target.value)}
                                    placeholder="z.B. Cloud Services"
                                />
                            </div>
                            <div>
                                <Label htmlFor="cat-desc-create">Beschreibung</Label>
                                <Input
                                    id="cat-desc-create"
                                    value={categoryDescription}
                                    onChange={(e) => setCategoryDescription(e.target.value)}
                                    placeholder="Optionale Beschreibung"
                                />
                            </div>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setCreateDialogOpen(false)} disabled={saving}>
                                Abbrechen
                            </Button>
                            <Button onClick={handleSaveCreate} disabled={saving}>
                                <Save className="h-4 w-4 mr-2" />
                                {saving ? "Erstellt..." : "Erstellen"}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Edit Dialog */}
                <Dialog open={editDialogOpen} onOpenChange={setEditDialogOpen}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Kategorie bearbeiten</DialogTitle>
                            <DialogDescription>
                                Ändere die Details der Kategorie.
                            </DialogDescription>
                        </DialogHeader>
                        <div className="space-y-4 py-4">
                            <div>
                                <Label htmlFor="cat-name-edit">Name *</Label>
                                <Input
                                    id="cat-name-edit"
                                    value={categoryName}
                                    onChange={(e) => setCategoryName(e.target.value)}
                                    placeholder="Kategoriename"
                                />
                            </div>
                            <div>
                                <Label htmlFor="cat-desc-edit">Beschreibung</Label>
                                <Input
                                    id="cat-desc-edit"
                                    value={categoryDescription}
                                    onChange={(e) => setCategoryDescription(e.target.value)}
                                    placeholder="Optionale Beschreibung"
                                />
                            </div>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setEditDialogOpen(false)} disabled={saving}>
                                Abbrechen
                            </Button>
                            <Button onClick={handleSaveEdit} disabled={saving}>
                                <Save className="h-4 w-4 mr-2" />
                                {saving ? "Speichert..." : "Speichern"}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Delete Dialog */}
                <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Kategorie löschen</DialogTitle>
                            <DialogDescription>
                                Möchtest du die Kategorie &quot;{selectedCategory?.name}&quot; wirklich löschen?
                                Diese Aktion kann nicht rückgängig gemacht werden.
                            </DialogDescription>
                        </DialogHeader>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setDeleteDialogOpen(false)} disabled={saving}>
                                Abbrechen
                            </Button>
                            <Button variant="destructive" onClick={handleDeleteConfirm} disabled={saving}>
                                {saving ? "Löscht..." : "Löschen"}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </div>
    );
}

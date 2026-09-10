import { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Plus, X, ArrowLeft, Save } from "lucide-react";
import { RichTextEditor } from "./RichTextEditor";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "./ui/select";
import {
    getAllCategories,
    getOfferingById,
    createOffering,
    updateOffering,
    type OfferingFormData,
    type OfferingCategory,
} from "../services/offeringAdminService";

export function OfferingForm() {
    const navigate = useNavigate();
    const { id } = useParams<{ id: string }>();
    const isEdit = Boolean(id);

    const [loading, setLoading] = useState(isEdit);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState("");

    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [descriptionPage, setDescriptionPage] = useState("");
    const [icon, setIcon] = useState("");
    const [categoryId, setCategoryId] = useState<number | null>(null);
    const [features, setFeatures] = useState<string[]>([""]);
    const [price, setPrice] = useState("");
    const [categories, setCategories] = useState<OfferingCategory[]>([]);

    useEffect(() => {
        const loadData = async () => {
            try {
                const cats = await getAllCategories();
                setCategories(cats);

                if (id) {
                    const offering = await getOfferingById(parseInt(id));
                    setTitle(offering.title);
                    setDescription(offering.description);
                    setDescriptionPage(offering.description_page);
                    setIcon(offering.icon);
                    setFeatures(offering.features.length > 0 ? offering.features : [""]);
                    setPrice(offering.price.toString());
                    if (offering.category) {
                        setCategoryId(offering.category);
                    } else if (cats.length > 0 && cats[0]) {
                        setCategoryId(cats[0].id);
                    }
                } else if (cats.length > 0 && cats[0]) {
                    setCategoryId(cats[0].id);
                }
            } catch (err) {
                setError("Fehler beim Laden der Daten");
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        loadData();
    }, [id]);

    const handleAddFeature = () => {
        setFeatures([...features, ""]);
    };

    const handleRemoveFeature = (index: number) => {
        if (features.length <= 1) return;
        setFeatures(features.filter((_, i) => i !== index));
    };

    const handleFeatureChange = (index: number, value: string) => {
        const updated = [...features];
        updated[index] = value;
        setFeatures(updated);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError("");

        if (!title.trim() || !description.trim() || !icon.trim() || categoryId === null || price === "") {
            setError("Bitte fülle alle Pflichtfelder aus (Titel, Beschreibung, Icon, Kategorie, Preis)");
            return;
        }

        setSaving(true);
        try {
            const data: Omit<OfferingFormData, "id"> = {
                title: title.trim(),
                description: description.trim(),
                description_page: descriptionPage,
                icon: icon.trim(),
                category: categoryId,
                features: features.filter((f) => f.trim().length > 0),
                price: parseInt(price),
            };

            if (isEdit && id) {
                await updateOffering(parseInt(id), data);
            } else {
                await createOffering(data);
            }

            navigate("/admin/offerings");
        } catch (err) {
            setError("Fehler beim Speichern");
            console.error(err);
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-background p-6">
            <div className="max-w-4xl mx-auto">
                <div className="flex items-center gap-4 mb-6">
                    <Button variant="ghost" size="icon" onClick={() => navigate("/admin/offerings")}>
                        <ArrowLeft className="h-5 w-5" />
                    </Button>
                    <h1 className="text-2xl font-bold">
                        {isEdit ? "Leistung bearbeiten" : "Neue Leistung erstellen"}
                    </h1>
                </div>

                {error && (
                    <div className="p-4 mb-6 rounded-md bg-destructive/10 border border-destructive text-destructive text-sm">
                        {error}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-6">
                    <Card>
                        <CardHeader>
                            <CardTitle>Grunddaten</CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <Label htmlFor="title">Titel *</Label>
                                    <Input
                                        id="title"
                                        value={title}
                                        onChange={(e) => setTitle(e.target.value)}
                                        placeholder="z.B. Cloud Migration"
                                        required
                                    />
                                </div>
                                <div>
                                    <Label htmlFor="icon">Icon-Name *</Label>
                                    <Input
                                        id="icon"
                                        value={icon}
                                        onChange={(e) => setIcon(e.target.value)}
                                        placeholder="z.B. CloudUpload"
                                        required
                                    />
                                    <p className="text-xs text-muted-foreground mt-1">
                                        Lucide Icon Name (z.B. CloudUpload, Code, Database)
                                    </p>
                                </div>
                            </div>

                            <div>
                                <Label htmlFor="description">Kurzbeschreibung *</Label>
                                <Input
                                    id="description"
                                    value={description}
                                    onChange={(e) => setDescription(e.target.value)}
                                    placeholder="Kurze Beschreibung der Leistung"
                                    required
                                />
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <Label>Kategorie *</Label>
                                    <Select
                                        value={categoryId?.toString() || ""}
                                        onValueChange={(v) => setCategoryId(parseInt(v))}
                                    >
                                        <SelectTrigger>
                                            <SelectValue placeholder="Kategorie wählen" />
                                        </SelectTrigger>
                                        <SelectContent>
                                            {categories.map((cat) => (
                                                <SelectItem key={cat.id} value={cat.id.toString()}>
                                                    {cat.name}
                                                </SelectItem>
                                            ))}
                                        </SelectContent>
                                    </Select>
                                </div>
                                <div>
                                    <Label htmlFor="price">Preis (€) *</Label>
                                    <Input
                                        id="price"
                                        type="number"
                                        min="0"
                                        value={price}
                                        onChange={(e) => setPrice(e.target.value)}
                                        placeholder="0 für 'Projektbasiert'"
                                        required
                                    />
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader>
                            <CardTitle>Features</CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-3">
                            {features.map((feature, index) => (
                                <div key={index} className="flex gap-2">
                                    <Input
                                        value={feature}
                                        onChange={(e) => handleFeatureChange(index, e.target.value)}
                                        placeholder={`Feature ${index + 1}`}
                                    />
                                    <Button
                                        type="button"
                                        variant="outline"
                                        size="icon"
                                        onClick={() => handleRemoveFeature(index)}
                                        disabled={features.length <= 1}
                                    >
                                        <X className="h-4 w-4" />
                                    </Button>
                                </div>
                            ))}
                            <Button
                                type="button"
                                variant="outline"
                                size="sm"
                                onClick={handleAddFeature}
                            >
                                <Plus className="h-4 w-4 mr-1" />
                                Feature hinzufügen
                            </Button>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader>
                            <CardTitle>Detaillierte Beschreibung</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <RichTextEditor
                                value={descriptionPage}
                                onChange={setDescriptionPage}
                                placeholder="Ausführliche Beschreibung der Leistung (unterstützt Markdown und WYSIWYG)"
                            />
                        </CardContent>
                    </Card>

                    <div className="flex justify-end gap-4">
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => navigate("/admin/offerings")}
                        >
                            Abbrechen
                        </Button>
                        <Button type="submit" disabled={saving}>
                            <Save className="h-4 w-4 mr-2" />
                            {saving ? "Speichert..." : "Speichern"}
                        </Button>
                    </div>
                </form>
            </div>
        </div>
    );
}

import { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, Save } from "lucide-react";
import { RichTextEditor } from "./RichTextEditor";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Textarea } from "./ui/textarea";
import { Label } from "./ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import {
    getReferenceById,
    createReference,
    updateReference,
    type ReferenceFormData,
} from "../services/referenceAdminService";

export function ReferenceForm() {
    const navigate = useNavigate();
    const { id } = useParams<{ id: string }>();
    const isEdit = Boolean(id);

    const [loading, setLoading] = useState(isEdit);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState("");

    const [company, setCompany] = useState("");
    const [companyUrl, setCompanyUrl] = useState("");
    const [logoUrl, setLogoUrl] = useState("");
    const [summary, setSummary] = useState("");
    const [story, setStory] = useState("");

    useEffect(() => {
        const loadData = async () => {
            try {
                if (id) {
                    const reference = await getReferenceById(parseInt(id));
                    setCompany(reference.company);
                    setCompanyUrl(reference.company_url);
                    setLogoUrl(reference.logo_url);
                    setSummary(reference.summary);
                    setStory(reference.story);
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

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError("");

        if (!company.trim() || !summary.trim()) {
            setError("Bitte fülle alle Pflichtfelder aus (Firma, Kurzbeschreibung)");
            return;
        }

        setSaving(true);
        try {
            const data: Omit<ReferenceFormData, "id"> = {
                company: company.trim(),
                company_url: companyUrl.trim(),
                logo_url: logoUrl.trim(),
                summary: summary.trim(),
                story: story,
            };

            if (isEdit && id) {
                await updateReference(parseInt(id), data);
            } else {
                await createReference(data);
            }

            navigate("/admin/references");
        } catch (err) {
            setError("Fehler beim Speichern");
            console.error(err);
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center pt-24">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-background px-4 py-6 pt-24">
            <div className="max-w-2xl mx-auto">
                <div className="flex items-center gap-4 mb-6">
                    <Button variant="ghost" size="icon" onClick={() => navigate("/admin/references")}>
                        <ArrowLeft className="h-5 w-5" />
                    </Button>
                    <h1 className="text-2xl font-bold">
                        {isEdit ? "Referenz bearbeiten" : "Neue Referenz erstellen"}
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
                            <div>
                                <Label htmlFor="company">Firma *</Label>
                                <Input
                                    id="company"
                                    value={company}
                                    onChange={(e) => setCompany(e.target.value)}
                                    placeholder="z.B. Beispiel GmbH"
                                    required
                                />
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <Label htmlFor="company_url">Website-URL</Label>
                                    <Input
                                        id="company_url"
                                        type="url"
                                        value={companyUrl}
                                        onChange={(e) => setCompanyUrl(e.target.value)}
                                        placeholder="https://www.beispiel.de"
                                    />
                                </div>
                                <div>
                                    <div>
                                        <Label htmlFor="logo_url">Logo-URL</Label>
                                        <Input
                                            id="logo_url"
                                            type="url"
                                            value={logoUrl}
                                            onChange={(e) => setLogoUrl(e.target.value)}
                                            placeholder="https://www.beispiel.de/logo.png"
                                        />
                                    </div>
                                    {logoUrl.trim() && (
                                        <div className="mt-2 flex items-center gap-2">
                                            <img
                                                src={logoUrl}
                                                alt={company || "Logo Vorschau"}
                                                className="h-8 w-8 object-contain"
                                                onError={(e) => {
                                                    (e.target as HTMLImageElement).style.display = "none";
                                                }}
                                            />
                                            <span className="text-xs text-muted-foreground">Vorschau</span>
                                        </div>
                                    )}
                                </div>
                            </div>

                            <div>
                                <Label htmlFor="summary">Kurzbeschreibung *</Label>
                                <Textarea
                                    id="summary"
                                    value={summary}
                                    onChange={(e) => setSummary(e.target.value)}
                                    placeholder="Kurze Zusammenfassung der Referenz"
                                    maxLength={1024}
                                    required
                                />
                                <p className="text-xs text-muted-foreground mt-1">
                                    {summary.length}/1024 Zeichen
                                </p>
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader>
                            <CardTitle>User-Story</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <RichTextEditor
                                value={story}
                                onChange={setStory}
                                placeholder="Ausführliche User-Story (unterstützt Markdown und WYSIWYG)"
                            />
                        </CardContent>
                    </Card>

                    <div className="flex justify-end gap-4">
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => navigate("/admin/references")}
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

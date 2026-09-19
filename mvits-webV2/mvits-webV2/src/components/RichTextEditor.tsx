import { useRef, useCallback, useState, useEffect } from "react";
import "@toast-ui/editor/dist/toastui-editor.css";
import { Editor } from "@toast-ui/react-editor";
import CodeMirror from "@uiw/react-codemirror";
import { html } from "@codemirror/lang-html";
import DOMPurify from "dompurify";
import { Button } from "./ui/button";

interface RichTextEditorProps {
    value: string;
    onChange: (html: string) => void;
    placeholder?: string;
}

type EditorMode = "wysiwyg" | "markdown" | "html";

function sanitizeForEditor(html: string): string {
    if (!html) return "";
    let cleaned = html
        .replace(/<!(?:DOCTYPE|doctype)\s+[^>]*>/g, "")
        .replace(/<!--[\s\S]*?-->/g, "")
        .replace(/<head[\s\S]*?<\/head>/gi, "")
        .replace(/<\/?(?:html|head|body)(?:\s[^>]*)?>/g, "");
    return DOMPurify.sanitize(cleaned).trim();
}

const modes: { key: EditorMode; label: string }[] = [
    { key: "wysiwyg", label: "WYSIWYG" },
    { key: "markdown", label: "Markdown" },
    { key: "html", label: "HTML" },
];

export function RichTextEditor({ value, onChange, placeholder }: RichTextEditorProps) {
    const editorRef = useRef<Editor>(null);
    const [mode, setMode] = useState<EditorMode>("wysiwyg");
    const [htmlCode, setHtmlCode] = useState("");
    const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

    useEffect(() => {
        return () => {
            if (debounceRef.current) {
                clearTimeout(debounceRef.current);
            }
        };
    }, []);

    const handleChange = useCallback(() => {
        if (editorRef.current) {
            const currentHtml = editorRef.current.getInstance().getHTML();
            onChange(currentHtml);
        }
    }, [onChange]);

    const handleCodeMirrorChange = useCallback(
        (val: string) => {
            setHtmlCode(val);
            if (debounceRef.current) {
                clearTimeout(debounceRef.current);
            }
            debounceRef.current = setTimeout(() => {
                onChange(sanitizeForEditor(val));
            }, 300);
        },
        [onChange]
    );

    const handleModeChange = useCallback(
        (next: EditorMode) => {
            if (next === mode) return;
            const instance = editorRef.current?.getInstance();
            if (!instance) return;

            if (next === "html") {
                setHtmlCode(instance.getHTML());
            } else if (mode === "html") {
                if (debounceRef.current) {
                    clearTimeout(debounceRef.current);
                    debounceRef.current = null;
                }
                const sanitized = sanitizeForEditor(htmlCode);
                try {
                    instance.setHTML(sanitized);
                    instance.changeMode(next);
                } catch {
                    instance.changeMode(next);
                }
                onChange(sanitized);
            } else {
                instance.changeMode(next);
            }
            setMode(next);
        },
        [mode, htmlCode, onChange]
    );

    return (
        <div className="rounded-md border border-input overflow-hidden">
            <div className="flex gap-2 border-b border-input p-2">
                {modes.map((m) => (
                    <Button
                        key={m.key}
                        type="button"
                        size="sm"
                        variant={mode === m.key ? "secondary" : "outline"}
                        onClick={() => handleModeChange(m.key)}
                    >
                        {m.label}
                    </Button>
                ))}
            </div>
            {mode === "html" ? (
                <div className="rounded-md border border-input overflow-hidden">
                    <CodeMirror
                        value={htmlCode}
                        height="400px"
                        theme="light"
                        extensions={[html()]}
                        onChange={handleCodeMirrorChange}
                    />
                </div>
            ) : null}
            <div className={mode === "html" ? "hidden" : undefined}>
                <Editor
                    ref={editorRef}
                    initialValue={sanitizeForEditor(value)}
                    previewStyle="vertical"
                    height="400px"
                    initialEditType="wysiwyg"
                    useCommandShortcut={true}
                    usageStatistics={false}
                    placeholder={placeholder}
                    onChange={handleChange}
                    toolbarItems={[
                        ["heading", "bold", "italic", "strike"],
                        ["hr", "quote"],
                        ["ul", "ol", "task", "indent", "outdent"],
                        ["table", "link"],
                        ["code", "codeblock"],
                    ]}
                />
            </div>
        </div>
    );
}

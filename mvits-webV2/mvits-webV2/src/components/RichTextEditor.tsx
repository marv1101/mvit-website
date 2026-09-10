import { useRef, useCallback } from "react";
import "@toast-ui/editor/dist/toastui-editor.css";
import { Editor } from "@toast-ui/react-editor";

interface RichTextEditorProps {
    value: string;
    onChange: (html: string) => void;
    placeholder?: string;
}

export function RichTextEditor({ value, onChange, placeholder }: RichTextEditorProps) {
    const editorRef = useRef<Editor>(null);

    const handleChange = useCallback(() => {
        if (editorRef.current) {
            const html = editorRef.current.getInstance().getHTML();
            onChange(html);
        }
    }, [onChange]);

    return (
        <div className="rounded-md border border-input overflow-hidden">
            <Editor
                ref={editorRef}
                initialValue={value || ""}
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
    );
}

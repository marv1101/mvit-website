import { useEffect } from "react";
import { useLocation } from "react-router-dom";
import { CONFIG } from "../utils/ConfigLoader";

export function usePageView() {
    const location = useLocation();

    useEffect(() => {
        const trackVisit = async () => {
            try {
                const referrer = document.referrer || undefined;
                await fetch(`${CONFIG.API_BASE_URL}/visits`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        path: location.pathname,
                        referrer,
                    }),
                });
            } catch {
                // Silently fail - tracking should not break the app
            }
        };

        trackVisit();
    }, [location.pathname]);
}

import { CalendarDays, Code, Database, Cloud, DatabaseZap, LucideFilter, MonitorCog, Server, type LucideProps } from 'lucide-react';
import type { ForwardRefExoticComponent, RefAttributes } from 'react';


const iconMap = new Map<string, ForwardRefExoticComponent<Omit<LucideProps, "ref"> & RefAttributes<SVGSVGElement>>>();

function initIconMap() {
    iconMap.set('CalendarDays', CalendarDays);
    iconMap.set('Code', Code);
    iconMap.set('Database', Database);
    iconMap.set('Cloud', Cloud);
    iconMap.set('DatabaseZap', DatabaseZap);
    iconMap.set('LucideFilter', LucideFilter);
    iconMap.set('MonitorCog', MonitorCog);
    iconMap.set('Server', Server);
}

export function getIconByName(name: string) {
    if (iconMap.size === 0) {
        initIconMap();
    }
    return iconMap.get(name);
}
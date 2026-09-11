export type pageVisitObject = {
    id: number;
    visitedAt: Date;
    path: string;
    ipHash: string;
    userAgent: string | null;
    referrer: string | null;
    deviceType: string | null;
};

export type createVisitRequest = {
    path: string;
    referrer?: string;
};

export type visitStats = {
    total: number;
    today: number;
    thisWeek: number;
    thisMonth: number;
};

export type dailyVisits = {
    date: string;
    count: number;
};

export type pageCount = {
    path: string;
    count: number;
};

export type referrerCount = {
    referrer: string;
    count: number;
};

export type deviceCount = {
    deviceType: string;
    count: number;
};

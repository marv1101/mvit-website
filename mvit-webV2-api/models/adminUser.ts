export type adminUserObject = {
    id: number;
    username: string;
    passwordHash: string;
    createdAt: Date;
};

export type loginRequest = {
    username: string;
    password: string;
};

export type registerRequest = {
    username: string;
    password: string;
};

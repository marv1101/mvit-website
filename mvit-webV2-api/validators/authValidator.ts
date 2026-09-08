import { loginRequest, registerRequest } from "../models/adminUser.js";

const USERNAME_REGEX = "^[a-zA-Z0-9_]{3,50}$";
const MIN_PASSWORD_LENGTH = 8;

export function validateLoginRequest(data: loginRequest): loginRequest | null {
    if (!data.username || !data.password) {
        return null;
    }
    if (!data.username.match(new RegExp(USERNAME_REGEX))) {
        return null;
    }
    if (data.password.length < MIN_PASSWORD_LENGTH) {
        return null;
    }
    return data;
}

export function validateRegisterRequest(data: registerRequest): registerRequest | null {
    if (!data.username || !data.password) {
        return null;
    }
    if (!data.username.match(new RegExp(USERNAME_REGEX))) {
        return null;
    }
    if (data.password.length < MIN_PASSWORD_LENGTH) {
        return null;
    }
    return data;
}

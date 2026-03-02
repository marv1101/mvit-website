# Project Style Guide

This document outlines naming conventions and directory structure guidelines for the **mvit website** repositories. It should serve as a reference for contributors to ensure consistent organization and readability.

---

## 1. Repository Overview

The workspace currently contains two primary sub-projects:

1. `mvit-webV2-api` – Node/Express backend written in TypeScript.
2. `mvits-webV2` – Frontend application (React + Bun/TypeScript).

Each project has its own conventions described below. Keeping them aligned improves maintainability.

---

## 2. General Conventions

- **Case style**: Prefer `camelCase` for filenames and folders, except for React component files, which use `PascalCase`.
- **Extensions**: Use `.ts` for TypeScript files, `.tsx` for files containing JSX/TSX.
- **Imports**: Use relative paths within a package; keep them clean by avoiding deeply nested references when possible (consider `index.ts` exports).
- **Configuration**: Configuration files (`tsconfig.json`, `package.json`, `.env`, etc.) remain at the project root.

---

## 3. Backend (`mvit-webV2-api`)

### 📁 Folder names

- `bin/` – executable entry points (e.g. `www.ts`).
- `db/` – database connection logic and schema.
- `middlewares/` – Express middleware modules.
- `models/` – data-access or ORM models.
- `routes/` – Express route handlers.
- `services/` – business logic separated from controllers.
- `public/` – static assets served by Express.

These names reflect typical Express project structures.

### 📄 File names

- Use `camelCase` for most files: `userController.ts`, `offeringsService.ts`, etc.
- Keep route files named after their resource: `offerings.ts`, `users.ts`.
- For a group of exports, consider `index.ts` inside the directory (e.g., `services/index.ts`).

> 🔁 **Renaming note**: the codebase currently uses camelCase throughout (e.g. `offeringService.ts`). Keep filenames in camelCase and update imports as needed.

### 🧩 Special files

- `db/schema.ts` defines the database schema. You can also use `db/index.ts` if you export additional helpers from the same folder.

---

## 4. Frontend (`mvits-webV2`)

### 🗂 Directory structure

The existing structure contains a redundant nested folder: `mvits-webV2/mvits-webV2`. For clarity, consider flattening such that the inner folder becomes the project root (rename top-level to `frontend/` or `client/`). Example:

```
frontend/          # formerly mvits-webV2/mvits-webV2
  package.json
  tsconfig.json
  src/
    components/
    styles/
    ...
```

### 🧱 Component files

- React components: `PascalCase` (e.g. `HomePage.tsx`, `Navigation.tsx`).
- Non-component utilities or hooks: `camelCase` or `kebab-case` (e.g. `useMobile.ts`, `utils.ts`).

### 🌐 Static resources

- `res/` or `public/` for images, icons, and manifests.
- `styles/` for global and utility CSS.

---

## 5. Migration & Refactor Tips

1. **Plan renames**: Use IDE support (VS Code rename) or `git mv` to maintain history.
2. **Update imports**: After renaming, search/replace across the repo for old filenames.
3. **Run tests/dev servers**: Ensure nothing breaks after renaming.
4. **Document changes**: Add a note to `CHANGELOG.md` (if you maintain one) when restructuring.

---

## 6. Additional Notes

- Add new conventions here as the project evolves (e.g. state management, testing files, naming for hooks).
- If adding tooling (ESLint, Prettier), enforce naming rules via linting plugins.

> 📌 *This style guide is a living document. Feel free to propose updates via pull requests.*

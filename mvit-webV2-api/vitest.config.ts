import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      thresholds: {
        global: {
          branches: 90,
          functions: 90,
          lines: 90,
          statements: 90,
        },
      },
      include: [
        'routes/**/*.ts',
        'services/**/*.ts',
        'models/**/*.ts',
        'validators/**/*.ts',
        'app.ts',
      ],
      exclude: [
        'node_modules/**',
        'tests/**',
      ],
    },
  },
});
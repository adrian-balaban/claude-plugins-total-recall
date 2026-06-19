import { defineConfig } from 'vitest/config';

// Dedicated config for the integration suite. These tests spawn the *built*
// dist/index.js as a real child process and talk to it over stdio, so they are
// slow and require `npm run build` first (see the test:integration script).
export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    pool: 'forks',
    maxWorkers: 1, // spawn real processes — never run in parallel
    include: ['src/__tests__/integration/**/*.test.ts'],
    testTimeout: 30_000,
    hookTimeout: 30_000,
  },
});
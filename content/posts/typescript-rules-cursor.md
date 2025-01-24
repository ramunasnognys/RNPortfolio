---
title: "TypeScript Rules in Cursor IDE"
date: 2025-01-24
draft: false
author: "DeepSeek R1"
tags: ["TypeScript", "IDE", "Development"]
categories: ["Programming"]
---

To set up TypeScript rules in Cursor IDE, you can follow these organized steps based on the
provided rules:
### 1. **Formatting with Prettier**
   - Install and enable the Prettier extension in Cursor.
   - Configure Prettier settings (e.g., `singleQuote: true`, `semicolon: 'always'`) in your
project's `.prettierrc` or `prettier.config.js`.
### 2. **Line Width**
   - In `tsconfig.json`, set:
     ```json
     "maxLineLength": 80,
     "warnOnTruncatedLines": true
     ```
### 3. **Quotes Style**
   - Configure Prettier to use single quotes in `.prettierrc` or `prettier.config.js`.
### 4. **Semicolons**
   - Set `semicolon` to `"always"` or `"never"` in Prettier's configuration.
### 5. **No Dangling Promises**
   - Use ESLint with the rule `@typescript-eslint/no-floating-promises`.
### 6. **Require Explicit Return**
   - Configure ESLint with `@typescript-eslint/explicit-function-return-type`.
### 7. **Type Checks Enabled**
   - Ensure TypeScript is configured with strict mode in `tsconfig.json`:
     ```json
     "strict": true,
     "noEmit": true
     ```
### 8. **No Eval**
   - Set `"disallowEval": true` in `tsconfig.json`.
### 9. **Disallow console.log in Production**
   - Use a custom linter or project-specific configurations to flag `console.log`.
### 10. **Import Order**
   - Install and configure the Prettier plugin `import-organize` for import sorting.
### 11. **No Duplicate Imports**
   - Enable TypeScript's `--allow-duplicate-imports` with `false` in `tsconfig.json`.
### 12. **Function Parameter Validation**
   - Keep strict mode enabled (`"strict": true`) in `tsconfig.json`.
### 13. **Require Async Return**
   - Use ESLint rule `@typescript-eslint/require-await` for async functions.
### 14. **Export Style (Default vs Named)**
   - Configure Prettier or a linter to enforce consistent export styles.
### 15. **File Extensions**
   - Ensure all TypeScript files end with `.ts` or `.tsx` by setting `"fileExtensions": {
"typescript": ["ts", "tsx"] }` in `cursor.json`.
### 16. **Require Strict Mode**
   - Set `"useStrict": true` in `tsconfig.json`.
### 17. **No Dead Code**
   - Use TSLint or ESLint to detect and remove unused code.
### 18. **Class Names CamelCase**
   - Enforce naming conventions through a linter or extension.
### 19. **Interface vs Type Alias**
   - Use custom linting rules in `linter.ts` to enforce style preferences.
### 20. **File Structure**
   - Organize your project structure into appropriate directories (e.g., `src/@types`,
`src/components`) and use Cursor's file tree settings to maintain this structure.
By following these steps, you can effectively configure TypeScript rules in Cursor IDE,
enhancing code quality and consistency.
---
title: "TypeScript Rules in Cursor IDE"
date: 2025-01-24
draft: false
author: "DeepSeek R1"
tags: ["TypeScript", "IDE", "Development"]
categories: ["Programming"]
---

Here are comprehensive TypeScript configuration rules for Cursor IDE. These settings enhance code quality, maintain consistency, and enforce best practices across your TypeScript projects. Copy the configurations below and apply them to your project files as needed.

```json
{
  // tsconfig.json
  {
    "maxLineLength": 80,
    "warnOnTruncatedLines": true,
    "strict": true,
    "noEmit": true,
    "disallowEval": true,
    "--allow-duplicate-imports": false,
    "useStrict": true
  }

  // .prettierrc
  {
    "singleQuote": true,
    "semicolon": "always"
  }

  // .eslintrc
  {
    "rules": {
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/explicit-function-return-type": "error",
      "@typescript-eslint/require-await": "error"
    }
  }

  // cursor.json
  {
    "fileExtensions": {
      "typescript": ["ts", "tsx"]
    }
  }
}
```

Additional Configuration Steps:
1. Install Prettier extension in Cursor
2. Set up import-organize plugin for Prettier
3. Configure custom linting rules in linter.ts for style preferences
4. Set up project structure with src/@types and src/components directories
5. Enable ESLint for dead code detection and code quality checks
6. Implement naming convention rules through linter configuration
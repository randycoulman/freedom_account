module.exports = {
  env: {
    browser: true,
    es6: true,
    es2021: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:cypress/recommended",
    "plugin:eslint-comments/recommended",
    "plugin:import/recommended",
    "prettier",
  ],
  globals: {},
  parser: "@babel/eslint-parser",
  parserOptions: {
    ecmaVersion: 2021,
    requireConfigFile: false,
    sourceType: "module",
  },
  plugins: [
    "chai-friendly",
    "cypress",
    "eslint-comments",
    "import",
    // "import-helpers",
  ],
  root: true,
  rules: {
    "accessor-pairs": "warn",
    "block-scoped-var": "warn",
    camelcase: "warn",
    // "chai-friendly/no-unused-expressions": [
    //   "warn",
    //   {
    //     allowShortCircuit: true,
    //     allowTernary: true,
    //   },
    // ],
    complexity: ["warn", 5],
    "consistent-return": "warn",
    "consistent-this": ["warn", "self"],
    "default-case": "warn",
    "dot-notation": "warn",
    eqeqeq: ["warn", "smart"],
    "func-name-matching": "warn",
    "func-names": "off",
    "func-style": ["warn", "declaration", { allowArrowFunctions: true }],
    "guard-for-in": "warn",
    "import/dynamic-import-chunkname": "warn",
    "import/extensions": ["warn", "never"],
    "import/first": "warn",
    "import/newline-after-import": "warn",
    "import/no-absolute-path": "warn",
    "import/no-cycle": "warn",
    "import/no-deprecated": "warn",
    "import/no-dynamic-require": "warn",
    "import/no-extraneous-dependencies": "warn",
    "import/no-mutable-exports": "warn",
    "import/no-named-default": "warn",
    "import/no-self-import": "warn",
    "import/no-useless-path-segments": "warn",
    "import/order": [
      "warn",
      {
        alphabetize: { order: "asc" },
        groups: [
          ["builtin", "external"],
          "internal",
          "parent",
          ["sibling", "index"],
        ],
        "newlines-between": "always",
      },
    ],
    // "import-helpers/order-imports": [
    //   "warn",
    //   {
    //     alphabetize: { order: "asc" },
    //     groups: [
    //       ["builtin", "external"],
    //       "internal",
    //       "parent",
    //       ["sibling", "index"],
    //     ],
    //     "newlines-between": "always",
    //   },
    // ],
    "init-declarations": "warn",
    "lines-between-class-members": [
      "warn",
      "always",
      {
        exceptAfterSingleLine: true,
      },
    ],
    "max-depth": "warn",
    "max-nested-callbacks": "off",
    "max-params": ["warn", 4],
    "max-statements": "off",
    "new-cap": "warn",
    "no-alert": "warn",
    "no-await-in-loop": "warn",
    "no-bitwise": "warn",
    "no-console": "warn",
    "no-continue": "warn",
    "no-debugger": "warn",
    "no-div-regex": "warn",
    "no-else-return": "warn",
    "no-empty-function": "warn",
    "no-implicit-coercion": "warn",
    "no-implicit-globals": "warn",
    "no-inner-declarations": ["warn", "both"],
    "no-lonely-if": "warn",
    "no-multi-str": "warn",
    "no-negated-condition": "warn",
    "no-nested-ternary": "warn",
    "no-new": "warn",
    "no-param-reassign": "warn",
    "no-proto": "warn",
    "no-return-assign": "warn",
    "no-return-await": "warn",
    "no-shadow": "warn",
    "no-undef-init": "warn",
    "no-unmodified-loop-condition": "warn",
    "no-unneeded-ternary": "warn",
    "no-unreachable": "warn",
    "no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    "no-use-before-define": ["warn", "nofunc"],
    "no-useless-call": "warn",
    "no-useless-return": "warn",
    "no-var": "warn",
    "no-void": "warn",
    "no-warning-comments": "warn",
    "object-shorthand": "warn",
    "one-var": ["warn", "never"],
    "operator-assignment": ["warn", "always"],
    "padding-line-between-statements": [
      "warn",
      { blankLine: "always", next: "*", prev: ["const", "let", "var"] },
      {
        blankLine: "any",
        next: ["const", "let", "var"],
        prev: ["const", "let", "var"],
      },
      { blankLine: "always", next: "*", prev: "directive" },
      { blankLine: "any", next: "directive", prev: "directive" },
    ],
    "prefer-const": "warn",
    "prefer-destructuring": "warn",
    "prefer-named-capture-group": "warn",
    "prefer-numeric-literals": "warn",
    "prefer-object-spread": "warn",
    "prefer-rest-params": "warn",
    "prefer-spread": "warn",
    "prefer-template": "warn",
    radix: "warn",
    "require-atomic-updates": "warn",
    "require-await": "warn",
    "sort-keys": ["warn", "asc", { natural: true }],
    "sort-vars": "warn",
    "spaced-comment": "warn",
    strict: ["warn", "never"],
    "symbol-description": "warn",
    "vars-on-top": "warn",
    yoda: "warn",
  },
};

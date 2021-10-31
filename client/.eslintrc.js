module.exports = {
  env: {
    es2021: true,
  },
  extends: [
    "react-app",
    "react-app/jest",
    "eslint:recommended",
    "plugin:eslint-comments/recommended",
    "plugin:import/recommended",
    "plugin:import/typescript",
    "plugin:jest/recommended",
    "plugin:jest/style",
    "plugin:jsx-a11y/recommended",
    "plugin:ramda/recommended",
    "plugin:react/recommended",
    "plugin:react/jsx-runtime",
    "prettier",
  ],
  overrides: [
    {
      files: ["**/__tests__/**/*", "**/*.(spec|test).*"],
      rules: {
        "func-names": "off",
        "jest/consistent-test-it": "warn",
        //       "jest/expect-expect": [
        //         "warn",
        //         { assertFunctionNames: ["expect", "td.verify"] },
        //       ],
        "jest/lowercase-name": ["warn", { ignore: ["describe"] }],
        "jest/no-focused-tests": "warn",
        "jest/no-large-snapshots": "warn",
        "jest/no-restricted-matchers": [
          "error",
          {
            toBeFalsy: null,
            toBeTruthy: null,
          },
        ],
        "jest/no-test-return-statement": "warn",
        "jest/prefer-called-with": "warn",
        "jest/prefer-spy-on": "warn",
        "jest/prefer-strict-equal": "warn",
        "jest/prefer-todo": "warn",
        "jest/require-to-throw-message": "warn",
        "max-nested-callbacks": "off",
        "max-statements": "off",
      },
    },
  ],
  parserOptions: {
    ecmaVersion: 2021,
  },
  plugins: [
    "eslint-comments",
    //   "import-helpers",
    "ramda",
  ],
  root: true,
  rules: {
    "accessor-pairs": "warn",
    "block-scoped-var": "warn",
    camelcase: "warn",
    complexity: ["warn", 5],
    "consistent-return": "warn",
    "consistent-this": ["warn", "self"],
    "dot-notation": "warn",
    "func-name-matching": "warn",
    "func-names": "warn",
    "func-style": ["warn", "declaration", { allowArrowFunctions: true }],
    "guard-for-in": "warn",
    "import/dynamic-import-chunkname": "warn",
    "import/extensions": ["warn", "never"],
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
    //   "import-helpers/order-imports": [
    //     "warn",
    //     {
    //       alphabetize: { order: "asc" },
    //       groups: [
    //         "module",
    //         "parent",
    //         ["sibling", "index"],
    //       ],
    //       "newlinesBetween": "always",
    //     },
    //   ],
    "init-declarations": "warn",
    "lines-between-class-members": [
      "warn",
      "always",
      {
        exceptAfterSingleLine: true,
      },
    ],
    "max-depth": "warn",
    "max-nested-callbacks": ["warn", 3],
    "max-params": ["warn", 4],
    "max-statements": "warn",
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
    "ramda/always-simplification": "warn",
    "ramda/compose-simplification": "warn",
    "ramda/eq-by-simplification": "warn",
    "ramda/pipe-simplification": "warn",
    "ramda/prefer-complement": "warn",
    "react/button-has-type": "warn",
    "react/default-props-match-prop-types": "warn",
    "react/destructuring-assignment": "warn",
    "react/forbid-prop-types": "warn",
    "react/jsx-boolean-value": "warn",
    "react/jsx-curly-brace-presence": ["warn", "never"],
    "react/jsx-fragments": ["warn", "syntax"],
    "react/jsx-handler-names": "warn",
    "react/jsx-sort-default-props": "warn",
    "react/jsx-sort-props": ["warn", { ignoreCase: true }],
    "react/no-access-state-in-setstate": "warn",
    "react/no-array-index-key": "warn",
    "react/no-danger": "warn",
    "react/no-did-mount-set-state": "warn",
    "react/no-did-update-set-state": "warn",
    "react/no-redundant-should-component-update": "warn",
    "react/no-this-in-sfc": "warn",
    "react/no-unsafe": "warn",
    "react/no-unused-prop-types": "warn",
    "react/no-unused-state": "warn",
    "react/no-will-update-set-state": "warn",
    "react/prefer-es6-class": "warn",
    "react/prefer-stateless-function": "warn",
    "react/prop-types": "warn",
    "react/require-default-props": "warn",
    "react/sort-comp": "warn",
    "react/sort-prop-types": ["warn", { sortShapeProp: true }],
    "react/void-dom-elements-no-children": "warn",
    "require-atomic-updates": "warn",
    "require-await": "warn",
    "sort-keys": ["warn", "asc", { natural: true }],
    "sort-vars": "warn",
    "spaced-comment": ["warn", "always", { markers: ["/"] }],
    strict: ["warn", "never"],
    "symbol-description": "warn",
    "vars-on-top": "warn",
    yoda: "warn",
  },
  settings: {
    //   "import/ignore": ["node_modules", ".(css|png|jpg|svg)$"],
    jest: { version: 26 },
  },
};

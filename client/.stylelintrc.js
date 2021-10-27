module.exports = {
  defaultSeverity: "warning",
  extends: ["stylelint-config-standard", "stylelint-config-prettier"],
  plugins: ["stylelint-order"],
  rules: {
    "at-rule-no-vendor-prefix": true,
    "color-named": "never",
    "color-no-hex": true,
    "declaration-block-no-redundant-longhand-properties": true,
    "declaration-no-important": true,
    "font-family-name-quotes": "always-unless-keyword",
    "function-url-no-scheme-relative": true,
    "media-feature-name-no-vendor-prefix": true,
    "no-empty-first-line": true,
    "no-unknown-animations": true,
    "order/order": ["custom-properties", "declarations", "rules"],
    "order/properties-alphabetical-order": true,
    "property-no-unknown": [true, { ignoreProperties: ["composes"] }],
    "property-no-vendor-prefix": true,
    "selector-no-vendor-prefix": true,
    "shorthand-property-no-redundant-values": true,
    "value-keyword-case": "lower",
    "value-no-vendor-prefix": true,
  },
};

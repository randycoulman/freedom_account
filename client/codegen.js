module.exports = {
  config: {
    gqlImport: "urql#gql",
  },
  documents: "src/**/*.tsx",
  generates: {
    "src/graphql.ts": {
      plugins: ["typescript", "typescript-operations", "typescript-urql"],
    },
  },
  hooks: {
    afterOneFileWrite: ["eslint --fix", "prettier --write"],
  },
  overwrite: true,
  schema: "http://localhost:4000/api",
};

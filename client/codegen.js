module.exports = {
  documents: "src/**/*.tsx",
  generates: {
    "src/graphql.ts": {
      plugins: ["typescript", "typescript-operations", "typescript-urql"],
    },
  },
  hooks: {
    afterOneFileWrite: ["eslint --fix", "prettier --write"],
  },
  options: {
    gqlImport: "urql#gql",
  },
  overwrite: true,
  schema: "http://localhost:4000/api",
};

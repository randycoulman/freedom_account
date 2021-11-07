module.exports = {
  documents: "src/**/*.tsx",
  generates: {
    "src/graphql.ts": {
      plugins: [
        "typescript",
        "typescript-operations",
        {
          "typescript-urql": {
            gqlImport: "urql#gql",
          },
        },
      ],
    },
  },
  hooks: {
    afterOneFileWrite: ["eslint --fix", "prettier --write"],
  },
  overwrite: true,
  schema: "http://localhost:4000/api",
};

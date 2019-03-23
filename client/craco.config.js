const { ESLINT_MODES } = require("@craco/craco");

module.exports = {
  eslint: {
    loaderOptions: eslintOptions => ({
      ...eslintOptions,
      eslintPath: require.resolve("eslint"),
    }),
    mode: ESLINT_MODES.file,
  },
};

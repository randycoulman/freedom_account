const { ESLINT_MODES } = require("@craco/craco");
const StylelintBarePlugin = require("stylelint-bare-webpack-plugin");

module.exports = {
  eslint: {
    loaderOptions: eslintOptions => ({
      ...eslintOptions,
      eslintPath: require.resolve("eslint"),
    }),
    mode: ESLINT_MODES.file,
  },
  webpack: {
    plugins: [
      new StylelintBarePlugin({
        configFile: ".stylelintrc.js",
        files: "**/*.{css,scss}",
      }),
    ],
  },
};

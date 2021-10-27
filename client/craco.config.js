const StylelintBarePlugin = require("stylelint-bare-webpack-plugin");

module.exports = {
  webpack: {
    plugins: {
      add: [
        new StylelintBarePlugin({
          files: "**/*.css",
        }),
      ],
    },
  },
};

const base = require("./codegen");

module.exports = {
  ...base,
  watch: [
    "src/**/*.tsx",
    "../server/lib/freedom_account_web/schema.ex",
    "../server/lib/freedom_account_web/schema/**/*.ex",
  ],
};

import { devtoolsExchange } from "@urql/devtools";
import { createClient, defaultExchanges } from "urql";

export const client = createClient({
  exchanges: [devtoolsExchange, ...defaultExchanges],
  suspense: true,
  url: "/api",
});

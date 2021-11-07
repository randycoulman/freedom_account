import { createClient } from "urql";

export const client = createClient({
  suspense: true,
  url: "/graphql",
});

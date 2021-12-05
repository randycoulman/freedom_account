import { devtoolsExchange } from "@urql/devtools";
import { createContext, ReactNode, useContext, useState } from "react";
import { Provider, createClient, defaultExchanges } from "urql";

const makeClient = () =>
  createClient({
    exchanges: [devtoolsExchange, ...defaultExchanges],
    suspense: true,
    url: "/api",
  });

type ClientState = {
  resetClient: () => void;
};

const ClientContext = createContext<ClientState>({
  resetClient: () => {},
});

type Props = {
  children: ReactNode;
};

export const ClientProvider = ({ children }: Props) => {
  const [client, setClient] = useState(makeClient());
  const resetClient = () => setClient(makeClient());

  return (
    <ClientContext.Provider value={{ resetClient }}>
      <Provider value={client}>{children}</Provider>
    </ClientContext.Provider>
  );
};

export const useClient = () => useContext(ClientContext);

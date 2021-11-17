import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";
import { BrowserRouter, Route, Switch } from "react-router-dom";
import { Provider } from "urql";

import { Account } from "./Account";
import styles from "./App.module.css";
import { ErrorFallback } from "./ErrorFallback";
import { Loader } from "./Loader";
import { client } from "./client";

export const App = () => {
  return (
    <Provider value={client}>
      <header className={styles.header}>
        <h1>Freedom Account</h1>
      </header>
      <main>
        <ErrorBoundary FallbackComponent={ErrorFallback}>
          <Suspense fallback={<Loader />}>
            <BrowserRouter>
              <Switch>
                <Route path="/">
                  <Account />
                </Route>
              </Switch>
            </BrowserRouter>
          </Suspense>
        </ErrorBoundary>
      </main>
    </Provider>
  );
};

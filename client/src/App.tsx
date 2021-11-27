import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";
import { BrowserRouter, Route, Switch } from "react-router-dom";
import { Provider } from "urql";

import { Account } from "./Account";
import styles from "./App.module.css";
import { ErrorFallback } from "./ErrorFallback";
import { Loader } from "./Loader";
import { Login } from "./Login";
import { NoMatch } from "./NoMatch";
import { client } from "./client";

export const App = () => {
  return (
    <Provider value={client}>
      <header className={styles.header}>
        <h1>Freedom Account</h1>
      </header>
      <main>
        <BrowserRouter>
          <ErrorBoundary FallbackComponent={ErrorFallback}>
            <Suspense fallback={<Loader />}>
              <Switch>
                <Route path="/login">
                  <Login />
                </Route>
                <Route exact path="/">
                  <Account />
                </Route>
                <Route>
                  <NoMatch />
                </Route>
              </Switch>
            </Suspense>
          </ErrorBoundary>
        </BrowserRouter>
      </main>
    </Provider>
  );
};

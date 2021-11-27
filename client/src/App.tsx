import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";
import { BrowserRouter, Route, Switch } from "react-router-dom";

import { Account } from "./Account";
import styles from "./App.module.css";
import { ErrorFallback } from "./ErrorFallback";
import { Loader } from "./Loader";
import { Login } from "./Login";
import { LogoutButton } from "./LogoutButton";
import { NoMatch } from "./NoMatch";
import { ClientProvider } from "./client";

export const App = () => {
  return (
    <BrowserRouter>
      <ClientProvider>
        <header className={styles.header}>
          <h1>Freedom Account</h1>
          <LogoutButton />
        </header>
        <main>
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
        </main>
      </ClientProvider>
    </BrowserRouter>
  );
};

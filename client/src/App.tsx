import { Provider } from "urql";

import styles from "./App.module.css";
import Root from "./Root";
import { client } from "./client";

const App = () => {
  return (
    <Provider value={client}>
      <div>
        <header className={styles.header}>
          <h1>Freedom Account</h1>
        </header>
        <main>
          <Root />
        </main>
      </div>
    </Provider>
  );
};

export default App;

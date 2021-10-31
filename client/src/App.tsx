import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch,
} from "react-router-dom";

import styles from "./App.module.css";
import FundList from "./FundList";

const App = () => {
  return (
    <Router>
      <div>
        <header className={styles.header}>
          <h1>Freedom Account</h1>
        </header>
        <main>
          <Switch>
            <Route path="/funds">
              <FundList />
            </Route>
          </Switch>
          <Redirect to="/funds" />
        </main>
      </div>
    </Router>
  );
};

export default App;

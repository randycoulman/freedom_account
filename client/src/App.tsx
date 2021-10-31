import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch,
} from "react-router-dom";

import "./App.module.css";

const App = () => {
  return (
    <Router>
      <div className="container">
        <header>
          <h1>Freedom Account</h1>
        </header>
        <main>
          <Switch>
            <Route path="/funds">
              <h2>Funds</h2>
            </Route>
          </Switch>
          <Redirect to="/funds" />
        </main>
      </div>
    </Router>
  );
};

export default App;

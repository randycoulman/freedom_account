import { useErrorHandler } from "react-error-boundary";
import { useHistory, useLocation } from "react-router-dom";
import { gql } from "urql";

import { LoginForm } from "./LoginForm";
import { useLoginMutation } from "./graphql";

interface LocationState {
  from?: string;
}

export const Login = () => {
  const [result, login] = useLoginMutation();
  const location = useLocation<LocationState>();
  const history = useHistory();
  const path = location.state?.from || "/";

  useErrorHandler(result.error);

  const onSubmit = async (username: string) => {
    await login({ username });
    history.replace(path);
  };

  return (
    <>
      <h2>Login</h2>
      <LoginForm onSubmit={onSubmit} />
    </>
  );
};

export const LoginMutation = gql`
  mutation Login($username: String!) {
    login(username: $username) {
      id
    }
  }
`;

import { useErrorHandler } from "react-error-boundary";
import { useHistory } from "react-router-dom";
import { gql } from "urql";

import { useClient } from "./client";
import { useLogoutMutation } from "./graphql";

export const LogoutButton = () => {
  const [result, logout] = useLogoutMutation();
  const history = useHistory();
  const { resetClient } = useClient();

  useErrorHandler(result.error);

  const onClick = async () => {
    await logout();
    history.push("/login");
    resetClient();
  };

  return (
    <button onClick={onClick} type="button">
      Logout
    </button>
  );
};

export const LogoutMutation = gql`
  mutation Logout {
    logout
  }
`;

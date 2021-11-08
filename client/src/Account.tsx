import { useErrorHandler } from "react-error-boundary";
import { gql } from "urql";

import { FundList } from "./FundList";
import { useMyAccountQuery } from "./graphql";

export const Account = () => {
  const [{ data, error }] = useMyAccountQuery();

  useErrorHandler(error);

  const { funds, name } = data!.myAccount;

  return (
    <>
      <section>
        <h2>{name}</h2>
      </section>
      <article>
        <h3>Funds</h3>
        <FundList funds={funds} />
      </article>
    </>
  );
};

export const AccountQuery = gql`
  query MyAccount {
    myAccount {
      ...AccountFunds
      name
    }
  }

  ${FundList.fragments.funds}
`;

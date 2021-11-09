import { useErrorHandler } from "react-error-boundary";
import { gql } from "urql";

import { AccountHeader } from "./AccountHeader";
import { FundList } from "./FundList";
import { useMyAccountQuery } from "./graphql";

export const Account = () => {
  const [{ data, error }] = useMyAccountQuery();

  useErrorHandler(error);

  const account = data!.myAccount;

  return (
    <>
      <section>
        <AccountHeader account={account} />
      </section>
      <article>
        <h3>Funds</h3>
        <FundList funds={account.funds} />
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

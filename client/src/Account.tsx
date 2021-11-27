import { useErrorHandler } from "react-error-boundary";
import { gql } from "urql";

import { AccountHeader } from "./AccountHeader";
import { FundList } from "./FundList";
import {
  AccountInput,
  useMyAccountQuery,
  useUpdateAccountMutation,
} from "./graphql";

export const Account = () => {
  const [queryResult] = useMyAccountQuery();
  const [mutationResult, updateAccount] = useUpdateAccountMutation();

  useErrorHandler(queryResult.error);
  useErrorHandler(mutationResult.error);

  const account = queryResult.data!.myAccount;
  const onUpdate = (input: AccountInput) => updateAccount({ input });

  return (
    <>
      <section>
        <AccountHeader account={account} onUpdate={onUpdate} />
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
      ...AccountFields
      ...AccountFunds
    }
  }

  ${AccountHeader.fragments.account}
  ${FundList.fragments.funds}
`;

export const UpdateAccountMutation = gql`
  mutation UpdateAccount($input: AccountInput!) {
    updateAccount(input: $input) {
      ...AccountFields
    }
  }

  ${AccountHeader.fragments.account}
`;

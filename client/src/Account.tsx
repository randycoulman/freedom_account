import { useErrorHandler } from "react-error-boundary";
import { gql } from "urql";

import { AccountHeader } from "./AccountHeader";
import { FundList } from "./FundList";
import {
  AccountInput,
  FundInput,
  useCreateFundMutation,
  useMyAccountQuery,
  useUpdateAccountMutation,
} from "./graphql";

const queryContext = { additionalTypenames: ["Fund"] };

export const Account = () => {
  const [queryResult] = useMyAccountQuery({ context: queryContext });
  const [updateAccountResult, updateAccount] = useUpdateAccountMutation();
  const [createFundResult, createFund] = useCreateFundMutation();

  useErrorHandler(queryResult.error);
  useErrorHandler(updateAccountResult.error);
  useErrorHandler(createFundResult.error);

  const account = queryResult.data!.myAccount;
  const onUpdate = (input: AccountInput) => updateAccount({ input });
  const onAddFund = (input: FundInput) =>
    createFund({ accountId: account.id, input });

  return (
    <>
      <section>
        <AccountHeader account={account} onUpdate={onUpdate} />
      </section>
      <article>
        <h3>Funds</h3>
        <FundList funds={account.funds} onAddFund={onAddFund} />
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

export const CreateFundMutation = gql`
  mutation CreateFund($accountId: ID!, $input: FundInput!) {
    createFund(accountId: $accountId, input: $input) {
      ...FundFields
    }
  }

  ${FundList.fragments.fund}
`;

export const UpdateAccountMutation = gql`
  mutation UpdateAccount($input: AccountInput!) {
    updateAccount(input: $input) {
      ...AccountFields
    }
  }

  ${AccountHeader.fragments.account}
`;

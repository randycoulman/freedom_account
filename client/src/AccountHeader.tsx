import { useState } from "react";
import { gql } from "urql";

import { AccountEditForm } from "./AccountEditForm";
import { Account, AccountInput } from "./graphql";

export type Props = {
  account: Account;
  onUpdate?: (_values: AccountInput) => void;
};

const defaultOnUpdate = (_values: AccountInput) => {
  /* noop */
};

export const AccountHeader = ({
  account,
  onUpdate = defaultOnUpdate,
}: Props) => {
  const [isEditing, beEditing] = useState(false);
  const handleUpdate = (values: AccountInput) => {
    onUpdate(values);
    beEditing(false);
  };

  return (
    <>
      <h2>{account.name}</h2>
      {isEditing ? (
        <>
          <h3>Account Settings</h3>
          <AccountEditForm
            account={account}
            onCancel={() => beEditing(false)}
            onUpdate={handleUpdate}
          />
        </>
      ) : (
        <button onClick={() => beEditing(true)} type="button">
          Edit
        </button>
      )}
    </>
  );
};

AccountHeader.fragments = {
  account: gql`
    fragment AccountFields on Account {
      depositsPerYear
      id
      name
    }
  `,
};
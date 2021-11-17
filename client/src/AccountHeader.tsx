import { useState } from "react";
import { gql } from "urql";

import { AccountEditForm } from "./AccountEditForm";
import { Account, AccountInput } from "./graphql";

export type Props = {
  account: Account;
  onUpdate: (_values: AccountInput) => void;
};

export const AccountHeader = ({ account, onUpdate }: Props) => {
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

AccountHeader.defaultProps = {
  onUpdate: (_values: AccountInput) => {
    /* noop */
  },
};

AccountHeader.fragments = {
  account: gql`
    fragment AccountFields on Account {
      id
      name
    }
  `,
};

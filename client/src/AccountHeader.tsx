import { useState } from "react";

import { AccountEditForm } from "./AccountEditForm";
import { Account } from "./graphql";

export type Props = {
  account: Account;
  onUpdate: (_values: Partial<Account>) => void;
};

export const AccountHeader = ({ account, onUpdate }: Props) => {
  const [isEditing, beEditing] = useState(false);
  const handleUpdate = (values: Partial<Account>) => {
    onUpdate(values);
    beEditing(false);
  };

  return isEditing ? (
    <AccountEditForm
      account={account}
      onCancel={() => beEditing(false)}
      onUpdate={handleUpdate}
    />
  ) : (
    <>
      <h2>{account.name}</h2>
      <button onClick={() => beEditing(true)} type="button">
        Edit
      </button>
    </>
  );
};

AccountHeader.defaultProps = {
  onUpdate: (_values: Partial<Account>) => {
    /* noop */
  },
};

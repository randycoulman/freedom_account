import { assoc, pick } from "ramda";
import { ChangeEvent, FormEvent, useState } from "react";

import { Account } from "./graphql";

type Props = {
  account: Account;
  onCancel: () => void;
  onUpdate: (_values: Partial<Account>) => void;
};

export const AccountEditForm = ({ account, onCancel, onUpdate }: Props) => {
  const [values, updateValues] = useState<Partial<Account>>(
    pick(["id", "name"], account)
  );
  const handleChange = (e: ChangeEvent<HTMLInputElement>) =>
    updateValues(assoc(e.currentTarget.name, e.currentTarget.value));

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();

    onUpdate(values);
  };

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="name">Name</label>
      <input
        id="name"
        name="name"
        onChange={handleChange}
        type="text"
        value={values.name}
      />
      <button type="submit">Update</button>
      <button onClick={onCancel} type="button">
        Cancel
      </button>
    </form>
  );
};

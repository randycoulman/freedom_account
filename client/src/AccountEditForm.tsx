import { pick } from "ramda";
import { ChangeEvent, FormEvent, useState } from "react";

import { Account, AccountInput } from "./graphql";

type Props = {
  account: Account;
  onCancel: () => void;
  onUpdate: (_values: AccountInput) => void;
};

export const AccountEditForm = ({ account, onCancel, onUpdate }: Props) => {
  const [values, updateValues] = useState<AccountInput>(
    pick(["depositsPerYear", "id", "name"], account)
  );
  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, type, value } = e.currentTarget;
    const parsedValue = type === "number" ? parseInt(value, 10) : value;

    updateValues((state) => ({ ...state, [name]: parsedValue }));
  };

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
      <label htmlFor="depositsPerYear">Deposits / year</label>
      <input
        id="depositsPerYear"
        min={1}
        name="depositsPerYear"
        onChange={handleChange}
        type="number"
        value={values.depositsPerYear}
      />
      <button type="submit">Update</button>
      <button onClick={onCancel} type="button">
        Cancel
      </button>
    </form>
  );
};

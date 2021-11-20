import { Form, Formik } from "formik";
import { pick } from "ramda";
import * as yup from "yup";

import { Input } from "./Input";
import { Account, AccountInput } from "./graphql";

type Props = {
  account: Account;
  onCancel: () => void;
  onUpdate: (_values: AccountInput) => void;
};

const validationSchema = yup.object({
  depositsPerYear: yup.number().integer().positive().required(),
  name: yup.string().max(50).required().trim(),
});

export const AccountEditForm = ({ account, onCancel, onUpdate }: Props) => {
  const initialValues: AccountInput = pick(
    ["depositsPerYear", "id", "name"],
    account
  );

  return (
    <Formik
      initialValues={initialValues}
      onSubmit={(values, { setSubmitting }) => {
        onUpdate(values);
        setSubmitting(false);
      }}
      validationSchema={validationSchema}
    >
      {({ isSubmitting }) => (
        <Form>
          <Input label="Name" name="name" type="text" />
          <Input label="Deposits / year" name="depositsPerYear" type="number" />
          <button disabled={isSubmitting} type="submit">
            Update
          </button>
          <button onClick={onCancel} type="button">
            Cancel
          </button>
        </Form>
      )}
    </Formik>
  );
};

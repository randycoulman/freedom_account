import { ErrorMessage, Field, Form, Formik } from "formik";
import { pick } from "ramda";
import * as yup from "yup";

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
          <label htmlFor="name">Name</label>
          <Field id="name" name="name" type="text" />
          <ErrorMessage name="name" />
          <label htmlFor="depositsPerYear">Deposits / year</label>
          <Field id="depositsPerYear" name="depositsPerYear" type="number" />
          <ErrorMessage name="depositsPerYear" />
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

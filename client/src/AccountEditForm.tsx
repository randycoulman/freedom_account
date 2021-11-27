import { Form, Formik } from "formik";
import { pick } from "ramda";
import * as yup from "yup";

import { Input } from "./Input";
import { Account, AccountInput } from "./graphql";

export type Props = {
  account: Account;
  onCancel?: () => void;
  onUpdate?: (_values: AccountInput) => void;
};

const defaultOnUpdate = (_values: AccountInput) => {
  /* noop */
};

const defaultOnCancel = () => {
  /* noop */
};

const validationSchema = yup.object({
  depositsPerYear: yup.number().integer().positive().required(),
  name: yup.string().max(50).required().trim(),
});

export const AccountEditForm = ({
  account,
  onCancel = defaultOnCancel,
  onUpdate = defaultOnUpdate,
}: Props) => {
  const initialValues: AccountInput = pick(
    ["depositsPerYear", "id", "name"],
    account
  );

  return (
    <Formik
      initialValues={initialValues}
      onSubmit={async (values) => {
        await onUpdate(values);
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
          <button onClick={(_e) => onCancel()} type="button">
            Cancel
          </button>
        </Form>
      )}
    </Formik>
  );
};

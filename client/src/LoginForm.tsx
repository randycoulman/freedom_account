import { Form, Formik } from "formik";
import * as yup from "yup";

import { Input } from "./Input";

export type Props = {
  onSubmit?: (_username: string) => void;
};

const defaultOnSubmit = (_username: string) => {
  /* noop */
};

const validationSchema = yup.object({
  username: yup.string().max(20).required().trim(),
});

export const LoginForm = ({ onSubmit = defaultOnSubmit }: Props) => {
  const initialValues = { username: "" };

  return (
    <Formik
      initialValues={initialValues}
      onSubmit={async ({ username }) => {
        await onSubmit(username);
      }}
      validationSchema={validationSchema}
    >
      {({ isSubmitting }) => (
        <Form>
          <Input label="Username" name="username" type="text" />
          <button disabled={isSubmitting} type="submit">
            Login
          </button>
        </Form>
      )}
    </Formik>
  );
};

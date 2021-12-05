import { Form, Formik } from "formik";
import * as yup from "yup";

import { Input } from "./Input";
import { FundInput } from "./graphql";

export type Props = {
  onCancel?: () => void;
  onSave?: (_values: FundInput) => void;
};

const defaultOnSave = (_values: FundInput) => {};
const defaultOnCancel = () => {};

const validationSchema = yup.object({
  icon: yup.string().max(10).required().trim(),
  name: yup.string().max(50).required().trim(),
});

export const FundEditForm = ({
  onCancel = defaultOnCancel,
  onSave = defaultOnSave,
}: Props) => {
  const initialValues: FundInput = {
    icon: "",
    name: "",
  };

  return (
    <Formik
      initialValues={initialValues}
      onSubmit={async (values) => {
        await onSave(values);
      }}
      validationSchema={validationSchema}
    >
      {({ isSubmitting }) => (
        <Form>
          <Input label="Icon" name="icon" type="text" />
          <Input label="Name" name="name" type="text" />
          <button disabled={isSubmitting} type="submit">
            Save
          </button>
          <button onClick={(_e) => onCancel()} type="button">
            Cancel
          </button>
        </Form>
      )}
    </Formik>
  );
};

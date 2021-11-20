import { ErrorMessage, Field } from "formik";
import { InputHTMLAttributes } from "react";

type Props = InputHTMLAttributes<HTMLInputElement> & {
  label: string;
  name: string;
};

export const Input = ({ label, name, ...inputProps }: Props) => {
  return (
    <>
      <label htmlFor={name}>{label}</label>
      <Field id={name} name={name} {...inputProps} />
      <ErrorMessage name={name} />
    </>
  );
};

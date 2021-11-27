import { render, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as td from "testdouble";

import { LoginForm, Props } from "./LoginForm";
import {
  clearInput,
  clickButton,
  expectError,
  fillInput,
} from "./testSupport/formHelpers";

type OnSubmit = NonNullable<Props["onSubmit"]>;

const renderForm = (props: Partial<Props> = {}) =>
  render(<LoginForm {...props} />);

describe("LoginForm", () => {
  it("validates the username", async () => {
    renderForm();

    clearInput(/username/i);
    userEvent.tab();

    await expectError("username is a required field");
  });

  it("submits the form when valid", async () => {
    const onSubmit = td.func<OnSubmit>();

    renderForm({ onSubmit });

    fillInput(/username/i, "USERNAME");
    const loginButton = clickButton(/login/i);

    await waitFor(() => {
      expect(loginButton).not.toBeDisabled();
    });

    td.verify(onSubmit("USERNAME"));
  });
});

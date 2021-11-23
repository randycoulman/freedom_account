import { render } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import { AccountEditForm, Props } from "./AccountEditForm";
import { accountFactory } from "./testSupport/factories";
import { clearInput, expectError, fillInput } from "./testSupport/formHelpers";

const account = accountFactory.build();

const renderForm = (props: Partial<Props> = {}) =>
  render(<AccountEditForm account={account} {...props} />);

describe("AccountEditForm", () => {
  it("validates the account name", async () => {
    renderForm();

    clearInput(/name/i);
    userEvent.tab();

    await expectError("name is a required field");
  });

  it("validates the number of deposits per year", async () => {
    renderForm();

    clearInput(/deposits/i);
    userEvent.tab();

    await expectError("depositsPerYear is a required field");

    fillInput(/deposits/i, "0");
    userEvent.tab();

    await expectError("depositsPerYear must be a positive number");
  });
});

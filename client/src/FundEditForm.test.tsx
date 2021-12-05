import { render } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import { FundEditForm, Props } from "./FundEditForm";
import { clearInput, expectError } from "./testSupport/formHelpers";

const renderForm = (props: Partial<Props> = {}) =>
  render(<FundEditForm {...props} />);

describe("FundEditForm", () => {
  it("validates the icon", async () => {
    renderForm();

    clearInput(/icon/i);
    userEvent.tab();

    await expectError("icon is a required field");
  });

  it("validates the fund name", async () => {
    renderForm();

    clearInput(/name/i);
    userEvent.tab();

    await expectError("name is a required field");
  });
});

import {
  render,
  screen,
  waitForElementToBeRemoved,
} from "@testing-library/react";
import * as td from "testdouble";

import { AccountHeader, Props } from "./AccountHeader";
import { accountFactory } from "./testSupport/factories";
import { clickButton, fillInput } from "./testSupport/formHelpers";
import { neverCalled } from "./testSupport/neverCalled";

const account = accountFactory.build();

type OnUpdate = NonNullable<Props["onUpdate"]>;

const { isA } = td.matchers;

const renderHeader = (props: Partial<Props> = {}) =>
  render(<AccountHeader account={account} {...props} />);

describe("AccountHeader", () => {
  it("shows a heading by default", () => {
    renderHeader();

    expect(screen.getByRole("heading")).toHaveTextContent(account.name);
  });

  it("allows editing", () => {
    renderHeader();

    clickButton(/edit/i);

    expect(screen.getByLabelText(/name/i)).toBeInTheDocument();
  });

  it("updates the account and returns to heading on submit", async () => {
    const onUpdate = td.func<OnUpdate>();

    renderHeader({ onUpdate });

    clickButton(/edit/i);
    fillInput(/name/i, "New Name");
    fillInput(/deposits/i, "13");
    clickButton(/update/i);

    await waitForElementToBeRemoved(screen.queryByLabelText(/name/i));

    td.verify(
      onUpdate({ depositsPerYear: 13, id: account.id, name: "New Name" })
    );
  });

  it("returns to heading after cancelling", () => {
    const onUpdate = td.func<OnUpdate>();

    renderHeader({ onUpdate });

    clickButton(/edit/i);
    clickButton(/cancel/i);

    expect(screen.queryByLabelText(/name/i)).not.toBeInTheDocument();

    td.verify(onUpdate(isA(Object)), neverCalled);
  });
});
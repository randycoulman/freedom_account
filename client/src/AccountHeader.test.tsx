import { ByRoleOptions, Matcher, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as td from "testdouble";

import { AccountHeader, Props } from "./AccountHeader";
import { Account } from "./graphql";

const account: Account = {
  depositsPerYear: 21,
  funds: [],
  id: "1",
  name: "Initial",
};

type OnUpdate = Props["onUpdate"];
type TextMatch = ByRoleOptions["name"];

const { isA } = td.matchers;
const neverCalled = { ignoreExtraArgs: true, times: 0 };

const clickButton = (name: TextMatch) => {
  userEvent.click(screen.getByRole("button", { name }));
};

const fillInput = (name: Matcher, value: string) => {
  const input = screen.getByLabelText(name);

  userEvent.clear(input);
  userEvent.type(input, value);
};

const renderHeader = (props: Partial<Props> = {}) =>
  render(<AccountHeader account={account} {...props} />);

it("shows a heading by default", () => {
  renderHeader();

  expect(screen.getByRole("heading")).toHaveTextContent(account.name);
});

it("allows editing", () => {
  renderHeader();

  clickButton(/edit/i);

  expect(screen.getByLabelText(/name/i)).toBeInTheDocument();
});

it("updates the account and returns to heading on submit", () => {
  const onUpdate = td.func<OnUpdate>();

  renderHeader({ onUpdate });

  clickButton(/edit/i);
  fillInput(/name/i, "New Name");
  fillInput(/deposits/i, "13");
  clickButton(/update/i);

  expect(screen.queryByLabelText(/name/i)).not.toBeInTheDocument();

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

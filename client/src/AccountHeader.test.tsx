import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as td from "testdouble";

import { AccountHeader, Props } from "./AccountHeader";
import { Account } from "./graphql";

const account: Account = {
  funds: [],
  id: "1",
  name: "Initial",
};

type OnUpdate = Props["onUpdate"];
const neverCalled = { ignoreExtraArgs: true, times: 0 };

const renderHeader = (props: Partial<Props> = {}) =>
  render(<AccountHeader account={account} {...props} />);

it("shows a heading by default", () => {
  renderHeader();

  expect(screen.getByRole("heading")).toHaveTextContent(account.name);
});

it("allows editing", () => {
  renderHeader();

  userEvent.click(screen.getByRole("button", { name: /edit/i }));

  expect(screen.getByLabelText(/name/i)).toBeInTheDocument();
});

it("updates the account and returns to heading on submit", () => {
  const onUpdate = td.func<OnUpdate>();

  renderHeader({ onUpdate });

  userEvent.click(screen.getByRole("button", { name: /edit/i }));

  const input = screen.getByLabelText(/name/i);

  userEvent.clear(input);
  userEvent.type(input, "New Name");
  userEvent.click(screen.getByRole("button", { name: /update/i }));

  expect(
    screen.getByRole("heading", { name: account.name })
  ).toBeInTheDocument();

  td.verify(onUpdate({ id: account.id, name: "New Name" }));
});

it("returns to heading after cancelling", () => {
  const onUpdate = td.func<OnUpdate>();

  renderHeader({ onUpdate });

  userEvent.click(screen.getByRole("button", { name: /edit/i }));
  userEvent.click(screen.getByRole("button", { name: /cancel/i }));

  expect(
    screen.getByRole("heading", { name: account.name })
  ).toBeInTheDocument();

  td.verify(onUpdate({}), neverCalled);
});

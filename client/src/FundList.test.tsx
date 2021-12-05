import {
  render,
  screen,
  waitForElementToBeRemoved,
} from "@testing-library/react";
import * as td from "testdouble";

import { FundList, Props } from "./FundList";
import { Fund } from "./graphql";
import { clickButton, fillInput } from "./testSupport/formHelpers";
import { neverCalled } from "./testSupport/neverCalled";

type OnAddFund = NonNullable<Props["onAddFund"]>;

const { isA } = td.matchers;

const fakeFunds: Fund[] = [
  {
    icon: "🏚️",
    id: "1",
    name: "Home Repairs",
  },
  {
    icon: "🚘",
    id: "2",
    name: "Car Repairs",
  },
  {
    icon: "💸",
    id: "3",
    name: "Property Taxes",
  },
];

const renderList = (props: Partial<Props> = {}) =>
  render(<FundList funds={[]} {...props} />);

describe("FundList", () => {
  it("has an empty state prompt", () => {
    renderList();

    const items = screen.queryAllByRole("listitem");
    const prompt = screen.getByText(/no funds/i);

    expect(items).toStrictEqual([]);
    expect(prompt).toBeInTheDocument();
  });

  it("sorts funds by name", () => {
    renderList({ funds: fakeFunds });

    const items = screen.getAllByRole("listitem");

    expect(items[0]).toHaveTextContent("🚘 Car Repairs");
    expect(items[1]).toHaveTextContent("🏚️ Home Repairs");
    expect(items[2]).toHaveTextContent("💸 Property Taxes");
  });

  it("allows editing", () => {
    renderList();

    const button = clickButton(/add fund/i);

    expect(button()).toBeDisabled();

    expect(screen.getByLabelText(/icon/i)).toBeInTheDocument();
  });

  it("adds the fund, hides the form, and re-enables the add button on submit", async () => {
    const onAddFund = td.func<OnAddFund>();

    renderList({ onAddFund });

    const addButton = clickButton(/add fund/i);

    fillInput(/icon/i, "✨");
    fillInput(/name/i, "New Fund");
    clickButton(/save/i);

    await waitForElementToBeRemoved(screen.queryByLabelText(/icon/i));

    expect(screen.queryByLabelText(/icon/i)).not.toBeInTheDocument();
    expect(addButton()).not.toBeDisabled();

    td.verify(onAddFund({ icon: "✨", name: "New Fund" }));
  });

  it("hides the form and re-enables the add button after cancelling", () => {
    const onAddFund = td.func<OnAddFund>();

    renderList({ onAddFund });

    const addButton = clickButton(/add fund/i);

    clickButton(/cancel/i);

    expect(screen.queryByLabelText(/icon/i)).not.toBeInTheDocument();
    expect(addButton()).not.toBeDisabled();

    td.verify(onAddFund(isA(Object)), neverCalled);
  });
});

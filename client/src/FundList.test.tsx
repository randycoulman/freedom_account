import { render, screen } from "@testing-library/react";

import FundList, { Fund } from "./FundList";

const fakeFunds: Fund[] = [
  {
    icon: "🏚️",
    id: 1,
    name: "Home Repairs",
  },
  {
    icon: "🚘",
    id: 2,
    name: "Car Repairs",
  },
  {
    icon: "💸",
    id: 3,
    name: "Property Taxes",
  },
];

it("sorts funds by name", () => {
  render(<FundList funds={fakeFunds} />);

  const items = screen.getAllByRole("listitem");

  expect(items[0]).toHaveTextContent("🚘 Car Repairs");
  expect(items[1]).toHaveTextContent("🏚️ Home Repairs");
  expect(items[2]).toHaveTextContent("💸 Property Taxes");
});

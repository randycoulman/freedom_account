import { render, screen } from "@testing-library/react";

import FundList from "./FundList";

test("sorts funds by name", () => {
  render(<FundList />);

  const items = screen.getAllByRole("listitem");

  expect(items[0]).toHaveTextContent("🚘 Car Repairs");
  expect(items[1]).toHaveTextContent("🏚️ Home Repairs");
  expect(items[2]).toHaveTextContent("💸 Property Taxes");
});

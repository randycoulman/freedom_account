import { render, screen } from "@testing-library/react";

import App from "./App";

test("renders page header", () => {
  render(<App />);
  const pageHeader = screen.getByText(/freedom account/i);

  expect(pageHeader).toBeInTheDocument();
});

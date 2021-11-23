import { ByRoleOptions, Matcher, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

type TextMatch = ByRoleOptions["name"];

export const clickButton = (name: TextMatch) => {
  userEvent.click(screen.getByRole("button", { name }));
};

export const fillInput = (name: Matcher, value: string) => {
  const input = screen.getByLabelText(name);

  userEvent.clear(input);
  userEvent.type(input, value);
};

import {
  ByRoleOptions,
  Matcher,
  screen,
  waitFor,
} from "@testing-library/react";
import userEvent from "@testing-library/user-event";

type TextMatch = ByRoleOptions["name"];

export const clearInput = (name: Matcher) => {
  const input = screen.getByLabelText(name);

  userEvent.clear(input);
  return input;
};

export const clickButton = (name: TextMatch) => {
  const button = screen.getByRole("button", { name });

  userEvent.click(button);
  return button;
};

export const expectError = (message: Matcher) =>
  waitFor(() => {
    expect(screen.getByText(message)).toBeInTheDocument();
  });

export const fillInput = (name: Matcher, value: string) => {
  const input = clearInput(name);

  userEvent.type(input, value);
  return input;
};

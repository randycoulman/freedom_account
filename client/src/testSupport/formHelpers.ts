import {
  ByRoleOptions,
  Matcher,
  screen,
  waitFor,
} from "@testing-library/react";
import userEvent from "@testing-library/user-event";

type TextMatch = ByRoleOptions["name"];

export const clearInput = (name: Matcher) => {
  const selector = () => screen.getByLabelText(name);

  userEvent.clear(selector());
  return selector;
};

export const clickButton = (name: TextMatch) => {
  const selector = () => screen.getByRole("button", { name });

  userEvent.click(selector());
  return selector;
};

export const expectError = (message: Matcher) =>
  waitFor(() => {
    expect(screen.getByText(message)).toBeInTheDocument();
  });

export const fillInput = (name: Matcher, value: string) => {
  const selector = clearInput(name);

  userEvent.type(selector(), value);
  return selector;
};

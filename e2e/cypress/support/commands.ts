import "@testing-library/cypress/add-commands";

// ***********************************************
// This example commands.ts shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//

Cypress.Commands.add("ignoreErrorBoundary", (message: string) => {
  cy.on("uncaught:exception", (err) => {
    if (err.message.includes(message)) {
      return false;
    }
    return true;
  });
});

Cypress.Commands.add("login", () => {
  cy.visit("/login");
  cy.findByLabelText(/username/i)
    .clear()
    .type("cypress");
  cy.findByRole("button", { name: /login/i }).click();
  cy.shouldHaveLocation("/");
});

Cypress.Commands.add("logout", () => {
  cy.visit("/login");
  cy.findByRole("button", { name: /logout/i });
});

Cypress.Commands.add("shouldHaveLocation", (expectedPathname: string) => {
  cy.location().should(({ pathname }) => {
    expect(pathname).to.eq(expectedPathname);
  });
});

/// <reference types="cypress" />

context("placeholder", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  describe("home page", () => {
    it("shows the standard create-react-app message", () => {
      cy.contains("save to reload").should("exist");
    });
  });
});

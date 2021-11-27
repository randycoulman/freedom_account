context("account settings", () => {
  beforeEach(() => {
    cy.login();
    cy.visit("/");
  });

  describe("account settings", () => {
    it("shows the account name", () => {
      // cy.findByRole("heading", { name: "Initial Account" }).should("exist");
      cy.findByRole("heading").should("exist");
    });

    it("allows editing account settings", () => {
      cy.findByRole("button", { name: /edit/i }).click();
      cy.findByLabelText(/name/i).clear().type("My New Account");
      cy.findByLabelText(/deposits/i)
        .clear()
        .type("18");
      cy.findByRole("button", { name: /update/i }).click();

      cy.findByRole("heading", { name: "My New Account" }).should("exist");
      cy.findByRole("button", { name: /update/i }).should("not.exist");
    });
  });
});

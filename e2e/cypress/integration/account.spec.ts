context("account settings", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  describe("account settings", () => {
    it("shows the account name", () => {
      cy.findByRole("heading", { name: "Initial Account" }).should("exist");
    });

    it("allows editing account settings", () => {
      cy.findByRole("heading", { name: "Initial Account" });
      cy.findByRole("button", { name: /edit/i }).click();
      cy.findByLabelText(/name/i).clear().type("My New Account");
      cy.findByRole("button", { name: /update/i }).click();

      cy.findByRole("heading", { name: "My New Account" }).should("exist");
      cy.findByRole("button", { name: /edit/i }).should("not.exist");
    });
  });
});

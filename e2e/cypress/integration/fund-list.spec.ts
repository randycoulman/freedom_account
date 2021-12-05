context("fund list", () => {
  beforeEach(() => {
    cy.resetAccount();
    cy.login();
    cy.visit("/");
  });

  describe("fund list page", () => {
    it("shows an empty list of funds", () => {
      cy.findByRole("heading", { name: "Funds" }).should("exist");
      cy.findByRole("listitem").should("not.exist");
      cy.findByText(/no funds/i).should("exist");
    });

    it("allows creation of a new fund", () => {
      cy.findByRole("button", { name: /add fund/i }).click();
      cy.findByLabelText(/icon/i).clear().type("🎉");
      cy.findByLabelText(/name/i).clear().type("My First Fund");
      cy.findByRole("button", { name: /save/i }).click();

      cy.findByRole("button", { name: /save/i }).should("not.exist");
      cy.findByRole("listitem").should("have.text", "🎉 My First Fund");
    });
  });
});

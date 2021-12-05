context("fund list", () => {
  beforeEach(() => {
    cy.resetAccount();
    cy.login();
    cy.visit("/");
  });

  describe("fund list page", () => {
    it("shows an empty list of funds", () => {
      cy.findByRole("heading", { name: "Freedom Account" }).should("exist");
      cy.findByRole("heading", { name: "Funds" }).should("exist");
      cy.findByRole("listitem").should("not.exist");
    });
  });
});

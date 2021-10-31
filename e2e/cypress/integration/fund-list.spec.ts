context("fund list", () => {
  beforeEach(() => {
    cy.visit("/funds");
  });

  describe("fund list page", () => {
    it("shows a list of funds", () => {
      cy.findByRole("heading", { name: "Freedom Account" }).should("exist");
      cy.findByRole("heading", { name: "Funds" }).should("exist");
      cy.findAllByRole("listitem").should((items) => {
        expect(items[0]).to.contain.text("🚘 Car Repairs");
        expect(items[1]).to.contain.text("🏚️ Home Repairs");
        expect(items[2]).to.contain.text("💸 Property Taxes");
      });
    });
  });
});

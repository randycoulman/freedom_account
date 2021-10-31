context("fund list", () => {
  beforeEach(() => {
    cy.visit("/funds");
  });

  describe("fund list page", () => {
    it("shows a list of funds", () => {
      cy.findByRole("heading", { name: "Freedom Account" }).should("exist");
      cy.findByRole("heading", { name: "Funds" }).should("exist");
      cy.findAllByRole("listitem").should((items) => {
        expect(items.length).to.eq(3);
      });
    });
  });
});

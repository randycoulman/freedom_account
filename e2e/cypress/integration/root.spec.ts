context("root", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  describe("root page", () => {
    it("redirects to the fund list page", () => {
      cy.location().should((loc) => {
        expect(loc.pathname).to.eq("/funds");
      });
    });
  });
});

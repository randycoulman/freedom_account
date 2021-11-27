context("login", () => {
  describe("when logged out", () => {
    beforeEach(() => {
      cy.logout();
    });

    it("disallows access to accounts page", () => {
      cy.ignoreErrorBoundary("unauthorized");
      cy.visit("/");
      cy.findByRole("heading", { name: /login/i }).should("exist");
      cy.shouldHaveLocation("/login");
    });

    it("proceeds to accounts page after logging in", () => {
      cy.login();
      cy.shouldHaveLocation("/");
    });

    it("redirects to login page after logging out", () => {
      cy.login();
      cy.logout();
      cy.shouldHaveLocation("/login");
    });
  });
});

# Freedom Account Tracker

I first learned about the Freedom Account from Mary Hunt's book, [Debt-Proof
Living](https://www.amazon.com/gp/product/0800721454/).  A Freedom Account is a
separate bank account where you regularly save for larger irregular expenses,
such as car repairs, annual or semi-annual insurance premiums, property taxes,
Christmas gifts, etc. [This article](http://www.mdmproofing.com/iym/freedom.php)
summarizes the idea very well.

I generally save for many different kinds of expenses ("categories" or
"sub-accounts") in my Freedom Account, and I needed a way to track the balance
of each category over time.  That's what this app is for.

## Handy Commands

I'll eventually flesh this out into better instructions; for now, this is just a
scratchpad to remind myself how to do things:

- Run the server in development mode: `docker-compose up -d server`
- Build the production app: `docker-compose -f docker-compose-prod.yml -p freedom_account_prod build`
- Run the production app: `docker-compose -f docker-compose-prod.yml -p freedom_account_prod up -d`

Local commands (run from the `server` directory):
- Install dependencies (requires [asdf](https://github.com/asdf-vm/asdf)): `asdf install`
- Run tests: `mix test`
- Run tests in watch mode: `mix test.watch`
- Run linting: `mix credo`
- Run type checks: `mix dialyzer`
- Format the code: `mix format`
- Run all server tests/linting/type-checking/format-checking: `MIX_ENV=test mix test.all`

## Approach

I previously built a version of this app in Smalltalk using the Seaside web
framework and have been using it for many years.  I decided to build a new,
updated version of the app in order to build my knowledge and skills in some
newer-to-me technologies.

As such, this is a side/learning project for me.  I don't expect others to find
it terribly useful for their needs, but I'm hoping that the code and development
process will be instructive.

I'm building this "in the open" so others can see the process I'm going through
while building it.  Even though it's a solo project, I plan to do the work via
pull requests that document what I'm doing and why.

I may also write a series of blog posts about this project on [my
blog](http://randycoulman.com/blog/).

## Learning Goals

Here's what I hope to learn by doing this project:

### Technologies/Languages/Tools

- GraphQL: I've been using this on client projects and work and want to continue
  to get more familiar with it.

- Elixir/Phoenix/Absinthe: I've build a [command-line
  application](https://github.com/randycoulman/invoice_tracker) in Elixir,
  worked on a fairly complex Elixir application for a client through my job, and
  maintained a very small internal Elixir/Phoenix application at work.  I want
  to gain more experience with Phoenix, and I've heard good things about
  Absinthe for building GraphQL servers, so I wanted to try that out as well.

- Modern React: I've been working in React for three years now, but I've never
  had the chance to start a project from the very beginning and control how
  everything is done.  I also don't have any open-source work in React that I
  can show people, as everything I've done has been on client projects.  I want
  to use fully-modern React capabilities, such as Strict Mode from day 1, using
  hooks as much as possible, etc.

- Docker: I've been using Docker at work, but most of the setup was done by
  another team member.  I want to learn how to do more of this work myself.

- Jest: I use Jest on pretty much every JavaScript project I do now, but I've
  come to realize that some patterns I've been following may not be the best.  I
  want to experiment with some alternatives.

- Cypress: I've heard really good things about Cypress as an end-to-end testing
  tool.  I want to try it out and get good at it.

- Hot-reloading in React.  I've used this in the past and loved it, but more
  recently the tools for it haven't been working in all situations.  For
  example, I don't believe that create-react-app currently supports
  hot-reloading out of the box.  I know there's been some recent work to make
  hot-reloading more usable and reliable, so I want to see if I can get that
  working.

### Overall Development Approach

On past projects, I've often been on projects where we rushed into delivering
the first few features early to get quick wins, but skipped over some important
things.  On this project, I want to try to do those important things from Day 1
to see how things turn out.  Among them:

- Use GitHub's project management tools.  Normally, I use Pivotal Tracker when
  given a choice, but for this project, I'd like to keep everything in one
  place, so I'm going to try out GitHub's tools.

- End-to-end tests.  I plan to use Cypress for this.

- Build and tooling infrastructure, including Continuous Integration
  (CI), linting, testing, type checking, etc.

- Proper error handling.

- Accessibility.

- Animations.

- Optimistic updates with proper rollback when errors occur.

- Pay attention to performance early on, especially React rendering performance.
  I want to learn if I'm using some patterns that negatively affect performance,
  and also try to establish some guidelines for myself about when to use some of
  React's performance optimization tools.

### Design

I'm not a designer, but I want to try to learn some design by doing my own
design for this project.  I am getting some mentoring from a designer at work,
but want to try doing as much of it myself as I can.

I want to try to design this application using a mobile-first approach as well.

### Other Possibilities

I'm not ready to commit to the items in this list just yet, but they are ideas
for other things I might want to learn about using this project as a vehicle:

- Proper handling of user roles

- Progressive web app

- Server-side rendering

- GraphQL code generation

- React Native

- [Architecture Decision
  Records](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)

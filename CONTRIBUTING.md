# Contribution Guidelines

Contributions are welcome from anyone who is interested in improving this project and there are multiple ways in which
you can contribute.

Be it code, documentation, or whatever, every contribution helps this project.

## Code of Conduct

Melon follows the
[GitHub Community Code of Conduct](https://docs.github.com/en/site-policy/github-terms/github-community-code-of-conduct).
By participating in this project, you agree to abide by its terms.

## License

By contributing to this project, you agree that your contributions will be licensed under the
[MIT license](https://github.com/patrik-kuehl/melon/blob/main/LICENSE.md).

## Code Style Guide

Melon doesn't come with a strict code style guide. Everything is checked by [Prettier](https://prettier.io/) and the
formatter that comes with Gleam.

You can run `npm run check` to check if everything is formatted accordingly and `npm run format` to run the formatters.

To keep modules organized, you need to follow this structure:

| Order |   Code Category   |
| :---: | :---------------: |
|   1   |   public types    |
|   2   | public constants  |
|   3   | public functions  |
|   4   |   private types   |
|   5   | private constants |
|   6   | private functions |

Apart from this, just keep your code readable. Remember, code is read more often than written. Everything else is just a
matter of someone's personal taste, and the heavy usage of opinionated formatters just prevents such (useless)
discussions.

## Git Branching Strategy

This project utilizes the [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).

Additionally, make sure to rebase onto the remote main branch in case new changes have been merged onto this branch.
This will ensure the Git history is kept flat.

## Commit Messages

This project employs [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## Changelog

This project maintains a changelog based on the format of [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Make
sure to add notable changes to the changelog before submitting a pull request.

## Development Environment

### Setup

|            Dependency             | Version  |
| :-------------------------------: | :------: |
| [Docker](https://www.docker.com/) | \>= 23.0 |
|    [Gleam](https://gleam.run/)    |  == 1.3  |
|      [Bun](https://bun.sh/)       | \>= 1.0  |
|     [Deno](https://deno.com/)     | \>= 1.0  |
| [Node.js](https://nodejs.org/)\*  | \>= 20.0 |

You need to run `npm ci` to set up all required npm dependencies. This ensures
[Husky](https://typicode.github.io/husky/) configures all Git hooks and that all npm scripts are executable.

\* Although Melon supports different JavaScript targets, Node.js will be required for local development to ensure the
highest compatibility with the `package.json`. Bun and Deno are only required for executing tests to ensure
compatibility.

### npm Scripts

|     Script     |                  Description                  |
| :------------: | :-------------------------------------------: |
|     check      | checks if everything is formatted accordingly |
|     format     |              applies formatting               |
|      test      |     runs tests on all non-browser targets     |
| test-on-erlang |        runs tests on the Erlang target        |
| test-on-nodejs |       runs tests on the Node.js target        |
|  test-on-deno  |         runs tests on the Deno target         |
|  test-on-bun   |         runs tests on the Bun target          |

# Contributing to Claude Code Sandbox

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

- Use the bug report template when creating an issue
- Include detailed steps to reproduce the problem
- Include your environment details (OS, Docker version, etc.)
- Attach relevant logs or error messages

### Suggesting Features

- Use the feature request template
- Clearly describe the use case and expected behavior
- Explain why this feature would be useful

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature/fix
3. Make your changes
4. Test your changes thoroughly
5. Update documentation if needed
6. Submit a pull request with a clear description

## Development Setup

1. Clone the repository
2. Copy `.env.example` to `.env` and add your credentials
3. Build the container: `docker-compose build`
4. Test your changes

## Code Style

- Keep changes focused and minimal
- Follow existing code patterns
- Comment complex logic
- Update README.md if adding new features

## Testing

Before submitting a PR:
- Build the Docker image successfully
- Start the container and verify it runs
- Test GitHub authentication works
- Test Claude Code CLI works inside the container

## Questions?

Feel free to open an issue for questions or clarifications.

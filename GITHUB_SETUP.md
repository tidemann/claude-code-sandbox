# Publishing to GitHub

The git repository is initialized and ready to push. Follow these steps to publish it to GitHub:

## Option 1: Using GitHub CLI (Recommended)

```bash
# Create a new public repository
gh repo create claude-code-sandbox --public --source=. --push

# Or create a private repository
gh repo create claude-code-sandbox --private --source=. --push
```

## Option 2: Manual Setup

1. **Create a new repository on GitHub:**
   - Go to https://github.com/new
   - Repository name: `claude-code-sandbox` (or your preferred name)
   - Choose public or private
   - **Do NOT** initialize with README, .gitignore, or license (we already have these)
   - Click "Create repository"

2. **Push your local repository:**
   ```bash
   # Add the remote (replace YOUR_USERNAME with your GitHub username)
   git remote add origin https://github.com/YOUR_USERNAME/claude-code-sandbox.git

   # Rename branch to main (GitHub's default)
   git branch -M main

   # Push to GitHub
   git push -u origin main
   ```

## After Publishing

Your repository will include:
- ✅ Complete Docker setup
- ✅ Documentation (README.md)
- ✅ MIT License
- ✅ Contributing guidelines
- ✅ GitHub Actions CI workflow
- ✅ Issue templates
- ✅ .gitignore for secrets

The GitHub Actions workflow will automatically run to test the Docker build on every push and pull request.

## Recommended GitHub Settings

After creating the repo, consider:
- Add topics: `docker`, `claude-code`, `sandbox`, `ai`, `anthropic`
- Add a description: "Sandboxed Docker environment for running Claude Code agents with GitHub access"
- Enable GitHub Actions (should be enabled by default)
- Enable issue templates

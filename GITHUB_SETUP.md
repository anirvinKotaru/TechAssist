# GitHub Setup Instructions

Your project is now ready to push to GitHub! Follow these steps:

## Step 1: Create a GitHub Repository

1. Go to https://github.com and sign in (or create an account)
2. Click the **"+"** icon in the top right → **"New repository"**
3. Fill in the details:
   - **Repository name**: `work-order-dashboard` (or any name you prefer)
   - **Description**: "Work Order Dashboard with priority system for NMC^2 technicians"
   - Choose **Public** or **Private**
   - **DO NOT** check "Initialize with README" (you already have files)
4. Click **"Create repository"**

## Step 2: Connect and Push to GitHub

After creating the repository, GitHub will show you commands. Use these:

```bash
# Add the remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/work-order-dashboard.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

**OR** if you already have a repository URL, just run:

```bash
git remote add origin YOUR_REPOSITORY_URL
git branch -M main
git push -u origin main
```

## Step 3: Share with Your Friend

Once pushed, share the repository URL with your friend:
- `https://github.com/YOUR_USERNAME/work-order-dashboard`

Your friend can then clone it on their Mac:
```bash
git clone https://github.com/YOUR_USERNAME/work-order-dashboard.git
cd work-order-dashboard
```

Then they should follow the instructions in `SETUP.md` to create the Xcode project.

## Troubleshooting

- **If you get authentication errors**: You may need to set up a Personal Access Token or SSH key
- **If branch is already "main"**: Skip the `git branch -M main` command
- **If you need to update later**: Just use `git add .`, `git commit -m "message"`, and `git push`

## Current Status

✅ Git repository initialized
✅ All files committed locally
✅ Ready to push to GitHub


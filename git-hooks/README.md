# Git Hooks for Automated Deployment

This directory contains Git hooks that can automate your deployment process.

## Installation

### For cPanel Git Version Control:

1. **Copy the hook to your repository's Git hooks directory:**
   ```bash
   cp git-hooks/post-receive .git/hooks/post-receive
   chmod +x .git/hooks/post-receive
   ```

2. **Or create it directly via cPanel File Manager:**
   - Navigate to your repository directory
   - Go to `.git/hooks/`
   - Create new file `post-receive`
   - Copy the content from `git-hooks/post-receive`
   - Set permissions to 755

## Available Hooks

### `post-receive`
Automatically runs after Git receives new commits (when you push to the repository).

**What it does:**
- Detects when new code is pushed
- Automatically runs the `deployment.sh` script
- Provides feedback on deployment success/failure

**Triggers on:**
- Git push to the repository
- cPanel Git Version Control pull/deploy

## Manual Setup Instructions

If you need to set this up manually on your cPanel hosting:

```bash
# SSH into your server
ssh username@yourserver.com

# Navigate to your repository
cd /home/username/portfolio

# Copy the hook
cp git-hooks/post-receive .git/hooks/post-receive

# Make it executable
chmod +x .git/hooks/post-receive

# Test the hook (optional)
.git/hooks/post-receive
```

## Testing

To test if the hook is working:

1. Make a small change to your repository
2. Commit and push the change
3. Check if deployment runs automatically
4. Verify the change appears on your live site

## Troubleshooting

### Hook not running?
- Check file permissions: `ls -la .git/hooks/post-receive`
- Ensure it's executable: `chmod +x .git/hooks/post-receive`
- Verify the shebang line: `#!/bin/bash`

### Deployment failing?
- Check deployment script permissions: `ls -la deployment.sh`
- Test deployment script manually: `./deployment.sh`
- Check server logs for error messages

### cPanel specific issues?
- Some shared hosts disable Git hooks for security
- Contact your hosting provider if hooks aren't working
- You can still deploy manually via cPanel Git interface

## Security Notes

- Git hooks run with your user permissions
- Keep hook scripts simple and secure
- Avoid storing sensitive data in hooks
- Test hooks thoroughly before production use
# PowerShell Script for Windows

# Set variables for Obsidian to Hugo copy
$sourcePath = "C:\Users\Ramunas\AnthropicFun\Second_Brain\posts"
$destinationPath = "C:\Users\Ramunas\AnthropicFun\hugo-portfolio\content\posts"

# Set Github repo 
$myrepo = "git@github.com:ramunasnognys/RNPortfolio.git"

# Set error handling
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Change to the script's directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir

# Check for required commands
$requiredCommands = @('git', 'hugo')

# Check for Python command
if (Get-Command 'python' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'python'
} elseif (Get-Command 'python3' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'python3'
} else {
    Write-Error "Python is not installed or not in PATH."
    exit 1
}

foreach ($cmd in $requiredCommands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "$cmd is not installed or not in PATH."
        exit 1
    }
}

# Step 1: Git initialization check
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..."
    git init
    git remote add origin $myrepo
} else {
    Write-Host "Git repository already initialized."
    $remotes = git remote
    if (-not ($remotes -contains 'origin')) {
        Write-Host "Adding remote origin..."
        git remote add origin $myrepo
    }
}

# Step 2: Sync posts
Write-Host "Syncing posts from Obsidian..."

if (-not (Test-Path $sourcePath)) {
    Write-Error "Source path does not exist: $sourcePath"
    exit 1
}

if (-not (Test-Path $destinationPath)) {
    Write-Error "Destination path does not exist: $destinationPath"
    exit 1
}

# Robocopy mirror
$robocopyOptions = @('/MIR', '/Z', '/W:5', '/R:3')
$robocopyResult = robocopy $sourcePath $destinationPath @robocopyOptions

if ($LASTEXITCODE -ge 8) {
    Write-Error "Robocopy failed with exit code $LASTEXITCODE"
    exit 1
}

# Step 3: Process images
Write-Host "Processing image links..."
if (-not (Test-Path "images.py")) {
    Write-Error "Python script images.py not found."
    exit 1
}

try {
    & $pythonCommand images.py
} catch {
    Write-Error "Failed to process image links."
    exit 1
}

# Step 4: Hugo build
Write-Host "Building Hugo site..."
try {
    hugo
} catch {
    Write-Error "Hugo build failed."
    exit 1
}

# Step 5: Git staging
Write-Host "Staging changes..."
$hasChanges = (git status --porcelain) -ne ""
if ($hasChanges) {
    git add .
}

# Step 6: Git commit
$commitMessage = "New Blog Post on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$hasStagedChanges = (git diff --cached --name-only) -ne ""
if ($hasStagedChanges) {
    Write-Host "Committing changes..."
    git commit -m "$commitMessage"
}

# Step 7: Git push
Write-Host "Pushing to GitHub..."
try {
    git push origin main
} catch {
    Write-Error "Failed to push to Main branch."
    exit 1
}

# Step 8: Hostinger deployment
Write-Host "Deploying to Hostinger..."

$remotePath = "u765550710@45.84.206.80:/home/u765550710/domains/blog.ramunasgnognys.tech/public_html"

if (-not (Get-Command rsync -ErrorAction SilentlyContinue)) {
    Write-Error "rsync is not installed."
    exit 1
}

# Quiet rsync deployment
$rsyncOptions = @(
    "-az",
    "-q",
    "--delete",
    "public/",
    "$remotePath"
)

try {
    $output = rsync @rsyncOptions 2>&1
    Write-Host "✓ Deployment completed" -ForegroundColor Green
} catch {
    Write-Error "× Deployment failed"
    exit 1
}

Write-Host "All done! Site deployed successfully."

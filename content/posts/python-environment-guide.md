---
title: "Python Environment Management in Bash: A Complete Guide"
date: "2024-01-28"
author: "Ramunas"
tags: ["python", "environment", "bash", "uv", "conda", "development", "tutorial"]
description: "A comprehensive guide to managing Python environments in Bash using UV and Conda, with practical examples from the Janus project."
category: "Development"
status: "published"
---

# Python Environment Management in Bash: A Complete Guide

Working with Python environments is crucial for maintaining clean, reproducible development setups. This guide will walk you through managing Python environments in Bash, using the Janus project as a practical example. We'll cover both `uv` and `conda` approaches, helping you understand which might work best for your needs.

## Understanding Python Environments

Before diving into the practical steps, let's understand why we need virtual environments:

- Isolation of project dependencies
- Prevention of package conflicts
- Easy project reproduction across different machines
- Clean development environment for each project

## Method 1: Using UV (Modern Approach)

UV is a modern, fast Python package installer and resolver. Here's how to use it with the Janus project:

### 1. Setting Up UV

First, install UV if you haven't already:

```bash
pip install uv
```

### 2. Creating and Activating the Environment

```bash
# Create a new virtual environment
uv venv venv

# Activate the environment
source venv/Scripts/activate  # Windows
# OR
source venv/bin/activate     # Linux/macOS
```

### 3. Installing Dependencies

```bash
# Install PyTorch with CUDA support
uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# Install project dependencies
uv pip install -e .
uv pip install pillow numpy transformers
```

## Method 2: Using Conda (Alternative Approach)

Conda is a powerful package manager that handles both Python and non-Python dependencies. Here's how to use it:

### 1. Creating a Conda Environment

```bash
# Create a new environment with Python 3.8
conda create -n janus-env python=3.8

# Activate the environment
conda activate janus-env
```

### 2. Installing Dependencies

```bash
# Install PyTorch and related packages
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

# Install Git through conda-forge
conda install -c conda-forge git

# Install additional dependencies
pip install transformers
```

## Project Setup (Common to Both Methods)

After setting up your environment, proceed with the project installation:

```bash
# Clone the repository
git clone https://github.com/deepseek-ai/Janus.git
cd Janus

# Install the project in editable mode
pip install -e .
```

## Environment Management Best Practices

### 1. Environment Activation and Deactivation

```bash
# UV activation
source venv/Scripts/activate  # Windows
source venv/bin/activate     # Linux/macOS

# Conda activation
conda activate janus-env

# Deactivation
deactivate  # UV
conda deactivate  # Conda
```

### 2. Checking Installed Packages

```bash
# List installed packages
pip list  # Both UV and Conda
conda list  # Conda only
```

### 3. Saving Environment Configuration

```bash
# UV/pip
pip freeze > requirements.txt

# Conda
conda env export > environment.yml
```

### 4. Recreating Environments

```bash
# UV/pip
uv venv venv
source venv/Scripts/activate
pip install -r requirements.txt

# Conda
conda env create -f environment.yml
```

## Troubleshooting Common Issues

### 1. Activation Fails

If activation fails, check:
- Path to activation script is correct
- You're using the right slash direction for your OS
- You have sufficient permissions

### 2. Package Installation Errors

For CUDA-related issues:
```bash
# Check CUDA version
nvidia-smi

# Ensure PyTorch version matches CUDA version
pip show torch
```

### 3. Environment Conflicts

```bash
# Remove environment if needed
rm -rf venv  # UV
conda env remove -n janus-env  # Conda
```

## Environment Selection Guide

Choose UV if you:
- Need faster package installation
- Want a lightweight solution
- Work primarily with Python packages

Choose Conda if you:
- Need non-Python dependencies
- Work with data science tools
- Prefer a more comprehensive package manager

## Project-Specific Notes for Janus

When working with the Janus project:

1. Ensure CUDA compatibility:
   - Check your GPU support
   - Verify CUDA toolkit installation
   - Match PyTorch version with CUDA version

2. Development setup:
   ```bash
   # Install in editable mode for development
   pip install -e .
   ```

3. Verify installation:
   ```bash
   python -c "import torch; print(torch.cuda.is_available())"
   ```

## Conclusion

Managing Python environments effectively is crucial for maintaining clean, reproducible development environments. Whether you choose UV or Conda depends on your specific needs, but both tools provide robust solutions for environment management.

Remember to:
- Always work in a virtual environment
- Keep track of your dependencies
- Document environment setup steps
- Regularly update your requirements files
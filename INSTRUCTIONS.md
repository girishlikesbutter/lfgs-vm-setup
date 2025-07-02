# LFG-S VM Setup Package

## 📦 What's in this package

- **`setup_lfgs_vm.sh`** - Master setup script (installs everything)
- **`install_claude_code.sh`** - Claude Code CLI installation  
- **`README.md`** - Quick reference guide
- **`INSTRUCTIONS.md`** - This file

## 🚀 New VM Setup (2 commands)

### Step 1: Run Setup Script
```bash
chmod +x setup_lfgs_vm.sh
./setup_lfgs_vm.sh
```
*This takes 5-10 minutes and installs everything automatically.*

### Step 2: Configure Git Authentication  
```bash
echo 'your_github_personal_access_token' > .github_token
./setup_git_auth.sh
```

## ✅ Validate Setup
```bash
./validate_setup.sh
```

## 🎯 Start Development
```bash
cd LFG-S
source venv/bin/activate
claude
```

**Initialize Claude with:**
```
Read docs/setup/CLAUDE_CONTEXT.md for full project context, then read docs/PRD.md for requirements.
```

## 📋 What Gets Installed

- Claude Code CLI
- Python 3.8+ with virtual environment
- LFG-S repository from GitHub
- All project dependencies (torch, numpy, spiceypy, etc.)
- Development tools (pytest, git, etc.)
- Complete project structure with data assets

## 🎯 Current Focus

**HFG Optimization (PRD Week 1-2)**
- File: `src/high_fidelity/shadowing_calculator.py` 
- Goal: 10x+ speedup via parallelization
- Priority: Reduce shadowing data generation from days to hours

---
*Keep this package locally and copy to any new VM for instant LFG-S setup.*
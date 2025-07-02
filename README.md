# LFG-S VM Setup Directory

## 🚀 Quick Start (New VM)

```bash
# 1. Run master setup (5-10 minutes)
chmod +x setup_lfgs_vm.sh
./setup_lfgs_vm.sh

# 2. Add your GitHub token (1 minute)
echo 'your_github_token_here' > .github_token
./setup_git_auth.sh

# 3. Validate setup (30 seconds)
./validate_setup.sh

# 4. Start development
cd LFG-S
source venv/bin/activate
claude
```

**Tell Claude:** `Read ../CLAUDE_CONTEXT.md then docs/PRD.md`

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `setup_lfgs_vm.sh` | **Master setup script** - Installs everything |
| `install_claude_code.sh` | Claude Code CLI installation |
| `setup_git_auth.sh` | Git authentication (created by master script) |
| `validate_setup.sh` | Validates complete setup |
| `CLAUDE_CONTEXT.md` | **Full project context for Claude** |
| `VM_SETUP_SUMMARY.md` | Complete setup guide |
| `QUICK_START.md` | Development commands (created by master script) |

## 🎯 What You Get

- ✅ **Claude Code CLI** installed and ready
- ✅ **LFG-S repository** cloned with all modules
- ✅ **Python environment** with all dependencies
- ✅ **Git authentication** configured
- ✅ **Development tools** (pytest, profiling, etc.)
- ✅ **Project data** (SPICE kernels, 3D models)
- ✅ **Claude context** for immediate productivity

## 🔄 For Existing Development

If LFG-S is already set up:
```bash
cd LFG-S
source venv/bin/activate
git pull  # Get latest changes
claude
```

## 📋 Current Priority

**HFG Optimization (PRD Week 1-2)**
- Focus: `src/high_fidelity/shadowing_calculator.py`
- Goal: 10x+ speedup via parallelization
- Target: Days → Hours for shadowing data generation

---
*This setup system enables rapid VM deployment for scalable LFG-S development.*
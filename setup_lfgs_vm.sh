#!/bin/bash

# ============================================================================
# LFG-S VM Setup Script
# ============================================================================
# This script sets up a fresh VM for LFG-S development by:
# 1. Installing Claude Code CLI
# 2. Installing system dependencies
# 3. Cloning the LFG-S repository
# 4. Setting up Python environment
# 5. Installing project dependencies
# 6. Creating context documents for Claude
# ============================================================================

set -e  # Exit on any error

echo "=========================================="
echo "🚀 LFG-S VM Setup Starting..."
echo "=========================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user."
   exit 1
fi

# ============================================================================
# Step 1: Install Claude Code CLI
# ============================================================================
print_status "Step 1: Installing Claude Code CLI..."

if [ -f "./install_claude_code.sh" ]; then
    chmod +x ./install_claude_code.sh
    ./install_claude_code.sh
    print_success "Claude Code CLI installed"
else
    print_warning "install_claude_code.sh not found. Downloading from repository..."
    
    # Create a basic Claude Code installation if the script isn't available
    print_status "Installing system dependencies..."
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y curl git python3 python3-pip python3-venv
    
    # Install nvm and Node.js
    print_status "Installing Node.js via nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    nvm install --lts
    nvm use --lts
    
    # Install Claude Code CLI
    npm install -g @anthropic-ai/claude-code
    
    print_success "Claude Code CLI installed (fallback method)"
fi

# ============================================================================
# Step 2: Install System Dependencies
# ============================================================================
print_status "Step 2: Installing system dependencies..."

# Ensure basic tools are installed
sudo apt update -y
sudo apt install -y \
    curl \
    git \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    jq \
    tree \
    htop

print_success "System dependencies installed"

# ============================================================================
# Step 3: Clone LFG-S Repository
# ============================================================================
print_status "Step 3: Cloning LFG-S repository..."

if [ -d "LFG-S" ]; then
    print_warning "LFG-S directory already exists. Pulling latest changes..."
    cd LFG-S
    git pull origin master || print_warning "Could not pull latest changes (authentication may be needed)"
    cd ..
else
    print_status "Cloning LFG-S repository..."
    git clone https://github.com/girishlikesbutter/LFGs.git LFG-S
    print_success "LFG-S repository cloned"
fi

# ============================================================================
# Step 4: Set up Python Environment
# ============================================================================
print_status "Step 4: Setting up Python environment..."

cd LFG-S

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    print_status "Creating Python virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install project dependencies
print_status "Installing project dependencies..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    print_success "Project dependencies installed"
else
    print_warning "requirements.txt not found. Installing basic dependencies..."
    pip install numpy pandas matplotlib torch scikit-learn
fi

# Install project in development mode
if [ -f "setup.py" ]; then
    print_status "Installing LFG-S package in development mode..."
    pip install -e .
    print_success "LFG-S package installed"
fi

# ============================================================================
# Step 5: Create Context Documents
# ============================================================================
print_status "Step 5: Creating context documents for Claude..."

# Create the Claude context document
cat > CLAUDE_CONTEXT.md << 'EOF'
# LFG-S Project Context for Claude

## Project Overview
LFG-S (Low Fidelity Generator with Shadowing) is a fast light curve generator augmented with machine-learned shadowing for RSO (Resident Space Object) characterization and data association.

## Current Status
- ✅ **Project Structure Created**: Modular architecture implemented
- ✅ **Code Migration**: Both low-fidelity and high-fidelity generators integrated
- ✅ **Data Consolidation**: SPICE kernels, 3D models, observations centralized
- ✅ **Neural Network Framework**: Placeholder LSM implementation ready
- ✅ **Git Repository**: Project pushed to GitHub
- 🔄 **Next Phase**: HFG optimization and parallelization (PRD Week 1-2)

## Architecture Overview

### Module Structure
```
LFG-S/
├── src/
│   ├── core/              # Shared utilities (geometry, BRDF, spacecraft models)
│   ├── low_fidelity/      # Fast analytical light curve generator  
│   ├── high_fidelity/     # Blender interface and shadowing calculator
│   ├── learned_shadowing/ # Neural network for shadowing prediction
│   └── lfg_s/            # Integrated engine combining LFG + LSM
├── data/                  # SPICE kernels, 3D models, observations
├── tests/                 # Comprehensive test framework
├── scripts/              # Batch processing and training scripts
└── examples/             # Usage examples and demos
```

### Key Components

1. **Core Module** (`src/core/`):
   - `geometry.py`: SPICE-based orbital mechanics and coordinate transformations
   - `brdf.py`: Ashikhmin-Shirley BRDF calculations for light scattering
   - `spacecraft_models.py`: Spacecraft geometry definitions (Face, Component, Spacecraft classes)

2. **Low Fidelity Module** (`src/low_fidelity/`):
   - `lcg_engine.py`: Fast analytical light curve generator using geometric face models
   - Performs sub-second light curve generation without ray-tracing

3. **High Fidelity Module** (`src/high_fidelity/`):
   - `blender_interface.py`: Blender API wrapper for 3D rendering
   - `shadowing_calculator.py`: Automated shadowing data generation for LSM training
   - Critical for Phase 1: HFG optimization and parallelization

4. **Learned Shadowing Module** (`src/learned_shadowing/`):
   - `neural_network.py`: MLP architecture optimized for sub-millisecond inference
   - `training.py`: Complete training pipeline for LSM
   - Target: <2% error, <1ms inference time

5. **LFG-S Engine** (`src/lfg_s/`):
   - `engine.py`: Integrated system combining LFG speed with LSM shadowing accuracy
   - Target: <5% performance overhead vs. base LFG

## Development Workflow

### Current PRD Phase: Week 1-2 (HFG Optimization)
**Priority**: Parallelize the High-Fidelity Generator for 10x+ speedup

#### Key Tasks:
1. **Analyze HFG bottlenecks** in `src/high_fidelity/blender_interface.py`
2. **Implement parallelization** in `src/high_fidelity/shadowing_calculator.py`
3. **Target**: Reduce shadowing dataset generation from days to hours
4. **Validation**: Benchmark speedup with comprehensive test cases

### Key File Locations
- **PRD**: `docs/PRD.md` - Complete 8-week development plan
- **Main Config**: `data/kernels/metakernel.tm` - SPICE kernel configuration
- **3D Models**: `data/models/intelsat901/` - Test spacecraft geometry
- **Test Data**: `data/observations/observations.txt` - Jovan's observational data

### Important Commands
```bash
# Activate environment
source venv/bin/activate

# Install in development mode
pip install -e .

# Run tests
pytest tests/

# Start development
cd LFG-S
claude
```

### Next Steps After HFG Optimization
1. **Shadowing Data Generation** (Week 3)
2. **LSM Training** (Week 4-5) 
3. **Integration & Validation** (Week 6-7)
4. **Applications Demo** (Week 8)

## Architecture Decisions Made

1. **Modular Design**: Clean separation enables independent development and testing
2. **HTTPS + Token**: Git authentication via Personal Access Token for VM flexibility  
3. **PyTorch**: Chosen for LSM implementation due to inference speed optimization
4. **HDF5**: Selected for shadowing dataset storage (efficient large-scale data handling)
5. **Ashikhmin-Shirley BRDF**: Physically accurate while computationally efficient

## Development Environment
- **Python**: 3.8+ with virtual environment
- **Key Dependencies**: torch, numpy, pandas, spiceypy, bpy (Blender), matplotlib
- **Git**: Configured with token-based authentication
- **Claude Code**: Installed and ready for development tasks

## Critical Success Metrics (from PRD)
- **HFG Speedup**: 10x+ improvement (days → hours)
- **LSM Accuracy**: <2% mean error vs. HFG ground truth  
- **LFG-S Performance**: <5% overhead vs. base LFG
- **Final Demo**: Successful data association and articulation detection

## Getting Started
1. Read `docs/PRD.md` for complete project requirements
2. Review module documentation in respective `__init__.py` files
3. Start with HFG optimization tasks as highest priority
4. Use `pytest` for testing, `pip install -e .` for development installs

Remember: The goal is breaking the speed-vs-accuracy trade-off by decoupling expensive ray-tracing (done once, offline) from runtime generation (sub-second with learned shadowing).
EOF

print_success "Claude context document created"

cd ..

# ============================================================================
# Step 6: Create Git Authentication Setup Script
# ============================================================================
print_status "Step 6: Creating git authentication setup script..."

cat > setup_git_auth.sh << 'EOF'
#!/bin/bash

# ============================================================================
# Git Authentication Setup for LFG-S
# ============================================================================
# This script configures git authentication using a Personal Access Token
# ============================================================================

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "Setting up Git authentication for LFG-S..."

# Check if token file exists
if [ ! -f ".github_token" ]; then
    print_error "GitHub token file not found!"
    echo "Please create .github_token file with your Personal Access Token:"
    echo "  echo 'your_token_here' > .github_token"
    echo "  chmod 600 .github_token"
    exit 1
fi

# Check token file permissions
if [ "$(stat -c %a .github_token)" != "600" ]; then
    print_warning "Setting secure permissions on token file..."
    chmod 600 .github_token
fi

# Navigate to LFG-S directory
if [ ! -d "LFG-S" ]; then
    print_error "LFG-S directory not found. Please run setup_lfgs_vm.sh first."
    exit 1
fi

cd LFG-S

# Configure git remote with token
print_success "Configuring git remote with authentication..."
TOKEN=$(cat ../.github_token)
git remote set-url origin https://girishlikesbutter:$TOKEN@github.com/girishlikesbutter/LFGs.git

# Test git access
print_success "Testing git access..."
if git ls-remote origin > /dev/null 2>&1; then
    print_success "Git authentication configured successfully!"
    print_success "You can now push/pull to the repository."
else
    print_error "Git authentication test failed. Please check your token."
    exit 1
fi

cd ..
EOF

chmod +x setup_git_auth.sh
print_success "Git authentication setup script created"

# ============================================================================
# Step 7: Create Quick Start Guide
# ============================================================================
print_status "Step 7: Creating quick start guide..."

cat > QUICK_START.md << 'EOF'
# LFG-S Quick Start Guide

## New VM Setup

### 1. Run Master Setup
```bash
chmod +x setup_lfgs_vm.sh
./setup_lfgs_vm.sh
```

### 2. Configure Git Authentication
```bash
# Add your GitHub Personal Access Token
echo 'your_token_here' > .github_token
chmod 600 .github_token

# Run git setup
./setup_git_auth.sh
```

### 3. Start Claude Code
```bash
cd LFG-S
source venv/bin/activate
claude
```

### 4. Initialize Claude Context
When Claude starts, run:
```
Read the file CLAUDE_CONTEXT.md for full project context, then read docs/PRD.md for requirements.
```

## Development Commands

### Environment Setup
```bash
cd LFG-S
source venv/bin/activate  # Activate Python environment
```

### Development Installation
```bash
pip install -e .  # Install in development mode
```

### Testing
```bash
pytest tests/  # Run all tests
pytest tests/test_core/  # Run specific module tests
```

### Git Operations
```bash
git status  # Check status
git add .  # Stage changes
git commit -m "Your commit message"  # Commit
git push  # Push to GitHub
```

## Project Structure Reminder

- `src/core/` - Shared utilities (geometry, BRDF, spacecraft models)
- `src/low_fidelity/` - Fast analytical LCG
- `src/high_fidelity/` - Blender interface and shadowing calculator
- `src/learned_shadowing/` - Neural network for shadowing
- `src/lfg_s/` - Integrated LFG-S engine
- `data/` - SPICE kernels, 3D models, observations
- `docs/PRD.md` - Complete project requirements

## Current Priority: HFG Optimization (PRD Week 1-2)

Focus on parallelizing the High-Fidelity Generator in:
- `src/high_fidelity/shadowing_calculator.py`
- Target: 10x+ speedup for shadowing data generation
EOF

print_success "Quick start guide created"

# ============================================================================
# Step 7: Copy and Configure Validation Script
# ============================================================================
print_status "Step 7: Setting up validation script..."

# Copy validation script from LFG-S repository
if [ -f "LFG-S/scripts/setup/validate_setup.sh" ]; then
    print_status "Copying validation script from repository..."
    cp LFG-S/scripts/setup/validate_setup.sh ./validate_setup.sh
    chmod +x ./validate_setup.sh
    
    # Fix paths in validation script to work from parent directory
    print_status "Fixing paths in validation script..."
    sed -i 's|if \[ -f "\.github_token" \]|if [ -f ".github_token" ]|g' ./validate_setup.sh
    sed -i 's|if \[ -d "\.git" \]|if [ -d "LFG-S/.git" ]|g' ./validate_setup.sh
    sed -i 's|if \[ -d "venv" \]|if [ -d "LFG-S/venv" ]|g' ./validate_setup.sh
    sed -i 's|source venv/bin/activate|source LFG-S/venv/bin/activate|g' ./validate_setup.sh
    sed -i 's|if \[ -d "\$dir" \]|if [ -d "LFG-S/$dir" ]|g' ./validate_setup.sh
    sed -i 's|if \[ -f "\$file" \]|if [ -f "LFG-S/$file" ]|g' ./validate_setup.sh
    sed -i 's|if \[ -d "data/kernels" \]|if [ -d "LFG-S/data/kernels" ]|g' ./validate_setup.sh
    sed -i 's|if \[ -f "data/kernels/metakernel.tm" \]|if [ -f "LFG-S/data/kernels/metakernel.tm" ]|g' ./validate_setup.sh
    sed -i 's|if \[ -d "data/models" \]|if [ -d "LFG-S/data/models" ]|g' ./validate_setup.sh
    sed -i 's|1\. source venv/bin/activate|1. cd LFG-S|g' ./validate_setup.sh
    sed -i 's|2\. claude|2. source venv/bin/activate|g' ./validate_setup.sh
    sed -i 's|3\. Tell Claude|3. claude|g' ./validate_setup.sh
    sed -i '/3\. claude/a\    echo "  4. Tell Claude to read CLAUDE_CONTEXT.md and docs/PRD.md"' ./validate_setup.sh
    
    print_success "Validation script configured"
else
    print_warning "Validation script not found in repository"
fi

# ============================================================================
# Final Steps and Summary
# ============================================================================
print_status "Step 8: Final validation and summary..."

# Check if Python environment is working
cd LFG-S
if source venv/bin/activate && python -c "import numpy, torch; print('Dependencies working')" 2>/dev/null; then
    print_success "Python environment validated"
else
    print_warning "Python environment validation failed - may need manual dependency installation"
fi
cd ..

# Summary
echo ""
echo "=========================================="
echo "🎉 LFG-S VM Setup Complete!"
echo "=========================================="
echo ""
print_success "What was installed:"
echo "  ✅ Claude Code CLI"
echo "  ✅ System dependencies (Python, git, build tools)"
echo "  ✅ LFG-S repository cloned"
echo "  ✅ Python virtual environment created"
echo "  ✅ Project dependencies installed"
echo "  ✅ Context documents created for Claude"
echo "  ✅ Git authentication script ready"
echo ""
print_warning "Next steps:"
echo "  1. Add your GitHub token: echo 'your_token' > .github_token"
echo "  2. Run git setup: ./setup_git_auth.sh"
echo "  3. Start Claude: cd LFG-S && source venv/bin/activate && claude"
echo "  4. Initialize Claude with: Read CLAUDE_CONTEXT.md then docs/PRD.md"
echo ""
print_success "VM is ready for LFG-S development!"
echo "📚 See QUICK_START.md for development commands and workflow"
EOF
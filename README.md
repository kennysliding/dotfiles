# 🛠️ Dotfiles Architecture

A secure, zero-symlink, public dotfiles repository built with modern file-based routing and a strict split-security layer. 100% public-repository safe.

---

## 🏗️ The 2026 Stack Architecture

| Component                    | Tool                         | Responsibility                                                           |
| :--------------------------- | :--------------------------- | :----------------------------------------------------------------------- |
| **Manager**                  | `chezmoi`                    | File-based routing and machine provisioning (No symlinks)                |
| **Security (Files)**         | `age`                        | Symmetric/Asymmetric encryption for explicit files (e.g., `ssh_config`)  |
| **Security (Env Variables)** | `varlock` + Bitwarden        | Local execution-time secret injector backed by Bitwarden Secrets Manager |
| **Security (Certs/Keys)**    | Bitwarden Vault              | Secure Notes storage for raw SSH keys, API tokens, and backup age keys   |
| **Runtime & Tools**          | `mise`                       | Deterministic language and tool utility manager                          |
| **Package Manager**          | `homebrew`                   | System binaries, applications, and casks                                 |
| **Shell & Theme**            | `zsh` + `zinit` + `starship` | Blazing-fast interactive terminal environment with transient prompts     |
| **Terminal / Editor**        | Ghostty + VS Code            | Hardware-accelerated terminal paired with automatic GUI editing locks    |

---

## 🔒 Security Architecture Explained

To keep this repository entirely **public**, configurations are separated into three distinct risk vectors:

1. **Static Public Configs:** Raw files like `.zshrc` or `starship.toml` contain no secrets and are stored in plaintext.
2. **Encrypted Native Files:** High-risk routing configurations like `~/.ssh/config` are explicitly encrypted using `age` into unreadable binaries (`config.age`) before hitting GitHub. They decrypt seamlessly on authorized local hardware.
3. **Runtime Shell Secrets:** Private API tokens and environment keys are completely decoupled from Git. They are retrieved via Bitwarden Secrets Manager and bound to macOS Touch ID via `varlock`, injecting variables natively on shell execution.

---

## 🚀 Restoration & Bootstrapping Guide (New Machine)

Follow these exact steps to provision a brand-new machine from a completely blank slate.

### Phase 1: Establish System Core

Install the baseline package manager and pull in the foundational tools:

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL [https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh](https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh))"

# 2. Install core deployment utilities
brew install chezmoi age mise

```

### Phase 2: Inject Cryptographic Key

Before syncing your dotfiles, pull down your unique cryptographic signature to authorize decryption:

```bash
# 1. Create local configuration boundary
mkdir -p ~/.config/chezmoi

# 2. Re-create your local key identity
nano ~/.config/chezmoi/key.txt

```

> 🔑 **Action:** Open your **Bitwarden Vault**, find the secure note named `Chezmoi Age Key`, copy the contents, paste it into the file above, save, and exit.

### Phase 3: The Unified Bootstrap Trigger

Run the initialization string. Chezmoi will pull down the public repository, detect your local identity key, configure your local options, map files to your `$HOME`, and safely decrypt your private configurations:

```bash
chezmoi init --apply [https://github.com/YOUR_USERNAME/dotfiles.git](https://github.com/YOUR_USERNAME/dotfiles.git)

```

### Phase 4: Hydrate Runtime Secrets & Tools

Complete the environment ecosystem authorization loop:

```bash
# 1. Initialize tool versions via mise
mise run install

# 2. One-time bootstrap for local shell secrets
varlock load --path ~/.config/varlock/

```

> 💳 **Action:** Enter your Bitwarden Access Token when prompted. VarLock will automatically encrypt it local to the hardware via Apple Touch ID.

---

## 🛠️ Daily Workflow Cheat Sheet

Never manually touch, symlink, or copy files inside your home folder. Let the file router manage everything.

### Editing Existing Configurations

Chezmoi will automatically decrypt files in memory, open them in VS Code, lock execution, and safely re-encrypt them when you close the tab:

```bash
chezmoi edit ~/.zshrc
chezmoi edit ~/.ssh/config

```

### Adding New Configurations to Tracking

```bash
# Plaintext configuration
chezmoi add ~/.config/new-tool/config.toml

# Highly sensitive or private configuration
chezmoi add --encrypt ~/.ssh/config

```

### Saving Changes to GitHub

```bash
dotfiles  # Custom alias to CD into your local Chezmoi git repository
git add .
git commit -m "feat: optimize shell environment parameters"
git push origin master

```

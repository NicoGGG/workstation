#!/bin/bash
#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9C\x96${NC}"
PIN="${RED}\xF0\x9F\x93\x8C${NC}"
CLOCK="${GREEN}\xE2\x8C\x9B${NC}"
ARROW="${SEA}\xE2\x96\xB6${NC}"
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${NC}"
WARNING="${RED}\xF0\x9F\x9A\xA8${NC}"
RIGHT_ANGLE="${GREEN}\xE2\x88\x9F${NC}"

set -e

VAULT_SECRET="$HOME/.ansible-vault/vault.secret"
WORKSTATION_DIR="$HOME/.workstation"
SSH_DIR="$HOME/.ssh"
IS_FIRST_RUN="$HOME/.workstation_first_run"

# Install git
if ! dpkg -s git >/dev/null 2>&1; then
    echo -e "${ARROW} ${CYAN}Installing Git...${NC}"
    sudo apt-get install -y git 2>&1 > /dev/null
    echo -e "${ARROW} ${GREEN}Git installed!${NC}"
fi

# Install Ansible
# check lsb_release -si
if ! dpkg -s ansible >/dev/null 2>&1; then
    echo -e "${ARROW} ${CYAN}Installing Ansible...${NC}"
    echo -e "   ${RIGHT_ANGLE} ${CYAN}Updating APT Repos${NC}"
    sudo apt-get update 2>&1 > /dev/null
    echo -e "   ${RIGHT_ANGLE} ${CYAN}Installing dependency: ${YELLOW}software-properties-common${NC}"
    sudo apt-get install -y software-properties-common 2>&1 > /dev/null
    echo -e "   ${RIGHT_ANGLE} ${CYAN}Adding Ansible PPA Repo${NC}"
    sudo apt-add-repository -y ppa:ansible/ansible 2>&1 > /dev/null
    echo -e "   ${RIGHT_ANGLE} ${CYAN}Updating APT Repos${NC}"
    sudo apt-get update 2>&1 > /dev/null
    echo -e "   ${RIGHT_ANGLE} ${CYAN}Installing Ansible${NC}"
    sudo apt-get install -y ansible 2>&1 > /dev/null
    echo -e "${ARROW} ${GREEN}Ansible installed!${NC}"
    echo -e "${ARROW} ${CYAN}Installing ansible argument completion...${NC}"
    sudo apt-get install python3-argcomplete 2>&1 > /dev/null
    sudo activate-global-python-argcomplete3 2>&1 > /dev/null
fi

# Check if python3 and pip is installed
if ! dpkg -s python3 >/dev/null 2>&1; then
    echo -e "${ARROW} ${CYAN}Installing Python3...${NC}"
    sudo apt-get install -y python3 2>&1 > /dev/null
    echo -e "${ARROW} ${GREEN}Python3 installed!${NC}"
fi
if ! dpkg -s python3-pip >/dev/null 2>&1; then
    echo -e "${ARROW} ${CYAN}Installing Python3 Pip...${NC}"
    sudo apt-get install -y python3-pip 2>&1 > /dev/null
    echo -e "${ARROW} ${GREEN}Python3 Pip installed!${NC}"
fi

# Check if pip module watchdog is installed
if ! pip3 list | grep watchdog >/dev/null 2>&1; then
    echo -e "${ARROW} ${CYAN}Installing Python3 Watchdog...${NC}"
    pip3 install watchdog --break-system-packages 2>&1 > /dev/null
    echo -e "${ARROW} ${GREEN}Python3 Watchdog installed!${NC}"
fi

# Generate SSH keys
if ! [[ -f "$SSH_DIR/authorized_keys" ]]; then
    echo -e "${ARROW} ${CYAN}Generating SSH keys...${NC}"
    mkdir -p "$SSH_DIR"

    chmod 700 "$SSH_DIR"

    ssh-keygen -b 4096 -t rsa -f "$SSH_DIR/id_local" -N "" -C "$USER@$HOSTNAME" 2>&1 > /dev/null

    cat "$SSH_DIR/id_local.pub" >> "$SSH_DIR/authorized_keys"
fi

# Clone repository
if ! [[ -d "$WORKSTATION_DIR" ]]; then
    echo -e "${ARROW} ${CYAN}Cloning repository: ${YELLOW}github.com/NicoGGG/workstation${NC}"
    git clone --quiet "https://github.com/NicoGGG/workstation.git" "$WORKSTATION_DIR" 2>&1 > /dev/null
else
    echo -e "${ARROW} ${CYAN}Updating repository: ${YELLOW}github.com/NicoGGG/workstation${NC}"
    git -C "$WORKSTATION_DIR" pull --quiet > /dev/null
fi

# Create path
pushd "$WORKSTATION_DIR" 2>&1 > /dev/null

# Update Galaxy
echo -e "${ARROW} ${CYAN}Updating Galaxy...${NC}"
ansible-galaxy install -r requirements.yml 2>&1 > /dev/null

# Run playbook
echo -e "${ARROW} ${CYAN}Running playbook...${NC}"
if [[ -f $VAULT_SECRET ]]; then
    echo -e "${ARROW} ${CYAN}Using vault config file...${NC}"
    ansible-playbook --vault-password-file $VAULT_SECRET "$WORKSTATION_DIR/main.yml" "$@"
else
    echo -e "${WARNING} ${CYAN}Vault config file not found...${NC}"
    if ! [[ -f $IS_FIRST_RUN ]]; then
        mkdir -p -m 700 $HOME/.ansible-vault
    echo -e "${WARNING} ${CYAN}Create vault pass file in ~/.ansible-vault. Next time this script is executed the playbook will run even without the vault file${NC}"
    else
        ansible-playbook "$WORKSTATION_DIR/main.yml" "$@"
    fi
fi

popd 2>&1 > /dev/null

if ! [[ -f "$IS_FIRST_RUN" ]]; then
    echo -e "${CHECK_MARK} ${GREEN}First run complete!${NC}"
    echo -e "${ARROW} ${CYAN}Please reboot your computer to complete the setup.${NC}"
    touch "$IS_FIRST_RUN"
fi

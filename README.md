# My workstation config

(inspired by [TechDufus .dotfiles](https://github.com/techdufus/dotfiles) and [Omakub](https://omakub.org/))

## Install with ansible

First create the vault password file in ~/.ansible-vault/vault.secret.
Then run this command (curl needs to be installed)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NicoGGG/workstation/main/workstation.sh)"
```

With arguments (like tags)

```bash
curl -fsSL https://raw.githubusercontent.com/NicoGGG/workstation/main/workstation.sh | bash -s -- --ask-become-pass -v -t list,of,tags
```

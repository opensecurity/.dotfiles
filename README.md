# .dotfiles

dotfiles for a customized shell environment.

## clone

clone the repository to your home directory:

```bash
git clone https://github.com/opensecurity/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## install

run the installer to create backups of your existing files and set up the necessary symlinks:

```bash
./install.sh
```

after the installation, restart your shell or run `source ~/.bashrc` to apply the changes.

## history search

- **up / down arrows**: automatically matches any typed word anywhere in the command (whether it appears at the start, middle, or end).
- **`hsync`**: synchronize history across open terminal sessions.

# Automatic install of packages, apps, configs

This script performs various tasks related to package installation and configuration. It provides several command-line arguments that allow you to control its behavior. Below is a description of each argument and how they are used:

## Usage

```sh
sudo ./install_packages.sh [options]
```

## Options

- `-all`: Initialize all tasks (default option)
- `-apps`: Initialize app installations
- `-packages`: Initialize package installations
- `-actions`: Initialize custom actions (apply settings, move dotfiles, etc.)

## Examples

### Initializing All Tasks

```sh
sudo ./install_packages.sh -all
```

This command will update the system, install apps, install packages, and perform custom actions.

### Initializing App Installations

```sh
sudo ./install_packages.sh -apps
```

This command will install specified apps using predefined URLs.

### Initializing Package Installations

```sh
sudo ./install_packages.sh -packages
```

This command will install packages specified in the `INSTALL` list.

### Initializing Custom Actions

```sh
sudo ./install_packages.sh -actions
```

This command will run custom actions defined in the `actions_array`.

## Note

- The script must be run with sudo or as root.
- By default, if no arguments are provided, the script will assume `-all`.

---

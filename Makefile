#
# Dotfiles Makefile
#
# Provides commands for maintaining and verifying the integrity of the dotfiles.
#

# --- Constants ---
SHELL := /bin/bash
SHELLCHECK := $(shell command -v shellcheck)
PROJECT_FILES := install.sh uninstall.sh lib/*.sh root/bashrc root/bash_profile

# --- Targets ---

.PHONY: help lint test install uninstall

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  test        - Verify shell script syntax."
	@echo "  lint        - Statically analyze shell scripts with shellcheck."
	@echo "  install     - Run the installation script."
	@echo "  uninstall   - Run the uninstallation script."
	@echo ""

test:
	@echo "Checking syntax of shell scripts..."
	@bash -n install.sh uninstall.sh lib/*.sh root/bashrc root/bash_profile
	@echo "All shell scripts passed syntax checks."

lint:
ifndef SHELLCHECK
	@echo "Error: shellcheck is not installed. Cannot perform linting."
	@exit 1
endif
	@echo "Linting all project shell scripts..."
	@$(SHELLCHECK) $(PROJECT_FILES)
	@echo "Linting complete. No issues found."

install:
	@./install.sh

uninstall:
	@./uninstall.sh

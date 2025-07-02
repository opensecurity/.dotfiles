#
# Dotfiles Makefile
#
# Provides commands for maintaining and verifying the integrity of the dotfiles.
#

# --- Constants ---
SHELL := /bin/bash
SHELLCHECK := $(shell command -v shellcheck)
PROJECT_FILES := install.sh uninstall.sh lib/*.sh root/*

# --- Targets ---

.PHONY: help lint clean install

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  lint        - Statically analyze all shell scripts for errors."
	@echo "  install     - Run the installation script."
	@echo "  uninstall   - Run the uninstallation script."
	@echo ""

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

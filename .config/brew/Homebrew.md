# Homebrew
----

To update this list use the following command with `mas` installed to get a manifest of all things managed by Homebrew and the Mac App Store:

    brew bundle dump --force

This command will dump all packages into `Brewfile` in the current working directory. The `--force` flag is required if there is already a `Brewfile` in the current directory.
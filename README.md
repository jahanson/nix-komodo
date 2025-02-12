# nix-komodo

## Quickstart

### Install via env/profile

```nix
# Flakes
nix profile install github:jahanson/nix-komodo#

# Non-flakes
nix-env -iA nixos.radarr
```

### Running via cli

```nix
# Remote
nix run github:jahanson/nix-komodo#periphery -- --version
nix run github:jahanson/nix-komodo#komodo -- --version

# Local
nix run .#periphery -- --version
nix run .#komodo -- --version
```

## Cachix
### https://app.cachix.org/cache/hsn-flakes
[Cachix Version Pins](https://app.cachix.org/cache/hsn-flakes#pins) 

Public Key: `hsn-flakes.cachix.org-1:pFP/2u3zLEkaKR4doE07SvYcQHzDQbrdj5y5D+md0Qw=`
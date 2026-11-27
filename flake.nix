{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # Zed only: track nixpkgs master so the editor gets new stable releases
    # without moving the whole system. Bump with `nix flake update nixpkgs-zed`.
    # home.nix takes `zed-editor` from here, so we run the official stable
    # release (1.30.2+ ships `title_bar.show`, zed#65671) instead of nightly.
    nixpkgs-zed.url = "github:NixOS/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devbox = {
      url = "github:jetify-com/devbox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hyprland is pinned to the last rev that starts reliably.
    # Upstream main (6e787199, 2026-11-19) dropped the null check on
    # FULLSCREEN_WINDOW in IHyprRenderer::handleFullscreenSettings(), so any
    # monitor whose EDID advertises HDR (our DP-1 does) crashes the compositor
    # with a SIGSEGV on the first frame. Hyprland 0.57.2 in nixpkgs has the
    # same bug. Drop the rev (and run `nix flake update hyprland`) once the
    # null check is restored upstream.
    hyprland = {
      url = "github:hyprwm/Hyprland/49b566a9780413a2498b7e8b925337ddb41a41a7";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    delta = {
      url = "github:zed-industries/delta-nix";
      # use the system's graphics stack (see delta-nix README)
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Rex (stable channel isn't published yet, so use preview).
    rex = {
      url = "https://pkgs.superlogical.com/rex/nix/preview.tar.gz";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixConfig = {
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
      };
      nixosConfigurations.elfbox = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          inputs.catppuccin.nixosModules.catppuccin
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.elf-pavlik = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };
    };
}

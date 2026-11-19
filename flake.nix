{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # Zed only: track nixpkgs master so the editor gets new releases without
    # moving the whole system. Bump with `nix flake update nixpkgs-zed`.
    # Currently unused by home.nix (kept as the fallback for stable Zed, e.g.
    # once 1.30 ships `title_bar.show`).
    nixpkgs-zed.url = "github:NixOS/nixpkgs";
    # Zed Nightly (upstream package) — the stable channel in nixpkgs-zed lagged
    # behind `title_bar.show` (zed#65671). This rev is already built and served
    # by https://zed.cachix.org (see nix.settings in configuration.nix); bumping
    # it to a rev that is not cached means a multi-hour Rust build, so change
    # the rev deliberately and then run `nix flake update zed`.
    zed.url = "github:zed-industries/zed/f693ad0847e4faacd7d630fc78c54695bb862266";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devbox = {
      url = "github:jetify-com/devbox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
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

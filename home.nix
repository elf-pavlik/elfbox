{ config, pkgs, system, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "elf-pavlik";
  home.homeDirectory = "/home/elf-pavlik";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  programs.git = {
    enable = true;
    userEmail = "elf-pavlik@hackers4peace.net";
    userName = "elf-pavlik";
  };

  programs.neovim.enable = true;

  programs.kitty.enable = true; # required for the default Hyprland config

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      exec-once = [
        "kitty"
      ];
    };
  };

  # Optional, hint Electron apps to use Wayland:
  # home.sessionVariables.NIXOS_OZONE_WL = "1";
}


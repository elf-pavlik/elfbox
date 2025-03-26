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
    nodejs
    pavucontrol
    yazi
  ];

  programs.git = {
    enable = true;
    userEmail = "elf-pavlik@hackers4peace.net";
    userName = "elf-pavlik";
  };

  programs.neovim.enable = true;

  programs.ghostty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "ghostty"
        "[workspace 1 silent] zen"
      ];
      "$mod" = "SUPER";
      bind = [
        "$mod, Q, exec, ghostty"
        "$mod, X, killactive"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, J, movewindow, l"
        "$mod, K, movewindow, r"
        "$mod, u, workspace, 1"
        "$mod, i, workspace, 2"
        "$mod, o, workspace, 3"
        "$mod, p, workspace, 4"
        "$mod SHIFT, u, movetoworkspace, 1"
        "$mod SHIFT, i, movetoworkspace, 2"
        "$mod SHIFT, o, movetoworkspace, 3"
        "$mod SHIFT, p, movetoworkspace, 4"
      ];
    };
  };

  # Optional, hint Electron apps to use Wayland:
  # home.sessionVariables.NIXOS_OZONE_WL = "1";
}

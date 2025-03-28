{ config, pkgs, system, inputs, ... }:

{

  imports = [
    inputs.ags.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
  ];
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
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.system}.default
    pavucontrol
    yazi
    inputs.ags.packages.${pkgs.system}.io
    inputs.ags.packages.${pkgs.system}.notifd
    discord-canary
    devbox
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    keymapp
  ];

  programs.git = {
    enable = true;
    userEmail = "elf-pavlik@hackers4peace.net";
    userName = "elf-pavlik";
    aliases = {
      fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
      l = "log --graph --decorate --pretty=oneline --abbrev-commit";
    };
  };

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    plugins.lsp.servers = {
      ts_ls.enable = true;
      nixd.enable = true;
      turtle_ls.enable = true;
      volar.enable = true;
      yamlls.enable = true;
      pylsp.enable = true;
      lua_ls.enable = true;
      html.enable = true;
      dockerls.enable = true;
    };
  };

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "ghostty"
        "[workspace 1 silent] zen"
	"ags run"
      ];
      "$mod" = "SUPER";
      bind = [
        "$mod, Q, exec, ghostty"
        "$mod, R, exec, ags toggle launcher --instance launcher"
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

  programs.ags = {
    enable = true;
    configDir = ./ags;
    extraPackages = with pkgs; [
      inputs.ags.packages.${pkgs.system}.apps
   ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "ls -l";
    };
    history.size = 10000;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 1300;
      scan_timeout = 50;
      format = "$all$nix_shell$nodejs$lua$golang$rust$php$git_branch$git_commit$git_state$git_status\n$username$hostname$directory";
      git_branch = {
        symbol = " ";
      };
      character = {
        success_symbol = "[](bold green) ";
        error_symbol = "[✗](bold red) ";
      };
    }; 
  };
}

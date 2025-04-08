{ config, pkgs, system, inputs, ... }:

{
  imports = [
    inputs.ags.homeManagerModules.default
    inputs.LazyVim.homeManagerModules.default
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
  xdg.enable = true;

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
    transmission_4-gtk
    cameractrls-gtk4
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  programs.git = {
    enable = true;
    userEmail = "elf-pavlik@hackers4peace.net";
    userName = "elf-pavlik";
    aliases = {
      fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
      l = "log --graph --decorate --pretty=oneline --abbrev-commit";
    };
  };

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-size = 15;
      font-family = "FiraCode Nerd Font";
      window-padding-x = 10;
      window-padding-y = 10;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      decoration = {
        rounding = 20;
      };
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

  programs.lazyvim = {
    enable = true;
    plugins = with pkgs; [
      vimPlugins.vim-tmux-navigator
    ];
    pluginsFile."plugins.lua".source = ./plugins.lua;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    aggressiveResize = true;
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.catppuccin
    ];

    extraConfig = ''
      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      # Mouse works as expected
      set-option -g mouse on
      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Theme
      set -g @catppuccin_flavor 'mocha'
      set -g @catppuccin_window_status_style 'rounded'
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"
    '';
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };

  programs.chromium.enable = true;

  programs.mpv = {
    enable = true;
    
    package = (
      pkgs.mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
        ];
    
        mpv = pkgs.mpv-unwrapped.override {
          waylandSupport = true;
        };
      }
    );
    
    config = {
      profile = "high-quality";
    };
  };
}

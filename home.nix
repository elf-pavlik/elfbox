{ config, pkgs, system, inputs, ... }:

{
  imports = [
    inputs.LazyVim.homeManagerModules.default
    inputs.walker.homeManagerModules.default
    inputs.catppuccin.homeModules.catppuccin
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
    discord-canary
    devbox
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    keymapp
    transmission_4-gtk
    cameractrls-gtk4
    p7zip
    grim
    slurp
    wl-clipboard
    lima
    fastfetch
    amdgpu_top
    glances
    spacedrive
    taskwarrior-tui
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  catppuccin = {
      enable = true;
      flavor = "macchiato";
  };

  programs.git = {
    enable = true;
    userEmail = "elf-pavlik@hackers4peace.net";
    userName = "elf-pavlik";
    aliases = {
      fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
      l = "log --graph --decorate --pretty=oneline --abbrev-commit";
    };
    ignores = [
      "devbox.json"
      "devbox.lock"
    ];
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "elf-pavlik@hackers4peace.net";
        name = "elf Pavlik";
      };
      ui = {
        default-command = "log";
      };
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
      background-opacity = 0.8;
    };
  };

  services.ssh-agent = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  programs.keepassxc = {
    enable = true;
    settings = {
      General. ConfigVersion = 2;
      Browser.Enabled = true;
      GUI = {
        ApplicationTheme = "dark";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  programs.gpg = {
    enable = true;
  };

  services.swayosd = {
    enable = true;
  };

  programs.mpvpaper.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      decoration = {
        rounding = 20;
      };
      cursor = {
        inactive_timeout = 2;
        hide_on_key_press = true;
      };
      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
      };
      exec-once = [
        "[workspace 1 silent] qutebrowser"
        "[workspace 2 silent] ghostty"
        "mpvpaper -o 'no-audio --loop-file=inf --panscan=1.0 --hwdec=auto' DP-1 ~/backgrounds/dragon.mp4"
      ];
      "$mod" = "SUPER";
      bind = [
        "$mod, Q, exec, ghostty"
        "$mod, R, exec, walker"
        "$mod, S, exec, grim -g \"$(slurp -d)\" - | wl-copy"
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
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume 10"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -10"
        ", XF86AudioMute , exec, swayosd-client --output-volume mute-toggle"
        "$mod, XF86AudioRaiseVolume, exec, ddcutil -d 1 setvcp 10 + 10"
        "$mod, XF86AudioLowerVolume, exec, ddcutil -d 1 setvcp 10 - 10"
        "$mod, F10, pass, class:^(com\.obsproject\.Studio)$"
        "$mod, F11, pass, class:^(com\.obsproject\.Studio)$"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      ll = "ls -l";
    };
    initContent = ''
      source <(COMPLETE=zsh jj)
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux = {
      enableShellIntegration = true;
    };
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

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  programs.neovim = {
    defaultEditor = true;
    extraPackages = with pkgs; [
      typescript-language-server
      vue-language-server
    ];
  };

  programs.lazyvim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-tmux-navigator
      nvim-lspconfig
      avante-nvim
      render-markdown-nvim
      mini-surround
      neogit
      diffview-nvim
      plenary-nvim
      multicursors-nvim
    ];
    extras = {
      coding = {
        mini-surround.enable = true;
      };
      lang = {
        nix.enable = true;
        typescript.enable = true;
      };
    };
    pluginsFile."vim-tmux-navigator.lua".source = ./vim-tmux-navigator.lua;
    pluginsFile."lspconfig.lua".source = ./lspconfig.lua;
    pluginsFile."avante.lua".source = ./avante.lua;
    pluginsFile."catppuccin.lua".source = ./catppuccin.lua;
    pluginsFile."neogit.lua".source = ./neogit.lua;
    pluginsFile."multicursors.lua".source = ./multicursors.lua;
  };

  programs.ripgrep.enable = true;

  programs.tmux = {
    enable = true;
    shortcut = "a";
    aggressiveResize = true;
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      vim-tmux-navigator
    ];

    extraConfig = ''
      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"
      set-option -g status-position top

      # Mouse works as expected
      set-option -g mouse on
      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Theme
      set -g @catppuccin_window_status_style 'rounded'
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      #set -ag status-right "#{E:@catppuccin_status_uptime}"
    '';
  };

  programs.sesh = {
    enable = true;
    enableTmuxIntegration = true;
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };

  programs.obs-studio.package = pkgs.obs-studio.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "obsproject";
      repo = "obs-studio";
      rev = "12c6febae21f369da50f09d511b54eadc1dc1342"; # https://github.com/obsproject/obs-studio/pull/11906
      sha256 = "sha256-DIlAMCdve7wfbMV5YCd3qJnZ2xwJMmQD6LamGP7ECOA=";
      fetchSubmodules = true;
    };
    version = "31.1.0-beta1";
    patches = builtins.filter (
      patch:
      !(
        builtins.baseNameOf (toString patch) == "Enable-file-access-and-universal-access-for-file-URL.patch"
      )
    ) oldAttrs.patches;
  });

  programs.chromium.enable = true;

  programs.qutebrowser = {
    enable = true;

    settings = {
      tabs.show = "never";
      statusbar.show = "always";
      colors.webpage.preferred_color_scheme = "dark";
      editor.command = ["ghostty" "-e" "nvim" "{file}" "+startinsert" "+call cursor({line}, {column})"];
    };
    keyBindings = {
      normal = {
        "pw" = "spawn --userscript qute-keepassxc --key 379559042C492245";
      };
      insert = {
        "<Alt-Shift-u>" = "spawn --userscript qute-keepassxc --key 379559042C492245";
      };
    };
  };

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

  programs.taskwarrior = {
    enable = true;
  };

  gtk.enable = true;

  catppuccin = {
    gtk = {
      enable = true;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style = {
      name = "kvantum";
      catppuccin = {
        enable = true;
        apply = true;
        flavor = "macchiato";
        accent = "blue";
      };
    };
  };
}

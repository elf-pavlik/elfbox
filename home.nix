{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
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
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
  xdg.enable = true;

  home.packages = with pkgs; [
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
    libnotify
    neovim
    nodejs
    python3
    clang-tools
    gcc
    gnumake
    tree-sitter
    unzip
    wget
    cargo
    libreoffice
    pinta
    bruno
    kdePackages.kdenlive
    unison-ucm
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    kvantum = {
      enable = true;
      apply = true;
      flavor = "macchiato";
      accent = "blue";
    };
  };

  xdg.configFile."nvim".source = ./nvim;

  programs.git = {
    enable = true;
    ignores = [
      "devbox.json"
      "devbox.lock"
    ];
    settings = {
      user.email = "elf-pavlik@hackers4peace.net";
      user.name = "elf Pavlik";
      alias = {
        fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
        l = "log --graph --decorate --pretty=oneline --abbrev-commit";
        s = "show --ext-diff";
      };
      init = {
        defaultBranch = "main";
      };
      gpg.format = "ssh";
      "gpg \"ssh\"".defaultKey = "/home/elf-pavlik/.ssh/id_ed25519.pub";
      user.signingkey = "/home/elf-pavlik/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
    };
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

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
-- Pull in the wezterm API
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- or, changing the font size and color scheme.
config.font_size = 15
config.color_scheme = 'Catppuccin Macchiato'
config.window_background_opacity = 0.8
config.font = wezterm.font 'FiraCode Nerd Font'
config.enable_tab_bar = false
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = 'Space', mods = 'ALT', timeout_milliseconds = 1000 }
config.keys = {
  { key = ',', mods = 'LEADER', action = wezterm.action.ShowTabNavigator },
  { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) },
  { key = '0', mods = 'LEADER', action = wezterm.action.ActivateTab(0) },
  { key = '1', mods = 'LEADER', action = wezterm.action.ActivateTab(1) },
  { key = '2', mods = 'LEADER', action = wezterm.action.ActivateTab(2) },
  { key = '3', mods = 'LEADER', action = wezterm.action.ActivateTab(3) },
  { key = '4', mods = 'LEADER', action = wezterm.action.ActivateTab(4) },
}
local workspace_picker = wezterm.plugin.require("https://github.com/isseii10/workspace-picker.wezterm")
workspace_picker.setup({
  zoxide_path = "${pkgs.zoxide}/bin/zoxide",
	labels = {
		workspace = "",
		zoxide = "",
		current = "",
	},
	colors = {
		workspace_prefix = "#cdd6f4",
		zoxide_prefix = "#cdd6f4",
		current_indicator = "#cdd6f4",
		text = "#cdd6f4",
		path = "#6c7086",
	},
})
workspace_picker.apply_to_config(config)

-- Finally, return the configuration to wezterm:
return config
    '';
  };

  programs.television = {
    enable = true;
    enableZshIntegration = true;
  };

  services.ssh-agent = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks."*".addKeysToAgent = "yes";
  };

  programs.keepassxc = {
    enable = true;
    settings = {
      General.ConfigVersion = 2;
      Browser.Enabled = true;
      GUI = {
        ApplicationTheme = "dark";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
  };

  programs.gpg = {
    enable = true;
  };

  services.swayosd = {
    enable = true;
  };

  services.systembus-notify.enable = true;

  services.swaync = {
    enable = true;
  };

  programs.mpvpaper.enable = true;
  programs.hyprshot.enable = true;
  programs.satty.enable = true;

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
        "$mod, S, exec, hyprshot -m region --raw | satty --filename -"
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

  programs.ripgrep.enable = true;
  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
  };

  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = true;
        use_pager = true;
      };
      updates = {
        auto_update = false;
      };
    };
  };

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      diffToolMode = true;
    };
    options = {
      color = "always";
      display = "side-by-side-show-both";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      ll = "ls -l";
      cat = "bat --paging=never --style=plain";
    };
    initContent = ''
      EDITOR=nvim
      source <(COMPLETE=zsh jj)

      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
        dbus-run-session Hyprland
      fi
    '';
  };

  programs.atuin = {
    enable = false;
    enableZshIntegration = true;
    settings = {
      keymap_mode = "vim-normal";
    };
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

  programs.tmux = {
    enable = true;
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

      # Unbind default prefix and set Alt+Space
      unbind C-b
      set -g prefix M-Space

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

  programs.opencode = {
    enable = true;
    settings = {
      theme = "catppuccin-macchiato";
      autoupdate = false;
      small_model = "opencode/minimax-m2.5-free";
      mcp = {
        container-use = {
          type = "local";
          command = ["container-use" "stdio"];
          enabled = true;
        };
      };
    };
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

  programs.qutebrowser = {
    enable = true;

    settings = {
      tabs.show = "never";
      statusbar.show = "always";
      colors.webpage.preferred_color_scheme = "dark";
      editor.command = [
        "ghostty"
        "-e"
        "nvim"
        "{file}"
        "+startinsert"
        "+call cursor({line}, {column})"
      ];
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

    config = {
      profile = "high-quality";
    };
  };

  programs.taskwarrior = {
    enable = true;
  };
  gtk = {
    enable = true;

    gtk3.theme = {
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        accents = [ "blue" ];
        size = "standard";
      };
      name = "catppuccin-macchiato-blue-standard";
    };
    gtk4.theme = {
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        accents = [ "blue" ];
        size = "standard";
      };
      name = "catppuccin-macchiato-blue-standard";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style = {
      name = "kvantum";
    };
  };

  programs.trippy = {
    enable = true;
    settings = {
      bindings = {
        toggle-help = "h";
        toggle-help-alt = "?";
        toggle-settings = "s";
        toggle-settings-dns = "3";
        toggle-settings-geoip = "4";
        toggle-settings-trace = "2";
        toggle-settings-tui = "1";
      };
      theme-colors = {
        bg-color = "black";
        border-color = "gray";
        tab-text-color = "green";
        text-color = "gray";
      };
    };
  };
}

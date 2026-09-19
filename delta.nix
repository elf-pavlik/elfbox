# delta.nix — runtime environment for the official "Delta" (Zed Industries)
# prebuilt bundle at ~/.local/delta.app.
#
# Import from home.nix:  imports = [ ./delta.nix ];
#
# The bundle ships its own libxcb/libxkbcommon/... (via RPATH $ORIGIN/../lib)
# but dlopens wayland / vulkan / libglvnd from the system at startup —
# without them it panics with "NoWaylandLib" (gpui). NixOS also has no
# /usr/share/X11/xkb, so libxkbcommon needs XKB_CONFIG_ROOT for keyboards.
#
# This module:
#   1. replaces ~/.local/bin/delta with a small wrapper that exports the env
#      and execs the bundle — works from any shell, no re-login needed
#   2. also exports the same vars at the session level (menu launches etc.)
{
  pkgs,
  lib,
  ...
}:

let
  deltaLibs = [
    # essentials (dlopen'd by the binary):
    pkgs.wayland # libwayland-client.so.0, libwayland-egl.so.1
    pkgs.vulkan-loader # libvulkan.so.1
    pkgs.libglvnd # libEGL.so.1
    # belt & suspenders (matches the install requirements; harmless):
    pkgs.fontconfig
    pkgs.libxkbcommon
    pkgs.libx11
    pkgs.libxcb
    # xkeyboard-config is data, not a library — consumed via XKB_CONFIG_ROOT
  ];

  deltaEnv = ''
    # --- env for the Delta prebuilt bundle (managed by delta.nix) ---
    export LD_LIBRARY_PATH="${lib.makeLibraryPath deltaLibs}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export XKB_CONFIG_ROOT="${pkgs.xkeyboard-config}/share/X11/xkb"
    # Use the "real" user bus ($XDG_RUNTIME_DIR/bus), not the private
    # dbus-run-session bus of the Hyprland session: the Secret Service
    # (KeePassXC FdoSecrets) only lives on the former, so without this
    # Delta can't reach the keychain.
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
  '';

  deltaBundledBinary = "$HOME/.local/delta.app/bin/delta";

  deltaWrapper = pkgs.writeShellScriptBin "delta" (
    deltaEnv
    + ''
      # use the installed bundle if present, otherwise fail loudly
      if [ ! -x "${deltaBundledBinary}" ]; then
        echo "delta: bundle not found at ${deltaBundledBinary}" >&2
        exit 1
      fi
      exec "${deltaBundledBinary}" "$@"
    ''
  );
in
{
  # replaces the install.sh symlink, so `delta` in any shell gets the env
  # (force = true: overwrite the pre-existing symlink from the manual
  # install.sh — home-manager otherwise refuses to clobber it)
  home.file.".local/bin/delta" = {
    source = "${deltaWrapper}/bin/delta";
    executable = true;
    force = true;
  };

  home.sessionVariables = {
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard-config}/share/X11/xkb";
    LD_LIBRARY_PATH = lib.makeLibraryPath deltaLibs;
  };
}
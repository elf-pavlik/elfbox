# delta.nix — glue for the official Delta package
# (github:zed-industries/delta-nix, added as the `delta` flake input).
#
# Import from home.nix:  imports = [ ./delta.nix ];
#
# The upstream package already takes care of everything the previous
# hand-rolled module did: runtime library paths (wayland / vulkan / libglvnd /
# xcb …), a libxkbcommon that knows NixOS' xkeyboard-config, desktop entries,
# and an updater disabled with a "managed by Nix" notice. New releases come
# from `nix flake update delta` — no more re-running the vendor install.sh.
#
# What is left here is a single environment quirk: Hyprland is started through
# `dbus-run-session start-hyprland` (home.nix, programs.zsh.initContent), so
# everything launched inside the session talks to a *private* D-Bus session
# bus. KeePassXC's FdoSecrets (org.freedesktop.secrets) registers on the
# systemd user bus instead, so Delta has to be pointed at that bus
# ($XDG_RUNTIME_DIR/bus) to reach the keychain. Wrapping the binaries keeps the
# package's own wrappers (LD_LIBRARY_PATH etc.) intact, and the desktop entries
# are retargeted at the wrapper so menu launches get the same environment.
#
# If the session ever stops using dbus-run-session (i.e. runs on the real user
# bus), this module can be deleted and the package added to home.packages
# directly.
{
  pkgs,
  inputs,
  ...
}:

let
  delta = inputs.delta.packages.${pkgs.stdenv.hostPlatform.system}.delta;

  deltaWrapped = pkgs.runCommand "delta-keychain-bus" { } ''
    mkdir -p $out
    cp -a ${delta}/. $out/
    chmod -R u+w $out

    # bin/delta (and bin/delta-app on paired-binary releases) are makeWrapper
    # scripts; keep them as-is and put a thin shim in front.
    for bin in delta delta-app; do
      [ -e "$out/bin/$bin" ] || continue
      mv "$out/bin/$bin" "$out/bin/.$bin-unwrapped"
      cat > "$out/bin/$bin" <<EOF
#!${pkgs.runtimeShell}
# managed by delta.nix — see the header of that file
export DBUS_SESSION_BUS_ADDRESS="unix:path=\$XDG_RUNTIME_DIR/bus"
exec "$out/bin/.$bin-unwrapped" "\$@"
EOF
      chmod +x "$out/bin/$bin"
    done

    for desktop in "$out"/share/applications/*.desktop; do
      substituteInPlace "$desktop" --replace-fail "${delta}" "$out"
    done
  '';
in
{
  home.packages = [ deltaWrapped ];
}

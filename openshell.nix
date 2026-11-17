# openshell.nix — OpenShell v0.1.7 (CLI, gateway, MicroVM driver) from
# NVIDIA's prebuilt release binaries.
#
# Facts that shaped this module:
#   1. github:NVIDIA/OpenShell has no `openshell` package output — that flake
#      only exposes devShells plus CI artifact builders (tmachine, vm-runtime,
#      build-artifacts-*), so there is nothing to take from it.
#   2. nixpkgs ships `openshell` (pkgs/by-name/op/openshell), but CLI-only and
#      built from the upstream v0.0.116 tag, which is behind upstream. Its
#      recipe does work with a newer tag, but compiling the workspace costs
#      20+ minutes per bump.
#
# So this overlay swaps in the binaries NVIDIA publishes per release (see
# https://docs.nvidia.com/openshell/latest/about/installation):
#   * openshell          — static musl PIE, so no patchelf / interpreter /
#                          glibc floor to worry about.
#   * openshell-gateway  — glibc build linking only libc/libm/librt/
#                          libpthread/libdl, so autoPatchelfHook is enough.
#   * openshell-driver-vm, openshell-supervisor — same, and they are installed
#                          *beside* the gateway on purpose: the gateway resolves
#                          the VM driver as a sibling of its own executable
#                          (after driver_dir and ~/.local/libexec/openshell), so
#                          no driver_dir configuration is needed.
# All binaries are version-checked at build time against `version`.
#
# Two gateways, because `compute_driver` selects exactly one driver:
#   * openshell-gateway     — default instance, auto-detects kubernetes →
#                             podman → docker; port 17670, upstream's unit.
#   * openshell-gateway-vm  — second instance pinned to compute_driver = "vm"
#                             on port 17671 with its own SQLite DB and driver
#                             state. The MicroVM driver is NVIDIA's own
#                             libkrun-based VM (KVM on Linux), not microvm.nix.
#
# Register them once each (the CLI is in home.nix's home.packages):
#
#   openshell gateway add https://127.0.0.1:17670 --local --name openshell
#   openshell gateway add https://127.0.0.1:17671 --local --name openshell-vm
#
# The overlay is NixOS-level because home-manager runs with
# `useGlobalPkgs = true` and therefore ignores its own nixpkgs.overlays.
#
# To bump `version`, refresh the hashes of all eight assets:
#   nix store prefetch-file --json \
#     https://github.com/NVIDIA/OpenShell/releases/download/v<version>/<file>
#
# Delete this module and the import in configuration.nix once the nixpkgs pin
# is >= version.
{
  pkgs,
  lib,
  ...
}:

let
  version = "0.1.7";

  # Default sandbox/bootstrap image for the VM driver. The driver refuses to
  # start when both default_image and bootstrap_image are empty.
  vmImage = "nvcr.io/nvidia/base/ubuntu:24.04";

  # The VM gateway must not share the default instance's port or SQLite DB.
  vmPort = 17671;
  # %S is $XDG_STATE_HOME for user units; matches StateDirectory= below.
  vmStateDir = "%S/openshell/gateway-vm";

  # Release assets per Nix system.
  targets = {
    x86_64-linux = {
      cli = {
        file = "openshell-x86_64-unknown-linux-musl.tar.gz";
        binary = "openshell";
        hash = "sha256-XBrfyueX6smy6LkoDGbB915OhNnjHOaTjFuZQxTvYJg=";
      };
      gateway = {
        file = "openshell-gateway-x86_64-unknown-linux-gnu.tar.gz";
        binary = "openshell-gateway";
        hash = "sha256-4XFNz9hclJ4vUyYLz78EsgP29cvTph5hwRw4y8kcsQI=";
      };
      driverVm = {
        file = "openshell-driver-vm-x86_64-unknown-linux-gnu.tar.gz";
        binary = "openshell-driver-vm";
        hash = "sha256-+zUPBCVG78nA7PAL1Z0/lsIzZ/xFAYP42XMm+t0STiE=";
      };
      supervisor = {
        file = "openshell-supervisor-x86_64-unknown-linux-gnu.tar.gz";
        binary = "openshell-supervisor";
        hash = "sha256-ozkDtCqDM95z9KDwUbBHdVnGMs8xGIyu7QBktMIEhgE=";
      };
    };
    aarch64-linux = {
      cli = {
        file = "openshell-aarch64-unknown-linux-musl.tar.gz";
        binary = "openshell";
        hash = "sha256-aWtSPCY4lbaeqnx+avuxm4r2xlzXnH/6x7aFtuOqI9o=";
      };
      gateway = {
        file = "openshell-gateway-aarch64-unknown-linux-gnu.tar.gz";
        binary = "openshell-gateway";
        hash = "sha256-6wupHv67zGHkz65fsYk0xf4wjs4aCboWyZnQDEUhCdw=";
      };
      driverVm = {
        file = "openshell-driver-vm-aarch64-unknown-linux-gnu.tar.gz";
        binary = "openshell-driver-vm";
        hash = "sha256-SQmThy/zHQ+Iag/QEji/hJi7ZPbZ32TbaBIec2xpy8I=";
      };
      supervisor = {
        file = "openshell-supervisor-aarch64-unknown-linux-gnu.tar.gz";
        binary = "openshell-supervisor";
        hash = "sha256-CV1WHfnqQOCvVdjTZFzRPubvn5LSzNK3jXb6rsTeyfM=";
      };
    };
  };

  # Renders the VM gateway's TOML at service start. grpc_endpoint and
  # guest_tls_ca are deliberately omitted: the gateway derives the former from
  # its own port and fills the latter from the local TLS bundle.
  vmConfig = pkgs.writeShellScript "openshell-gateway-vm-config" ''
    set -eu
    export PATH=${pkgs.coreutils}/bin:$PATH
    : "''${OPENSHELL_VM_STATE_DIR:?OPENSHELL_VM_STATE_DIR must be set}"

    mkdir -p -m 0700 "$OPENSHELL_VM_STATE_DIR"
    cat > "$OPENSHELL_VM_STATE_DIR/gateway.toml" <<EOF
    [openshell]
    version = 2

    [openshell.gateway]
    bind_address   = "127.0.0.1:${toString vmPort}"
    log_level      = "info"
    # Never auto-detected; an explicit entry is required for the VM driver.
    compute_driver = "vm"

    [openshell.drivers.vm]
    state_dir       = "$OPENSHELL_VM_STATE_DIR/vm-driver"
    default_image   = "${vmImage}"
    bootstrap_image = "${vmImage}"
    vcpus           = 2
    mem_mib         = 2048
    EOF
  '';
in
{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        inherit (prev.stdenv.hostPlatform) system;
        release = targets.${system} or (throw "openshell.nix: no release asset for ${system}");

        # Every release tarball holds exactly one executable at its root, and
        # the file names do not collide, so the default multi-src unpack works.
        # There is no directory for unpackPhase to descend into, hence
        # sourceRoot = ".".
        mkRelease =
          {
            pname,
            parts,
            nativeBuildInputs ? [ ],
          }:
          prev.stdenv.mkDerivation {
            inherit pname version nativeBuildInputs;

            srcs = map (part: prev.fetchurl {
              url = "https://github.com/NVIDIA/OpenShell/releases/download/v${version}/${part.file}";
              inherit (part) hash;
            }) parts;

            sourceRoot = ".";

            installPhase = ''
              runHook preInstall
              ${lib.concatMapStringsSep "\n" (
                part: "install -Dm755 ${part.binary} $out/bin/${part.binary}"
              ) parts}
              runHook postInstall
            '';

            # Fail the build if the shipped binary disagrees with `version`.
            nativeInstallCheckInputs = [ prev.versionCheckHook ];
            doInstallCheck = true;

            meta = prev.openshell.meta // {
              changelog = "https://github.com/NVIDIA/OpenShell/releases/tag/v${version}";
              mainProgram = pname;
              platforms = builtins.attrNames targets;
              sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
            };
          };
      in
      {
        openshell = mkRelease {
          pname = "openshell";
          parts = [ release.cli ];
        };

        # Ships the MicroVM driver and its host supervisor beside the gateway so
        # the sibling lookup finds them without any driver_dir setting.
        openshell-gateway = mkRelease {
          pname = "openshell-gateway";
          parts = [
            release.gateway
            release.driverVm
            release.supervisor
          ];
          # Only the musl CLI above is static; these three are glibc builds.
          nativeBuildInputs = [ prev.autoPatchelfHook ];
        };
      }
    )
  ];

  # host.openshell.internal is the name baked into the generated certificate
  # SAN and the name the VM driver's supervisor dials; upstream resolves it to
  # host loopback.
  networking.hosts."127.0.0.1" = [ "host.openshell.internal" ];

  # Mirrors upstream's deploy/deb/openshell-gateway.service: preflight, generate
  # the local mTLS/JWT bundle, then run. Driver auto-detection (kubernetes →
  # podman → docker) applies here.
  systemd.user.services.openshell-gateway = {
    description = "OpenShell Gateway";
    documentation = [ "https://github.com/NVIDIA/OpenShell" ];
    after = [ "default.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "simple";
      StateDirectory = "openshell/gateway";
      Environment = [ "OPENSHELL_LOCAL_TLS_DIR=%h/.local/state/openshell/tls" ];
      EnvironmentFile = "-%E/openshell/gateway.env";
      ExecStartPre = [
        "${pkgs.openshell-gateway}/bin/openshell-gateway config preflight"
        "${pkgs.openshell-gateway}/bin/openshell-gateway generate-certs --output-dir \${OPENSHELL_LOCAL_TLS_DIR} --server-san host.openshell.internal"
      ];
      ExecStart = "${pkgs.openshell-gateway}/bin/openshell-gateway";
      Restart = "on-failure";
      RestartSec = "5s";
      PrivateTmp = true;
      UMask = "0077";
    };
  };

  # Second gateway instance pinned to the MicroVM compute driver. Separate port,
  # SQLite DB, and driver state; it reuses the same generated TLS/JWT bundle as
  # the default instance (generate-certs is idempotent), hence the ordering
  # dependency.
  systemd.user.services.openshell-gateway-vm = {
    description = "OpenShell Gateway (MicroVM compute driver)";
    path = [ pkgs.e2fsprogs ];
    documentation = [ "https://github.com/NVIDIA/OpenShell" ];
    after = [ "default.target" "openshell-gateway.service" ];
    wants = [ "openshell-gateway.service" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "simple";
      StateDirectory = "openshell/gateway-vm";
      Environment = [
        "OPENSHELL_LOCAL_TLS_DIR=%h/.local/state/openshell/tls"
        "OPENSHELL_VM_STATE_DIR=${vmStateDir}"
      ];
      EnvironmentFile = "-%E/openshell/gateway-vm.env";
      ExecStartPre = [
        "${pkgs.openshell-gateway}/bin/openshell-gateway generate-certs --output-dir \${OPENSHELL_LOCAL_TLS_DIR} --server-san host.openshell.internal"
        "${vmConfig}"
      ];
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.openshell-gateway}/bin/openshell-gateway"
        "--config ${vmStateDir}/gateway.toml"
        "--db-url sqlite:${vmStateDir}/gateway.db?mode=rwc"
      ];
      Restart = "on-failure";
      RestartSec = "5s";
      PrivateTmp = true;
      UMask = "0077";
    };
  };
}

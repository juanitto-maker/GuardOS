{
  description = "GuardOS — reproducible dev shell & CI scaffolding (pre‑alpha)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems, ... }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs (import systems) (system:
          f (import nixpkgs { inherit system; }));
    in
    {

      # -------------------------------
      # Dev shells for hacking GuardOS
      # -------------------------------
      devShells = eachSystem (pkgs:
        let
          # Core CLI tools we actually use across the repo.
          baseTools = with pkgs; [
            bashInteractive
            coreutils
            gnused
            gawk
            gnugrep
            findutils
            diffutils
            util-linux
            which
            openssl            # sha256sum alt / misc checks
            rsync
            tar
            gzip
            # optional niceties
            curl
            git
          ];
        in
        {
          default = pkgs.mkShell {
            name = "guardos-dev";
            buildInputs = baseTools;

            # Keep the shell POSIX/bashy; no network calls by default.
            shellHook = ''
              echo "🛡  GuardOS dev shell — local/offline by default"
              echo "   - repo root: $PWD"
              echo "   - tools: bash, grep, awk, sed, rsync, tar, openssl"
              echo
              echo "Quick cmds:"
              echo "  bash build.sh check"
              echo "  bash guardos/system/boot_init.sh profiles/minimal.yaml"
              echo "  bash guardos/aegis/validate_config.sh profiles/dev-test.yaml"
              echo "  bash guardos/hunter/detect_threats.sh testdata/*.log || true"
              echo

              # Respect local env if present, else use example.
              if [ -f .env ]; then
                set -a; . ./.env; set +a
                echo "Loaded local .env"
              elif [ -f .env.example ]; then
                echo "Tip: cp .env.example .env  # then edit model path etc."
              fi

              # Ensure scripts are executable (useful on ZIP transfers)
              chmod +x guardos/guardpanel/cli.sh 2>/dev/null || true
              chmod +x guardos/aegis/validate_config.sh 2>/dev/null || true
              chmod +x guardos/hunter/detect_threats.sh 2>/dev/null || true
              chmod +x guardos/system/boot_init.sh 2>/dev/null || true
              chmod +x guardos/installer/install.sh 2>/dev/null || true
              chmod +x build.sh 2>/dev/null || true
            '';
          };
        });

      # -------------------------------
      # Formatter (nix files only)
      # -------------------------------
      formatter = eachSystem (pkgs: pkgs.nixpkgs-fmt);

      # -------------------------------
      # Packages (stubs for CI/demo)
      # -------------------------------
      # We expose a tiny "guardos-tools" package that just installs our shell
      # entrypoints into $out/bin. This is not a full OS package—purely a demo.
      packages = eachSystem (pkgs:
        let
          installScript = pkgs.writeShellScriptBin "guardos-install-layout" ''
            set -euo pipefail
            repo="${1:-.}"
            echo "GuardOS stub installer — staging layout (no root, no disk writes)"
            bash "$repo/guardos/installer/install.sh" --profile "$repo/profiles/minimal.yaml" --out "$repo/out/rootfs" --force
          '';

          guardpanelBin = pkgs.writeShellScriptBin "guardpanel" ''
            set -euo pipefail
            REPO="${1:-.}"
            exec bash "$REPO/guardos/guardpanel/cli.sh" "show-config"
          '';
        in
        {
          default = pkgs.symlinkJoin {
            name = "guardos-tools";
            paths = [ installScript guardpanelBin ];
            meta = {
              description = "GuardOS shell tooling (pre‑alpha stubs)";
              license = pkgs.lib.licenses.gpl3Plus;
              platforms = pkgs.lib.platforms.linux;
            };
          };
        });

      # -------------------------------
      # Apps (nix run .#guardpanel)
      # -------------------------------
      apps = eachSystem (pkgs: {
        guardpanel = {
          type = "app";
          program = "${self.packages.${pkgs.system}.default}/bin/guardpanel";
        };
        installLayout = {
          type = "app";
          program = "${self.packages.${pkgs.system}.default}/bin/guardos-install-layout";
        };
      });

    };
}

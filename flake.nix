{
  description = "k8s-homelab workstation dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # `kubectl` resolves to kubecolor, which shells out to the real kubectl
        # via KUBECTL_COMMAND. A shellHook alias would be lost under direnv,
        # which only carries environment variables across.
        kubectl-kubecolor = pkgs.writeShellScriptBin "kubectl" ''
          export KUBECTL_COMMAND="''${KUBECTL_COMMAND:-${pkgs.kubectl}/bin/kubectl}"
          exec ${pkgs.kubecolor}/bin/kubecolor "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            kubectl-kubecolor
            age
            cloudflared
            fluxcd
            go-task
            kubernetes-helm
            helmfile
            jq
            kubecolor
            kubeconform
            kustomize
            moreutils
            sops
            stern
            talhelper
            talosctl
            yq-go
            git
          ];
        };
      }
    );
}

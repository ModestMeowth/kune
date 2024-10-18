{ inputs, ... }:
{
  unstable-packages = final: prev: {
    unstable = import inputs.unstable {
      inherit (final) system;
      overlays = [ ];
    };
  };

  helm-wrapped = final: prev: {
    kubernetes-helm-wrapped = prev.wrapHelm prev.kubernetes-helm {
      plugins = with prev.kubernetes-helmPlugins; [
        helm-diff
        helm-git
        helm-unittest
      ];
    };
  };

  devshell = inputs.devshell.overlays.default;
}

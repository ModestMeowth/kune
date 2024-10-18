{inputs, ...}: {
  unstable-packages = final: prev: {
    unstable = import inputs.unstable {
      inherit (final) system;
      overlays = [];
    };
  };
  devshell = inputs.devshell.overlays.default;
}

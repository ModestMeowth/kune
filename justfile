# default task
default:
  just --justfile {{ justfile() }} --list

# Update flake and helm repos
update:
  nix flake update

# Run treefmt on repo
format:
  treefmt

# Run pre-commit tasks
check *ARGS:
  pre-commit run {{ ARGS }}

# run htpasswd
[no-cd]
htpasswd *ARGS:
  nix shell 'nixpkgs#apacheHttpd' --command htpasswd {{ ARGS }}

# task flux:bootstrap
bootstrap:
  task flux:bootstrap

# task flux:apply [ARGS]
apply path name='' namespace='flux-system':
  task flux:apply KS_PATH={{path}} KS_NAME={{name}} KS_NS={{namespace}}

# task flux:delete [ARGS]
delete path name='' namespace='flux-system':
  task flux:delete KS_PATH={{path}} KS_NAME={{name}} KS_NS={{namespace}}

# flux reconcile
reconcile:
  flux reconcile source git kube-cluster

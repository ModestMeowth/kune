# default task
default:
  just --justfile {{ justfile() }} --list

# Update flake and helm repos
update:
  nix flake update
  helm repo update

format:
  treefmt

check *ARGS:
  pre-commit run {{ ARGS }}

# run htpasswd
[no-cd]
htpasswd *ARGS:
  nix shell 'nixpkgs#apacheHttpd' --command htpasswd {{ ARGS }}

bootstrap:
  kubectl apply --server-side --kustomize ./cluster/bootstrap
  sops --decrypt ./cluster/bootstrap/age-key.sops.yaml | kubectl apply -f -
  sops --decrypt ./cluster/flux/vars/secrets.sops.yaml | kubectl apply -f -
  kubectl apply --server-side --filename ./cluster/flux/vars/settings.yaml
  kubectl apply --server-side --kustomize ./cluster/flux/config

reconcile:
  flux reconcile source git kube-cluster

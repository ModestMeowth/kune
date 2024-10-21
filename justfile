# default task
default:
    just --justfile {{ justfile() }} --list

# Update flake and helm repos
update:
    nix flake update
    helm repo update

format:
    treefmt

# run htpasswd
[no-cd]
htpasswd *ARGS:
    nix shell 'nixpkgs#apacheHttpd' --command htpasswd {{ ARGS }}

bootstrap:
    kubectl apply --server-side --kustomize ./bootstrap
    sops --decrypt ./bootstrap/age-key.sops.yaml | kubectl apply -f -
    sops --decrypt ./flux/config/secrets.sops.yaml | kubectl apply -f -
    kubectl apply --server-side --kustomize ./flux/config

reconcile:
    flux reconcile source git kube-cluster
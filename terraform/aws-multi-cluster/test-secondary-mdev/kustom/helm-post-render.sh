#!/usr/bin/env bash

# See:
# * https://helm.sh/docs/topics/advanced/#post-rendering
# * https://github.com/thomastaylor312/advanced-helm-demos/tree/master/post-render

set -o errexit -o nounset

kustomize_dir=${1:-}
if [[ ! -d $kustomize_dir ]]; then
  >&2 echo "[directory] is required, must be a kustomize directory."
  exit 1
fi

cd "$kustomize_dir" || exit 1

helm_output_file="helm-output.yaml"
cat <&0 > "$helm_output_file"

kustomize_output_file='kustomize-output.yaml'
kubectl kustomize . > "$kustomize_output_file"

# Check if Kustomize output is empty. This can commonly occur if
# Helm output manifest is not referenced in kustomization.yaml
if [[ ! -s "$kustomize_output_file" ]]; then
    >&2 echo "$kustomize_output_file is empty
Did you include the following in your kustomization.yaml?
resources:
  - helm-output.yaml
"
    exit 1
fi

cat "$kustomize_output_file"

rm "$helm_output_file"
rm "$kustomize_output_file"
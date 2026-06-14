#!/bin/bash 
sudo podman build . --tag=workspace-image

USER="tadgh"

mounts=(
  --volume "$HOME/projects:/home/${USER}/projects"
)

for key in id_ed25519 id_rsa; do
  if [[ -f "$HOME/.ssh/$key" ]]; then
    mounts+=(
      --volume "$HOME/.ssh/$key:/home/${USER}/.ssh/$key:ro"
    )
  fi
  if [[ -f "$HOME/.ssh/$key.pub" ]]; then
    mounts+=(
      --volume "$HOME/.ssh/$key.pub:/home/${USER}/.ssh/$key.pub:ro"
    )
  fi
done

sudo podman run -d --name worktop-container "${mounts[@]}" --publish 0.0.0.0:22222:22/tcp --hostname worktop --replace worktop-container 

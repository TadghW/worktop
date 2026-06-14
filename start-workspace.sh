#!/bin/bash
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

sudo podman run -d --name workspace-container "${mounts[@]}" --publish 22222:22/tcp --hostname workspace --replace workspace-image


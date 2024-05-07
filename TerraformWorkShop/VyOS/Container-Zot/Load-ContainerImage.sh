#!/bin/bash
# check image archive from local

AVAILABLE_IMAGES=($(sudo podman image list | awk '{ if ( NR > 1  ) { print $1 ":" $2} }'))

if [[ ! " $${AVAILABLE_IMAGES[*]} " =~ " ${image_name} " ]]; then
    echo "Loading image ${image_name}"
    if [ -f "${image_archive_path}" ]; then
        sudo podman load --input ${image_archive_path}
    else
        echo "pull and save the target image to ${image_archive_path} first"
        echo "sudo podman save -o ${image_archive_path} ${image_name} first"
        exit 1
    fi
fi

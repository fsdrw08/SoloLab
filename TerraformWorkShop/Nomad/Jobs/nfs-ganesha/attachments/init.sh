#!/bin/bash
%{ for dir in rootless_dirs ~}
mkdir -p ${dir}
%{ endfor ~}

%{ for dir in root_dirs ~}
sudo mkdir -p ${dir}
%{ endfor ~}

%{ for dir in root_chown_dirs ~}
sudo chown ${root_chown_user}:${root_chown_group} ${dir}
%{ endfor ~}
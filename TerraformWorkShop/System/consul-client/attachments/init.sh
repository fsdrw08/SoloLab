#!/bin/bash
%{ for dir in rootless_dirs ~}
mkdir -p ${dir}
%{ endfor ~}
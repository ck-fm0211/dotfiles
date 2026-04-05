#!/bin/bash

set -e

SHELDON_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon"
export SHELDON_CONFIG_DIR

sheldon lock

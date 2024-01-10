#!/bin/bash

# pymol does not work on cluster
# download ffmpeg locally or split pipeline
# fix pymol license
# optimize frame rate and quality of images and ffmpeg options

pymol_session=$1

source $HOME/.bashrc
micromamba activate pymol

mkdir $(dirname $pymol_session)/movie
cd $(dirname $pymol_session)/movie

pymol $HOME/work/scripts/pymol/movie/movie.py ../$(basename $pymol_session)

/home/cagostino/work/software/ffmpeg-git-20231229-amd64-static/ffmpeg -framerate 24 -i %04d.png -c:v libx264 -r 24 -pix_fmt yuv420p movie.mp4

mv movie.mp4 ..

cd -
rm $(dirname $pymol_session)/movie -rf

# https://ffmpeg.org/ffmpeg.html)
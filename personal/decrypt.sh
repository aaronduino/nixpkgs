#!/usr/bin/env bash

for filename in ./*.enc; do
  sops -d $filename | sudo tee $(basename $filename .enc)
done

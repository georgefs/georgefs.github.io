#! /bin/bash
ipython profile create nbserver
ipython notebook --ip=0.0.0.0 --notebook-dir=$1


#!/bin/bash

emacs --batch --no-init-file --load project.el --funcall org-publish-all

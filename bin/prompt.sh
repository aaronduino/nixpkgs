#!/usr/bin/env bash

if [ "$NIX_SHELL_PACKAGES"  ]; then
	echo -n '%{%F{red}%}' # red
	echo -n "$NIX_SHELL_PACKAGES "
	echo -n '%{%f%}'
fi

if [ "$NIXSHELL"  ]; then
	echo -n '%{%F{cyan}%}' # cyan
	echo -n "$NIXSHELL "
	echo -n '%{%f%}'
fi

echo -n '%{%F{yellow}%}' # yellow
dirs | sed 's/\/\(.\)[^\/]*/\/\1/g' | sed s'/.$//' | xargs echo -n ; echo -n $(basename "`pwd`")
echo -n '%{%f%}'

echo -n " "

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$branch" ]; then
	echo -n '%{%F{magenta}%}'
	echo -n "$branch "
	echo -n '%{%f%}'
fi

if [ `whoami` = "root" ]; then
	echo -n "#"
else
	echo -n "$"
fi

echo -n " "

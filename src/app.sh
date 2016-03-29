#!/usr/bin/env bash

# COLORS
COLOR_RED='\e[31m'
COLOR_GREEN='\e[32m'
COLOR_BLUE='\e[94m'
COLOR_CYAN='\e[96m'
COLOR_YELLOW='\e[93m'
COLOR_ORANGE='\e[33m'
COLOR_PURPLE='\e[35m'
COLOR_PINK='\e[95m'
COLOR_WHITE='\e[39m'

# FONTS
FONT_BOLD='\e[1m'
FONT_UNDERLINED='\e[4m'
FONT_HIDDEN='\e[8m'

CLEAR='\e[0m' #CLEAR COLORS and FONTS

# INPUT
NEWLINE='\n'

# CONSTANTS
RESOURCES='../resources/'
JQ='./jq'
CONFIG='../config.json'

# COMMANDS
declare -Ar COMMANDS=(
	['help']='Shows the "Sublime Manager" help information.'
	['commands']='Shows the "Sublime Manager" available commands.'
	['install']='Uninstall and Install "Sublime Text".'
	['uninstall']='Uninstall "Sublime Text".'
	['kill']='Kill "Sublime Text" processes.'
)

init () {
	sudo chown $(whoami):$(whoami) ${JQ}
	sudo chmod +x ${JQ}
}

kill () {
	killall -q -r '^subl*'
}

clear () {
	sudo rm -rf $(${JQ} -r '.install.path' ${CONFIG}) /usr/share/applications/sublime_text.desktop ./sublime.tar.bz2 ./sublime_text_3
	if [[ -L $(${JQ} -r '.install.bin' ${CONFIG}) ]]; then
		sudo unlink $(${JQ} -r '.install.bin' ${CONFIG})
	fi
}

uninstall () {
	kill
	clear
}

install () {
	uninstall
	local VERSION=$(${JQ} -r '.install.version' ${CONFIG})
	local BITS=$(${JQ} -r '.install.bits' ${CONFIG})
	local URL=$(${JQ} -r ".download.\"${VERSION}\".\"${BITS}\"" ${CONFIG})
	wget ${URL} -O sublime.tar.bz2
	tar -xvjf ./sublime.tar.bz2
	cd ./sublime_text_${VERSION}
	sed -i 's/Icon=sublime-text/Icon=\/opt\/sublime_text\/Icon\/256x256\/sublime-text.png/g' ./sublime_text.desktop
	cd ..
	sudo cp -fr ./sublime_text_${VERSION} $(${JQ} -r '.install.path' ${CONFIG})
	sudo cp -f $(${JQ} -r '.install.path' ${CONFIG})/sublime_text.desktop /usr/share/applications/sublime_text.desktop
	sudo ln -s $(${JQ} -r '.install.path' ${CONFIG})/sublime_text $(${JQ} -r '.install.bin' ${CONFIG})
	rm -rf ./sublime_text_${VERSION} ./sublime.tar.bz2
}

commands () {
	echo -e "${CLEAR}${COLOR_ORANGE}Available commands are:${CLEAR}"
	for command in ${!COMMANDS[*]}; do
		echo -e "${CLEAR}    - ${COLOR_CYAN}${command}${CLEAR}    =>    ${FONT_BOLD}${COMMANDS[$command]}${CLEAR}"
	done
}

help () {
	echo -e "${CLEAR}${COLOR_GREEN}Help command not implemented yet.${CLEAR}"
}

if [[ ! ${1} ]]; then
	help
else
	init
	if [[ ${!COMMANDS[*]} == *${1}* ]]; then
		if [[ ${1} == 'help' ]]; then
			help
		elif [[ ${1} == 'install' ]]; then
			install
		elif [[ ${1} == 'uninstall' ]]; then
			uninstall
		elif [[ ${1} == 'commands' ]]; then
			commands
		fi
	else
		echo -e "${CLEAR}${COLOR_ORANGE}Invalid command.${CLEAR}"
		commands
	fi
fi

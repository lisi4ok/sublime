#!/usr/bin/env bash

source constants.sh

declare -A COMMANDS
COMMANDS=(
	['help']='Shows the help information.'
	['install']='Install "Sublime Text 3"'
	['uninstall']='Uninstall "Sublime Text 3"'
	['remove']='Alias of the "uninstall" command.'
	['init']='Alias of the "install" command.'
)

declare -a PACKAGES
PACKAGES=(
	'sublime'
	'package-control'
	'emmet'
	'case-conversion'
	'side-bar-enhancements'
	'docblockr'
)

_help () {
	if [[ -f ./.sublime.lock ]]; then
		/opt/sublime_text/sublime_text --help
	else
		echo -e "${CLEAR}${COLOR_GREEN}    Help command not implemented yet.${CLEAR}"
	fi
}

_install () {
	if [[ ! -f ./.sublime.lock ]]; then
		rm -rf ./sublime.tar.bz2 ./sublime_text_3
		wget http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083_x64.tar.bz2 -O sublime.tar.bz2
		tar -xvjf sublime.tar.bz2
		cd ./sublime_text_3/
		sed -i 's/Icon=sublime-text/Icon=\/opt\/sublime_text\/Icon\/256x256\/sublime-text.png/g' ./sublime_text.desktop
		cd ..
		sudo rm -rf /opt/sublime_text
		sudo mv ./sublime_text_3 /opt/sublime_text
		sudo cp -fr /opt/sublime_text/sublime_text.desktop /usr/share/applications/sublime_text.desktop
		sudo ln -s /opt/sublime_text/sublime_text /usr/bin/subl
		touch ./.sublime.lock
	fi
}

_uninstall () {
	sudo rm -rf /opt/sublime_text/ /usr/share/applications/sublime_text.desktop ./sublime.tar.bz2 ./sublime_text_3 ./.sublime.lock
	if [[ -f /usr/bin/subl ]]; then
		sudo unlink /usr/bin/subl
	fi
}

if [[ ! ${1} ]]; then
	_help
else
	if [[ ${!COMMANDS[*]} == *${1}* ]]; then
		if [[ ${1} == 'help' ]]; then
			_help
		elif [[ ${1} == 'install' || ${1} == 'init' ]]; then
			if [[ ! ${2} || ${2} == 'sublime' ]]; then
				_install
			elif [[ ${PACKAGES[*]} == *${2}* ]]; then
				echo ${PACKAGES[@]}
			fi
		elif [[ ${1} == 'uninstall' || ${1} == 'remove' ]]; then
			if [[ ! ${2} || ${2} == 'sublime' ]]; then
				_uninstall
			fi
		fi
	else
		echo -e "${CLEAR}${COLOR_ORANGE}Invalid Command.${CLEAR}"
		echo -e "${CLEAR}${COLOR_ORANGE}Available commands are:${CLEAR}"
		for command in ${!COMMANDS[*]}; do
			echo -e "${CLEAR}    - ${COLOR_CYAN}${command}${CLEAR}    =>    ${FONT_BOLD}${COMMANDS[$command]}${CLEAR}"
		done
	fi
fi
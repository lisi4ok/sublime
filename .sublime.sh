#!/usr/bin/env bash

source ./.constants.sh

declare -A COMMANDS
COMMANDS=(
	['help']='Shows the "Sublime Manager" help information.'
	['commands']='Shows the "Sublime Manager" available commands.'
	['packages']='Shows the "Sublime Manager" available packages (in dash-case).'
	['install']='Install "Sublime Text 3".'
	['uninstall']='Uninstall "Sublime Text 3".'
	['reinstall']='Reinstall "Sublime Text 3".'
	['kill']='Kill "Sublime Text 3" processes.'
)

declare -a PACKAGES
PACKAGES=(
	'package-control'
	'emmet'
	'case-conversion'
	'side-bar-enhancements'
	'docblockr'
)

_kill () {
	killall -q -r '^subl*'
}

_clear () {
	sudo rm -rf /opt/sublime_text/ /usr/share/applications/sublime_text.desktop ./sublime.tar.bz2 ./sublime_text_3/
	if [[ -L /usr/bin/subl ]]; then
		sudo unlink /usr/bin/subl
	fi
	if [[ -L /usr/bin/sublime ]]; then
		sudo unlink /usr/bin/sublime
	fi
}

_init () {
	wget -N http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083_x64.tar.bz2 -O sublime.tar.bz2
	tar -xvjf ./sublime.tar.bz2
	cd ./sublime_text_3/
	sed -i 's/Icon=sublime-text/Icon=\/opt\/sublime_text\/Icon\/256x256\/sublime-text.png/g' ./sublime_text.desktop
	cd ..
	sudo cp -r ./sublime_text_3/ /opt/sublime_text/
	sudo cp -fr /opt/sublime_text/sublime_text.desktop /usr/share/applications/sublime_text.desktop
	sudo ln -s /opt/sublime_text/sublime_text /usr/bin/subl
	sudo ln -s /opt/sublime_text/sublime_text /usr/bin/sublime
}

help () {
	if [[ -f ./.sublime.lock ]]; then
		/opt/sublime_text/sublime_text --help
	else
		echo -e "${CLEAR}${COLOR_GREEN}Help command not implemented yet.${CLEAR}"
	fi
}

commands () {
	echo -e "${CLEAR}${COLOR_ORANGE}Available commands are:${CLEAR}"
	for command in ${!COMMANDS[*]}; do
		echo -e "${CLEAR}    - ${COLOR_CYAN}${command}${CLEAR}    =>    ${FONT_BOLD}${COMMANDS[$command]}${CLEAR}"
	done
}

packages () {
	echo -e "${CLEAR}${COLOR_ORANGE}Available packages are:${CLEAR}"
	for package in ${PACKAGES[*]}; do
		echo -e "${CLEAR}    - ${COLOR_CYAN}${package}${CLEAR}"
	done
}

install () {
	if [[ ! -f ./.sublime.lock ]]; then
		_clear
		_init
		rm -rf ./sublime_text_3/ ./sublime.tar.bz2
		touch ./.sublime.lock
	else
		echo -e "Sublime Text 3 is installed on this device."
	fi
}

uninstall () {
	_kill
	_clear
	sudo rm -rf ./.sublime.lock
}

reinstall () {
	_kill
	uninstall
	install
}

kill () {
	_kill
}

if [[ ! ${1} ]]; then
	help
else
	if [[ ${!COMMANDS[*]} == *${1}* ]]; then
		if [[ ${1} == 'help' ]]; then
			help
		elif [[ ${1} == 'packages' ]]; then
			packages
		elif [[ ${1} == 'install' ]]; then
			if [[ ! ${2} ]]; then
				install
			elif [[ ${PACKAGES[*]} == *${2}* ]]; then
				echo ${PACKAGES[@]}
			fi
		elif [[ ${1} == 'uninstall' ]]; then
			if [[ ! ${2} ]]; then
				uninstall
			# elif [[ ${PACKAGES[*]} == *${2}* ]]; then
			# 	echo ${PACKAGES[@]}
			fi
		elif [[ ${1} == 'reinstall' ]]; then
			if [[ ! ${2} ]]; then
				reinstall
			# elif [[ ${PACKAGES[*]} == *${2}* ]]; then
			# 	echo ${PACKAGES[@]}
			fi
		elif [[ ${1} == 'commands' ]]; then
			commands
		fi
	else
		echo -e "${CLEAR}${COLOR_ORANGE}Invalid command.${CLEAR}"
		commands
	fi
fi

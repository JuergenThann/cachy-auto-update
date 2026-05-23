#!/bin/bash

# restart_services.sh: Display services requiring a post update restart and offer to restart them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
services=$("${su_cmd}" checkservices -F -P -R -i gdm.service -i plasmalogin.service -i sddm.service -i lightdm.service -i lxdm.service -i slim.service -i xdm.service -i greetd.service -i nodm.service -i ly.service -i lemurs.service 2> /dev/null | grep ".service" | cut -f2 -d "'")
services_num=$(echo "${services}" | wc -l)

if [ -n "${services}" ]; then
	if [ "${services_num}" -eq 1 ]; then
		main_msg "$(eval_gettext "Services:\nThe following service requires a post upgrade restart\n")"
	else
		main_msg "$(eval_gettext "Services:\nThe following services require a post upgrade restart\n")"
	fi

	i=1
	while IFS= read -r line; do
		echo "${i} - ${line}"
		((i=i+1))
	done < <(printf '%s\n' "${services}")

	echo

	# shellcheck disable=SC2086,SC2154
	if "${su_cmd}" systemctl restart ${services}; then
		info_msg "$(eval_gettext "Service(s) restarted successfully\n")"

	else
		error_msg "$(eval_gettext "An error has occurred during the service(s) restart\nPlease, verify the above service(s) status\n")" && quit_msg
		exit 11
	fi
else
	info_msg "$(eval_gettext "No service requiring a post upgrade restart found\n")"
fi

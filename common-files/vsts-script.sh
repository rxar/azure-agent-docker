#!/usr/bin/env bash

script_name="${0}"
script_dirname="$( dirname "${0}" )"
script_basename="$( basename "${0}" )"

verbose_run() {
	local level="${1}"; shift 1;
	[ "${verbosity:--1}" -ge "${level}" ] && { "${@}"; return "${?}"; }
	return 0;
}

dump_command()
{
	for arg in "${@}"; do
		printf "%q " "${arg}"
	done
	echo
}

pretend_run()
{
	if "${pretend}"; then
		dump_command "${@}" 1>&2
	else
		"${@}"
	fi
}

log() {
	1>&2 echo "$(date +%Y%m%d%H%M%S) ${script_basename} ${$}" "${@}"
}

VSTS_OPT=/opt/vsts-agent/

do_cleanup() {
	verbose_run 0 log "${FUNCNAME}: entry"
	verbose_run -1 log "${FUNCNAME}: checking if configured ..."
	if [ -e "${VSTS_OPT}/config.sh" ]; then
		verbose_run -1 log "${FUNCNAME}: configured ... removing"
		pretend_run Agent.Listener remove --unattended \
			--agent "${VSTS_AGENT:-$(hostname)}" \
			--auth PAT \
			--token "${VSTS_TOKEN}"
	fi
}

do_start() {
	verbose_run 0 log "${FUNCNAME}: entry"
	verbose_run 0 declare -p VSTS_AGENT VSTS_ACCOUNT VSTS_TOKEN VSTS_POOL VSTS_WORK

	pretend_run Agent.Listener configure --unattended \
		--agent "${VSTS_AGENT:-$(hostname)}" \
		--url "https://${VSTS_ACCOUNT}.visualstudio.com" \
		--auth PAT \
		--token "${VSTS_TOKEN}" \
		--pool "${VSTS_POOL:-Default}" \
		--work "${VSTS_WORK:-_work}" \
		--replace

	trap 'do_cleanup; exit 130' INT
	trap 'do_cleanup; exit 143' TERM

	pretend_run exec Agent.Listener run
}

main_usage()
{
	1>&2 echo -e "${script_basename} [options] command"

	1>&2 echo -e "commands:"

	local -a format=( printf " %-32s%s\n" )
	1>&2 "${format[@]}" "start" "Start the agent"

	1>&2 echo -e "options:"

	local -a format=( printf " %-32s%s\n" )
	1>&2 "${format[@]}" "-h" "help"
	1>&2 "${format[@]}" "-v" "increase verbosity"
	1>&2 "${format[@]}" "-p" "pretend mode"
	return 0;
}

main()
{
	local argv=( "${@}" )
	local verbosity=-1
	local verbose=false
	local pretend=false
	local something=""

	local OPTARG OPTERR="" option OPTIND
	while getopts "hvps:" option "${@}"
	do
		case "${option}" in
			h)
				"${FUNCNAME}_usage"
				return 0;
				;;
			v)
				verbosity=$(( ${verbosity} + 1 ))
				;;
			p)
				pretend=true
				;;
			*)
				"${FUNCNAME}_usage" "Invalid options [ OPTARG=${OPTARG}, OPTERR=${OPTERR}, option=${option} ]"
				return 1
				;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))

	[ "${verbosity:--1}" -ge 0 ] && verbose=true

	verbose_run 0 declare -p script_dirname script_basename argv
	verbose_run 0 declare -p option OPTERR OPTIND
	verbose_run 0 declare -p verbosity pretend verbose

	verbose_run 0 log "entry ..."
	local command=""

	case "${script_basename}" in
		vsts-script.sh)
			command="${1}"; shift 1;
		;;
		vsts-*.sh)
			command="${script_basename}"
			command="${command#vsts-}"
			command="${command%.sh}"
		;;
	esac

	verbose_run 0 declare -p command

	case "${command}" in
		start|cleanup)
				do_"${command}" "${@}"; return "${?}"
			;;
		*)
			"${FUNCNAME}_usage" "Invalid command ${command}"
			;;
	esac

	return 0
}

if ! $(return >/dev/null 2>&1)
then
	script_dirname=$( dirname "${0}" )
	script_basename=$( basename "${0}" )
	main "${@}"
	exit "${?}"
fi

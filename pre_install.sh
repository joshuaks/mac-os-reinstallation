#!/bin/bash

set -e; # exit all shells if script fails
set -u; # exit script if uninitialized variable is used
set -o pipefail; #exit script if anything fails in pipe
# set -x; #debug mode


#########################
# GLOBALS ###############
#########################
# declare -r FILE_NAME="$0"
# declare -r FILE_NAME=$(basename $0)
declare -r PROGRAM="$0"
declare -r ARGS="$@"

declare -r APPLE_SCRIPTS="./support/scripts/apple_scripts/"
# declare -r BASH_SCRIPTS="./support/scripts/bash/"




#######################################################################################################
#######################################################################################################
# read paramters in ###################################################################################
#######################################################################################################
#######################################################################################################
function read_parameters(){
	log_func "read_parameters"
    local is_dump_homebrew="false"
    local is_run_mackup="false"
    local is_run_arq="false"
    local is_update_devonthink="false"
    local is_do_all="false"
    
    while getopts ":hdmaiz" opt; do
      case "${opt}" in
        h ) usage
            ;;
        m ) is_run_mackup="true"
            ;;
        d ) is_dump_homebrew="true"
            ;;
        a ) is_run_arq="true"
            ;;
        i ) is_update_devonthink="true"
            ;;
        z ) is_do_all="true"
            ;;
        \? ) usage
            ;;
      esac
    done
    
    if [[ "$is_do_all" == "true" ]]; then 
        is_dump_homebrew="true"
        is_run_mackup="true"
        is_run_arq="true"
        is_update_devonthink="true"    
    fi
    
    readonly IS_DUMP_HOMEBREW="$is_dump_homebrew"
    readonly IS_RUN_MACKUP="$is_run_mackup"
    readonly IS_RUN_ARQ="$is_run_arq"
    readonly IS_UPDATE_DEVONTHINK="$is_update_devonthink"
}



#######################################################################################################
#######################################################################################################
# logging #############################################################################################
#######################################################################################################
#######################################################################################################

function log(){
    local -r msg="$1"
    echo "======================> LOG: $msg"
}

function log_func(){
    local -r function_name="$1"
    log "function - $function_name"
}



#######################################################################################################
#######################################################################################################
# print the usage #####################################################################################
# displays usage information to the user for this script ##############################################
# http://docopt.org ###################################################################################
#######################################################################################################
#######################################################################################################
function usage(){
	log_func "usage"
    echo "-----------------------------------------------------------------------------------------------------"
    echo "Usage: $PROGRAM [-h] [-d] [-m] [-a] [-i] "
    echo 
    echo "       -h        HELP: displays this usage page"
    echo
    echo "       -d        dumps homebrew information (installed apps) to Brewfile.dump"
    echo
    echo "       -m        run \`mackup backup\` to update backed up preference files"
    echo
    echo "       -a        run arq backup"
    echo
    echo "       -i        index and sync DevonThink"
    echo
    echo "       -z        enable all flags (except -h/help) for this program"
    echo
    echo "-----------------------------------------------------------------------------------------------------"
}




#######################################################################################################
#######################################################################################################
# # dumps all installed homebrew stuff into a Brewfile ################################################
#######################################################################################################
#######################################################################################################
function dump_homebrew(){
	log_func "dump_homebrew"
    brew bundle dump --force --file="./support/resources/brew/Brewfile.dump"
}


#######################################################################################################
#######################################################################################################
# run devonthink index and sync apple scripts #########################################################
#######################################################################################################
#######################################################################################################

function index_and_sync_devonthink(){
	log_func "index_and_sync_devonthink"
    (   cd "$APPLE_SCRIPTS" || return
        osascript "index_devonthink.scpt"
        osascript "sync_devonthink.scpt"
    )
}


#######################################################################################################
#######################################################################################################
# links any new apps to have pref files sym linked ####################################################
#######################################################################################################
#######################################################################################################
function backup_mackup(){
	log_func "backup_mackup"
    mackup backup
}


#######################################################################################################
#######################################################################################################
# run arq backup ######################################################################################
#######################################################################################################
#######################################################################################################
function backup_arq(){
	log_func "backup_arq"
    (   cd "/Applications/Arq.app/Contents/MacOS" || return
    
        # select B2
        ./Arq backupnow
    
        # select local
        ./Arq backupnow
    )
}


#######################################################################################################
#######################################################################################################
# main ################################################################################################
#######################################################################################################
#######################################################################################################
function main(){
	log_func "main"
    read_parameters $ARGS
    
    if [[ "$IS_DUMP_HOMEBREW" == "true" ]]; then
        dump_homebrew
    fi
    
    if [[ "$IS_RUN_MACKUP" == "true" ]]; then
        backup_mackup
    fi
    
    if [[ "$IS_UPDATE_DEVONTHINK" == "true" ]]; then
        index_and_sync_devonthink
    fi
    
    if [[ "$IS_RUN_ARQ" == "true" ]]; then
        backup_arq
    fi
}
main





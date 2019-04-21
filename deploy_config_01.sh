#!/usr/bin/env bash
# shellcheck disable=2059,2154,2034,2155,2046,2086
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: deploy_config_01.sh
#
#         USAGE: sudo ./deploy_config_01.sh
#
#   DESCRIPTION: Deploy Logstash configuration for the ELK Lab
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline


###############
#  Functions  #
###############

function echoinfo() {
  local GC="\033[1;32m"
  local EC="\033[0m"
  printf "${GC} ☆  INFO${EC}: %s${GC}\n" "$@";
}

function echodebug() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  local GC="\033[1;32m"
  if [[ -n ${DEBUG+x} ]]; then
    printf "${BC} ★  DEBUG${EC}: %s${GC}\n" "$@";
  fi
}

function echoerror() {
  local RC="\033[1;31m"
  local EC="\033[0m"
  printf "${RC} ✖  ERROR${EC}: %s\n" "$@" 1>&2;
}

function deploy_pipeline() {
  echoinfo "Deploying Logstash Pipeline: /usr/share/logstash/config/pipelines.yml" 
  mkdir -p /usr/share/logstash/config
  cp /tmp/elk-guided-lab-code/pipelines.yml /usr/share/logstash/config/
  chown -R logstash:logstash /usr/share/logstash/config
}

function deploy_peoplesoft_config() {
  echoinfo "Deploying PeopleSoft Log Configuration 01: /etc/logstash/conf.d/peoplesoft.conf"
  cp -r /tmp/elk-guided-lab-code/conf.d/peoplesoft.conf.01 /etc/logstash/conf.d/peoplesoft.conf
  chown -R logstash:logstash /etc/logstash/conf.d
}

# function deploy_peoplesoft_patterns() {
#   echoinfo "Deploying PeopleSoft Grok Patterns: /etc/logstash/conf.d/patterns"
#   cp -r /tmp/elk-guided-lab-code/conf.d/patterns /etc/logstash/
#   chown -R logstash:logstash /etc/logstash/conf.d
# }

########
# Main #
########


deploy_peoplesoft_config
# deploy_peoplesoft_patterns
deploy_pipeline
#!/usr/bin/env bash
# shellcheck disable=2059,2154,2034,2155,2046,2086
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: deploy_config.sh
#
#         USAGE: sudo ./deploy_config.sh step01
#       OPTIONS: step01, step0X, final
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
  echoinfo "Deploying PeopleSoft Log Configuration 02: /etc/logstash/conf.d/peoplesoft.conf"
  cp -r /tmp/elk-guided-lab-code/conf.d/peoplesoft.conf."$1" /etc/logstash/conf.d/peoplesoft.conf
  chown -R logstash:logstash /etc/logstash/conf.d
}

function deploy_peoplesoft_patterns() {
  echoinfo "Deploying PeopleSoft Grok Patterns: /etc/logstash/conf.d/patterns"
  cp -R /tmp/elk-guided-lab-code/conf.d/patterns /etc/logstash/conf.d/
  chown -R logstash:logstash /etc/logstash/conf.d
}

function remove_file_read_data() {
  echoinfo "Removing file read data for Logstash"
  rm -rf /usr/share/logstash/data/plugins/inputs/file/.sinced*
}

function deploy_elasticsearch_template() {
  echoinfo "Deploying Elasticsearch Template for PeopleSoft Logs"
  echoinfo "-> Make sure to change the `elastic` password in the base file"
  cp -r /tmp/elk-guided-lab-code/peoplesoft.template.json /etc/logstash/
  chown logstash:logstash /etc/logstash/peoplesoft.template.json
}

########
# Main #
########

case $1 in
  "step01")
    deploy_peoplesoft_config "01"
    deploy_pipeline
    remove_file_read_data
    ;;
  "step02")
    deploy_peoplesoft_config "02"
    deploy_peoplesoft_patterns
    deploy_pipeline
    remove_file_read_data
    ;;
  "step03")
    deploy_peoplesoft_config "03"
    deploy_peoplesoft_patterns
    deploy_pipeline
    remove_file_read_data
    deploy_elasticsearch_template
    ;;
  "final")
    deploy_peoplesoft_config "final"
    deploy_peoplesoft_patterns
    deploy_pipeline
    remove_file_read_data
    deploy_elasticsearch_template
    ;;
  *)
    echoinfo "Pass in a step to deploy: step01, step0X, or final"
esac
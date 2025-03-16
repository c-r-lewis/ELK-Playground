#!/bin/bash

#===================================================================#

# Variables de couleurs ansii 256
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'
PINK='\033[38;5;206m'

# Variable pour contrôler le mode verbose.
verbose=true

#===================================================================#

# Fonctions d'affichage.
logs()
{   
    local color="$1"
    shift
    date_formated=$(date +"%d-%m-%Y %H:%M:%S")

    if [ "$verbose" = true ]; then
        echo -e "${PINK}[🧶 ELK-Playground]${RESET}[$date_formated]${color} $1 ${RESET}"
    fi
    echo -e "${PINK}[🧶 ELK-Playground]${RESET}[$date_formated]${color} $1 ${RESET}" >> /var/log/ELK-Playground.log
}

logs_error()
{
    date_formated=$(date +"%d-%m-%Y %H:%M:%S")
    echo -e "${PINK}[🧶 ELK-Playground]${RESET}[$date_formated]${RED} $1 ${RESET}"
    echo -e "${PINK}[🧶 ELK-Playground]${RESET}[$date_formated]${RED} $1 ${RESET}" >> /var/log/ELK-Playground.log
}

logs_info()
{
    logs "$YELLOW" "$*"
}

logs_success()
{
    logs "$GREEN" "$*"
}

logs_end()
{
    verbinit=$verbose
    verbose=true
    logs "$BLUE" "$*"
    verbose=$verbinit
}


# Fonction de gestion de l'affichage des erreurs.
error_handler()
{

    # echo "Debug: error_handler received code $1 and message '$2'" # Debug message
    if [ $1 -ne 0 ]
    then
        logs_error "$2"
        exit $1
    fi
}

#===================================================================#

# Fonction pour exécuter des commandes avec redirection conditionnelle.
run_command() 
{
    exit_code=$?
    if [ "$verbose" = "true" ]; then
        "$@" 2>&1 | tee -a /var/log/ELK-Playground.log
    else
        "$@" 2>&1 | tee -a /var/log/ELK-Playground.log &>/dev/null
    fi
    return $exit_code
}

#===================================================================#

# Fonction pour démarrer les services ELK
start_elk() {

    logs_info "ELK > Démarrage d'Elasticsearch..."
    run_command sudo systemctl start elasticsearch
    error_handler $? "ELK > Le lancement d'Elasticsearch a échoué."

    logs_info "ELK > Démarrage de Logstash..."
    run_command sudo systemctl start logstash
    error_handler $? "ELK > Le lancement de Logstash a échoué."

    logs_info "ELK > Démarrage de Kibana..."
    run_command sudo systemctl start kibana
    error_handler $? "ELK > Le lancement de kibana a échoué."

    logs_success "ELK > Tous les services ELK ont démarré."

    logs_info "Beat > Démarrage des services..."

    run_command sudo systemctl start filebeat
    error_handler $? "Beat > Le lancement de filebeat a échouée."

    run_command sudo systemctl start metricbeat
    error_handler $? "Beat > Le lancement de metricbeat a échouée."

    run_command sudo systemctl start heartbeat-elastic
    error_handler $? "Beat > Le lancement de heartbeat-elastic a échoué."

    run_command sudo systemctl start packetbeat
    error_handler $? "Beat > Le lancement de packetbeat a échoué."

    logs_success "Beat > Tous les services Beat ont démarré."

    logs_end "Les services ELK et Beat ont été démarré."

}

# Fonction pour arrêter les services ELK
stop_elk() {


    logs_info "ELK > Arrêt d'Elasticsearch..."
    run_command sudo systemctl stop elasticsearch
    error_handler $? "ELK > L'arrêt d'Elasticsearch a échoué."

    logs_info "ELK > Arrêt de Logstash..."
    run_command sudo systemctl stop logstash
    error_handler $? "ELK > L'arrêt de Logstash a échoué."

    logs_info "ELK > Arrêt de Kibana..."
    run_command sudo systemctl stop kibana
    error_handler $? "ELK > L'arrêt de kibana a échoué."

    logs_success "ELK > Tous les services ELK sont arrêtés."

    logs_info "Beat > Arrêt des services..."

    run_command sudo systemctl stop filebeat
    error_handler $? "Beat > L'arrêt de filebeat a échoué."

    run_command sudo systemctl stop metricbeat
    error_handler $? "Beat > L'arrêt de metricbeat a échoué."

    run_command sudo systemctl stop heartbeat-elastic
    error_handler $? "Beat > L'arrêt de heartbeat-elastic a échoué."

    run_command sudo systemctl stop packetbeat
    error_handler $? "Beat > L'arrêt de packetbeat a échoué."

    logs_success "Beat > Tous les services Beat sont arrêtés."

    logs_end "Les services ELK et Beat ont été arrêtés."

}

# Fonction pour afficher l'état des services ELK
status_elk() {
    logs_info "État d'Elasticsearch:"
    sudo systemctl status elasticsearch
    error_handler $? "ELK > L'affichage de l'état d'Elasticsearch a échoué."

    logs_info "État de Logstash:"
    sudo systemctl status logstash
    error_handler $? "ELK > L'affichage de l'état de Logstash a échoué."

    logs_info "État de Kibana:"
    sudo systemctl status kibana
    error_handler $? "ELK > L'affichage de l'état de kibana a échoué."

    logs_info "État de Filebeat:"
    sudo systemctl status filebeat
    error_handler $? "Beat > L'affichage de l'état de filebeat a échoué."

    logs_info "État de Metricbeat:"
    sudo systemctl status metricbeat
    error_handler $? "Beat > L'affichage de l'état de metricbeat a échoué."

    logs_info "État de Packetbeat:"
    sudo systemctl status packetbeat
    error_handler $? "Beat > L'affichage de l'état de packetbeat a échoué."

    logs_info "État de Heatbeat:"
    sudo systemctl status heartbeat-elastic
    error_handler $? "Beat > L'affichage de l'état de heartbeat-elastic a échoué."


}

#===================================================================#



# Vérification de la configuration de la machine hôte.
if [ "$EUID" -ne 0 ]
then
    logs_error "Ce script doit être exécuté avec des privilèges root."
    exit 1
fi

# Vérifie les arguments passés au script
case "$1" in
    start)
        start_elk
        ;;
    stop)
        stop_elk
        ;;
    status)
        status_elk
        ;;
    *)
        logs_info "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac

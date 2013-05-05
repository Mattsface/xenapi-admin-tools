#!/bin/bash
# Lists all information about a XCP/Xenserver network 
# Author: Matthew Spah (spahmatthew@gmail.com)
# Version: .0.1
# Date: 04/19/2013
# shownetwork - show all information about the network including the ethernet device, the settings, the VLAN, the type of network the vifs plugged into it, the VMs possessing those, etc..
source xaptools.lib
NETWORKUUID=$1
set -x

setup()
{
	SCRIPTDIR=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
	source "$SCRIPTDIR/xaptools.lib" 
	setcolors	
	DEFSPACE="5"
	MINSPACE="$DEFSPACE"
	MODE="mixed"
	VERSION="0.6"
}

syntax()
{
		echo "$(basename $0) $VERSION"
        echo ""
        echo "Syntax: $(basename $0) [options]"
        echo "Options:"
        echo "-d - shell debugging"
        echo "-c - output comma seperated values"
        echo "-u - shows PIF UUID, HOST-UUID, device, MAC, physical, VLAN, IP-configuration-mode, IP, netmask, and gateway. \n
                   shows VIF UUID, VM-UUID, locking-mode, currently-attached, and MAC"
        echo "-n - shows PIF UUID, HOST-NAME-LABEL, device, MAC, physical, VLAN, IP-configuration-mode, IP, netmask, and gateway. \n
                   shows VIF UUID, VM-NAME-LABEL, locking-mode, currently-attached, and MAC"
        echo "-s <host> - remote poolmaster host"
        echo "-p <password> - remote poolmaster password"
        echo "-h - this help text"
        echo "-w - number of whitespaces between columns"
        echo ""
        exit
}



getnetvifinfo()
{

    # Gathering VIF data for $NETWORKUUID
	getcmddata vif-list network-uuid="$NETWORKUUID" params="uuid,vm-uuid,vm-name-label,device,locking-mode,currently-attached,MAC"

    # Setting title array depending on $MODE
    case "$MODE" in 
        "uuid")
              TITLES=( 'uuid' 'vm-uuid' 'device' 'locking-mode' 'currently-attached' 'MAC' ) ;;
        "name")
              TITLES=( 'uuid' 'vm-name-label' 'device' 'locking-mode' 'currently-attached' 'MAC' ) ;;
    esac

    # Creating COLLONGEST array 

    case "$MODE" in 
        "uuid")
            COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${vif_uuid[@]}")
	        COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${vif_vm_uuid[@]}")
	        COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${vif_device[@]}")
	        COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${vif_locking_mode[@]}")
	        COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${vif_currently_attached[@]}")
            COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${vif_MAC[@]}")
            ;;
        "name")
            COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${vif_uuid[@]}")
	        COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${vif_vm_name_label[@]}")
	        COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${vif_device[@]}")
	        COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${vif_locking_mode[@]}")
	        COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${vif_currently_attached[@]}")
            COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${vif_MAC[@]}")
	        ;;
    esac

    # Printing header for VIF intformation 
    case "$MODE" in
        "uuid")
          echo "VIF Information for Network: ${network_uuids[0]}" 
          echo "" ;;
        "name") 
          echo "VIF Information for Network: ${network_name_label[0]}"
          echo "" ;;
	esac

    # Printing columns and VIF information
	printheadings
	for i in $(seq 0 $(( ${#vif_uuid[@]} - 1 )) ) ;do
        case "$MODE" in
           "uuid")
                cecho "${vif_uuid[$i]}" blue 			    ; printspaces "${COLLONGEST[0]}" "${#vif_uuid[$i]}" 
		        cecho "${vif_vm_uuid[$i]}" blue 		    ; printspaces "${COLLONGEST[1]}" "${#vif_vm_uuid[$i]}"
		        cecho "${vif_device[$i]}" blue 		        ; printspaces "${COLLONGEST[2]}" "${#vif_device[$i]}"
		        cecho "${vif_locking_mode[$i]}" blue 	    ; printspaces "${COLLONGEST[3]}" "${#vif_locking_mode[$i]}"
                cecho "${vif_currently_attached[$i]}" blue 	; printspaces "${COLLONGEST[4]}" "${#vif_currently_attached[$i]}"
		        cecho "${vif_MAC[$i]}" blue 			    ; printspaces "${COLLONGEST[5]}" "${#vif_MAC[$i]}"
                echo "" ;;
           "name")		
                cecho "${vif_uuid[$i]}" blue 			    ; printspaces "${COLLONGEST[0]}" "${#vif_uuid[$i]}" 
		        cecho "${vif_vm_uuid[$i]}" blue 		    ; printspaces "${COLLONGEST[1]}" "${#vif_vm_name_label[$i]}"
		        cecho "${vif_device[$i]}" blue 		        ; printspaces "${COLLONGEST[2]}" "${#vif_device[$i]}"
		        cecho "${vif_locking_mode[$i]}" blue 	    ; printspaces "${COLLONGEST[3]}" "${#vif_locking_mode[$i]}"
                cecho "${vif_currently_attached[$i]}" blue 	; printspaces "${COLLONGEST[4]}" "${#vif_currently_attached[$i]}"
		        cecho "${vif_MAC[$i]}" blue 			    ; printspaces "${COLLONGEST[5]}" "${#vif_MAC[$i]}"
		        echo "" ;;
        esac 
	done
	
}


getnetinfo()
{

    TITLES=( 'Name-label' 'MTU' 'Bridge' 'Default-locking-mode' 'tags' )
	getcmddata network-list uuid="$NETWORKUUID" params="uuid,name-label,bridge,MTU,default-locking-mode,tags,VIF-uuids,PIF-uuids"

	COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${network_name_label[@]}")
	COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${network_MTU[@]}")
	COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${network_bridge[@]}")
	COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${network_default_locking_mode[@]}")
	COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${network_tags[@]}")
    
    echo "NETWORK INFORMATION"
	printheadings
	cecho "${network_name_label[0]}" red             ; printspaces "${COLLONGEST[0]}" "${#network_name_label[0]}"
	cecho "${network_MTU[0]}" red                    ; printspaces "${COLLONGEST[1]}" "${#network_MTU[0]}"
	cecho "${network_bridge[0]}" red                 ; printspaces "${COLLONGEST[2]}" "${#network_bridge[0]}"
	cecho "${network_default_locking_mode[0]}" red   ; printspaces "${COLLONGEST[3]}" "${#network_default_locking_mode[0]}"
	cecho "${network_tags[0]}" red                   ; printspaces "${COLLONGEST[4]}" "${#network_tags[0]}"
	echo ""

}

getnetpifinfo()
{
    # Gathering PIF data
    getcmddata pif-list network-uuid="$NETWORKUUID" params="uuid,host-uuid,host-name-label,VLAN,device,MAC,physical,IP-configuration-mode,IP,netmask,gateway"
    
    # Setting title array depending on $MODE
    case "$MODE" in 
        "uuid") TITLES=( 'uuid' 'host-uuid' 'device' 'MAC' 'physical' 'VLAN' 'IP-mode' 'IP' 'netmask' 'gateway' ) ;;
        "name") TITLES=( 'uuid' 'host-name-label' 'device' 'MAC' 'physical' 'VLAN' 'IP-mode' 'IP' 'netmask' 'gateway' ) ;;
    esac

    # Creating COLLONGEST array 
    case "$MODE" in 
        "uuid")
                    COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${pif_uuid[@]}")
                    COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${pif_host_uuid[@]}")
	                COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${pif_device[@]}")
	                COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${pif_MAC[@]}")
	                COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${pif_physical[@]}") 
                    COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${pif_VLAN[@]")
	                COLLONGEST[6]=$(getcolwidth "${TITLES[6]}" "${pif_IP_configuration_mode[@]}")
	                COLLONGEST[7]=$(getcolwidth "${TITLES[7]}" "${pif_IP[@]}")
	                COLLONGEST[8]=$(getcolwidth "${TITLES[8]}" "${pif_netmask[@]}")
	                COLLONGEST[9]=$(getcolwidth "${TITLES[9]}" "${pif_gateway[@]}")
                ;;
        "name") 
                    COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${pif_uuid[@]}")
                    COLLONGEST[1]=$(getcolwidth "${TITLES[0]}" "${pif_host_name_label[@]}")
	                COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${pif_device[@]}")
	                COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${pif_MAC[@]}")
	                COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${pif_physical[@]}") 
                    COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${pif_VLAN[@]")
	                COLLONGEST[6]=$(getcolwidth "${TITLES[6]}" "${pif_IP_configuration_mode[@]}")
	                COLLONGEST[7]=$(getcolwidth "${TITLES[7]}" "${pif_IP[@]}")
	                COLLONGEST[8]=$(getcolwidth "${TITLES[8]}" "${pif_netmask[@]}")
	                COLLONGEST[9]=$(getcolwidth "${TITLES[9]}" "${pif_gateway[@]}")
                ;;
    esac 
 
    # Printing header for PIF intformation 
    case "$MODE" in
        "uuid")
          echo "PIF Information for Network: ${network_uuids[0]}" 
          echo "" ;;
        "name") 
          echo "PIF Information for Network: ${network_name_label[0]}"
          echo "" ;;
    esac 

    # Printing columns and PIF information
    printheadings
	for i in $(seq 0 $(( ${#pif_uuid[@]} - 1 )) ) ;do
        case "$MODE" in 
           "uuid")
                cecho "${pif_uuid[$i]}" blue 			                ; printspaces "${COLLONGEST[0]}" "${#pif_uuid[$i]}"
                cecho "${pif_host_uuid[$i]}" blue 			            ; printspaces "${COLLONGEST[1]}" "${#pif_host_uuid[$i]}" 
		        cecho "${pif_device[$i]}" blue 			                ; printspaces "${COLLONGEST[2]}" "${#pif_device[$i]}"
		        cecho "${pif_MAC[$i]}" blue 			                ; printspaces "${COLLONGEST[3]}" "${#pif_MAC[$i]}"
		        cecho "${pif_physical[$i]}" blue 			            ; printspaces "${COLLONGEST[4]}" "${#pif_physical[$i]}"
		        cecho "${pif_VLAN[$i]}" blue 			                ; printspaces "${COLLONGEST[5]}" "${#pif_VLAN[$i]}"
   		        cecho "${pif_IP_configuration_mode[$i]}" blue 			; printspaces "${COLLONGEST[6]}" "${#pif_IP_configuration_mode[$i]}" 
		        cecho "${pif_IP[$i]}" blue 			                    ; printspaces "${COLLONGEST[7]}" "${#pif_IP[$i]}"
		        cecho "${pif_netmask[$i]}" blue 			            ; printspaces "${COLLONGEST[8]}" "${#pif_netmask[$i]}"
		        cecho "${pif_gateway[$i]}" blue 			            ; printspaces "${COLLONGEST[9]}" "${#pif_gateway[$i]}"
                echo ""
            ;;	
           "name")
                cecho "${pif_uuid[$i]}" blue 			                ; printspaces "${COLLONGEST[0]}" "${#pif_uuid[$i]}"
                cecho "${pif_host_name_label[$i]}" blue 			    ; printspaces "${COLLONGEST[1]}" "${#pif_host_name_label[$i]}" 
		        cecho "${pif_device[$i]}" blue 			                ; printspaces "${COLLONGEST[2]}" "${#pif_device[$i]}"
		        cecho "${pif_MAC[$i]}" blue 			                ; printspaces "${COLLONGEST[3]}" "${#pif_MAC[$i]}"
		        cecho "${pif_physical[$i]}" blue 			            ; printspaces "${COLLONGEST[4]}" "${#pif_physical[$i]}"
		        cecho "${pif_VLAN[$i]}" blue 			                ; printspaces "${COLLONGEST[5]}" "${#pif_VLAN[$i]}"
   		        cecho "${pif_IP_configuration_mode[$i]}" blue 			; printspaces "${COLLONGEST[6]}" "${#pif_IP_configuration_mode[$i]}" 
		        cecho "${pif_IP[$i]}" blue 			                    ; printspaces "${COLLONGEST[7]}" "${#pif_IP[$i]}"
		        cecho "${pif_netmask[$i]}" blue 			            ; printspaces "${COLLONGEST[8]}" "${#pif_netmask[$i]}"
		        cecho "${pif_gateway[$i]}" blue 			            ; printspaces "${COLLONGEST[9]}" "${#pif_gateway[$i]}"
                echo ""
            ;;
        esac
    done
}

setup
while getopts :dcunh:x opt ;do
        case $opt in
                d) set -x ;;
                h) syntax ;;
                c) CSV="yes" ;;
                u) MODE="uuid" ;;
                n) MODE="name" ;;
                x) NETWORKUUID=$OPTARG ;;
                \?) echo "Unknown option"; syntax ;;
        esac
done
shift $(($OPTIND - 1))
getnetinfo

echo ""
 
if ! [[ "${network_PIF_uuids[0]}" == "" ]] ; then
    getnetpifinfo
else
    echo "NO PIFS PRESENT"
fi

if ! [[ "${network_VIF_uuids[0]}" == "" ]] ; then
    getnetvifinfo
else
    echo "NO VIFS PRESENT"
fi

echo ""









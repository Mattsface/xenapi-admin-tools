#!/bin/bash
# Lists all information about a XCP/Xenserver network 
# Author: Matthew Spah (spahmatthew@gmail.com)
# Version: .0.1
# Date: 04/19/2013
# shownetwork - show all information about the network including the ethernet device, the settings, the VLAN, the type of network the vifs plugged into it, the VMs possessing those, etc..
source xaptools.lib

setup()
{
	SCRIPTDIR=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
	source "$SCRIPTDIR/xaptools.lib" 
	setcolors	
	DEFSPACE="5"
	MINSPACE="$DEFSPACE"
	MODE="name"
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
        echo "-x - Network UUID"
		echo "-s <host> - remote poolmaster host"
		echo "-p <password> - remote poolmaster password"
		echo "-h - this help text"
		echo "-w - number of whitespaces between columns"
		echo ""
		exit
}



getnetinfo()
{

    # Setting title array depending on $MODE
	TITLES=( 'Network' 'MTU' 'Bridge' 'Port Security' 'Tags' )
	getcmddata network-list uuid="$NETWORKUUID" params="uuid,name-label,bridge,MTU,default-locking-mode,tags,VIF-uuids,PIF-uuids"

	# Creating COLLONGEST array 
	COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${network_name_label[@]}")
	COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${network_MTU[@]}")
	COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${network_bridge[@]}")
	COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${network_default_locking_mode[@]}")
	COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${network_tags[@]}")
	
	# Printing columns and network information
	echo "Network information"
	printheadings
	cecho "${network_name_label[0]}" red             ; printspaces "${COLLONGEST[0]}" "${#network_name_label[0]}"
	cecho "${network_MTU[0]}" red                    ; printspaces "${COLLONGEST[1]}" "${#network_MTU[0]}"
	cecho "${network_bridge[0]}" red                 ; printspaces "${COLLONGEST[2]}" "${#network_bridge[0]}"
	cecho "${network_default_locking_mode[0]}" red   ; printspaces "${COLLONGEST[3]}" "${#network_default_locking_mode[0]}"
	cecho "${network_tags[0]}" red                   ; printspaces "${COLLONGEST[4]}" "${#network_tags[0]}"
	echo ""

}



getnetvifinfo()
{

	# Gathering VIF data for $NETWORKUUID
	getcmddata vif-list network-uuid="$NETWORKUUID" params="uuid,vm-uuid,vm-name-label,device,locking-mode,currently-attached,MAC"

	# Setting title array depending on $MODE
    case "$MODE" in 
        "uuid")
            TITLES=( 'UUID' 'VM-UUID' 'Dev' 'Locking-mode' 'Attached' 'MAC' ) ;;
		"name")
            TITLES=( 'UUID' 'VM-NAME-LABEL' 'Dev' 'Mac' 'Locking-mode' 'Attached' ) ;;
        "mixed")
            TITLES=( 'UUID' 'VM-NAME-LABEL' 'VM-UUID' 'Device' 'Locking-mode' 'Attached' 'MAC' ) ;;
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
			COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${vif_MAC[@]}")
			COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${vif_locking_mode[@]}")
			COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${vif_currently_attached[@]}")
			;;
        "mixed")
            COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${vif_uuid[@]}")
            COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${vif_vm_name_label[@]}")
			COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${vif_vm_uuid[@]}")
            COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${vif_device[@]}")
            COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${vif_locking_mode[@]}")
            COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${vif_currently_attached[@]}")
            COLLONGEST[6]=$(getcolwidth "${TITLES[6]}" "${vif_MAC[@]}")
	esac

	# Printing columns and VIF information
	echo "VIF information"
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
				cecho "${vif_vm_name_label[$i]}" blue 		; printspaces "${COLLONGEST[1]}" "${#vif_vm_name_label[$i]}"
				cecho "${vif_device[$i]}" blue 		        ; printspaces "${COLLONGEST[2]}" "${#vif_device[$i]}"
				cecho "${vif_MAC[$i]}" blue 			    ; printspaces "${COLLONGEST[3]}" "${#vif_MAC[$i]}"
				cecho "${vif_locking_mode[$i]}" blue 	    ; printspaces "${COLLONGEST[4]}" "${#vif_locking_mode[$i]}"
				cecho "${vif_currently_attached[$i]}" blue 	; printspaces "${COLLONGEST[5]}" "${#vif_currently_attached[$i]}"
				echo "" ;;
            "mixed")		
				cecho "${vif_uuid[$i]}" blue 			    ; printspaces "${COLLONGEST[0]}" "${#vif_uuid[$i]}" 
				cecho "${vif_vm_name_label[$i]}" blue 		; printspaces "${COLLONGEST[1]}" "${#vif_vm_name_label[$i]}"
				cecho "${vif_vm_uuid[$i]}" blue 		    ; printspaces "${COLLONGEST[2]}" "${#vif_vm_uuid[$i]}"
				cecho "${vif_device[$i]}" blue 		        ; printspaces "${COLLONGEST[3]}" "${#vif_device[$i]}"
				cecho "${vif_locking_mode[$i]}" blue 	    ; printspaces "${COLLONGEST[4]}" "${#vif_locking_mode[$i]}"
				cecho "${vif_currently_attached[$i]}" blue 	; printspaces "${COLLONGEST[5]}" "${#vif_currently_attached[$i]}"
				cecho "${vif_MAC[$i]}" blue 			    ; printspaces "${COLLONGEST[6]}" "${#vif_MAC[$i]}"
				echo "" ;;
        esac 
	done
	
}



getnetpifinfo()
{
	# Gathering PIF data
	getcmddata pif-list network-uuid="$NETWORKUUID" params="uuid,host-uuid,host-name-label,VLAN,device,MAC,IP-configuration-mode,IP,netmask,gateway"
	
	# Setting title array depending on $MODE
	case "$MODE" in 
		"uuid") TITLES=( 'UUID' 'Host-UUID' 'Dev' 'MAC' 'VLAN' 'IP-mode' 'IP' 'netmask' 'gateway' ) ;;
		"name") TITLES=( 'UUID' 'Hostname' 'Dev' 'MAC' 'VLAN' 'IP-mode' 'IP' 'netmask' 'gateway' ) ;;
		"mixed") TITLES=( 'UUID' 'Host-UUID' 'Dev' 'MAC' 'VLAN' 'IP-mode' 'IP' 'netmask' 'gateway' ) ;;
	esac

	# Creating COLLONGEST array 
	case "$MODE" in 
		"uuid")
					COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${pif_uuid[@]}")
					COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${pif_host_uuid[@]}")
					COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${pif_device[@]}")
					COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${pif_MAC[@]}")
					COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${pif_VLAN[@]}")
					COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${pif_IP_configuration_mode[@]}")
					COLLONGEST[6]=$(getcolwidth "${TITLES[6]}" "${pif_IP[@]}")
					COLLONGEST[7]=$(getcolwidth "${TITLES[7]}" "${pif_netmask[@]}")
					COLLONGEST[8]=$(getcolwidth "${TITLES[8]}" "${pif_gateway[@]}")
				;;
		"name") 
					COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${pif_uuid[@]}")
					COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${pif_host_name_label[@]}")
					COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${pif_device[@]}")
					COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${pif_MAC[@]}")
					COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${pif_VLAN[@]}")
					COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${pif_IP_configuration_mode[@]}")
					COLLONGEST[6]=$(getcolwidth "${TITLES[6]}" "${pif_IP[@]}")
					COLLONGEST[7]=$(getcolwidth "${TITLES[7]}" "${pif_netmask[@]}")
					COLLONGEST[8]=$(getcolwidth "${TITLES[8]}" "${pif_gateway[@]}")
				;;
		"mixed") 
					COLLONGEST[0]=$(getcolwidth "${TITLES[0]}" "${pif_uuid[@]}")
					COLLONGEST[1]=$(getcolwidth "${TITLES[1]}" "${pif_host_name_label[@]}")
					COLLONGEST[2]=$(getcolwidth "${TITLES[2]}" "${pif_device[@]}")
					COLLONGEST[3]=$(getcolwidth "${TITLES[3]}" "${pif_MAC[@]}")
					COLLONGEST[4]=$(getcolwidth "${TITLES[4]}" "${pif_VLAN[@]}")
					COLLONGEST[5]=$(getcolwidth "${TITLES[5]}" "${pif_IP_configuration_mode[@]}")
					COLLONGEST[6]=$(getcolwidth "${TITLES[6]}" "${pif_IP[@]}")
					COLLONGEST[7]=$(getcolwidth "${TITLES[7]}" "${pif_netmask[@]}")
					COLLONGEST[8]=$(getcolwidth "${TITLES[8]}" "${pif_gateway[@]}")
				;;
	esac 
 
	# Printing columns and PIF information
	echo "PIF information"
	printheadings
	for i in $(seq 0 $(( ${#pif_uuid[@]} - 1 )) ) ;do
		case "$MODE" in 
		   "uuid")
				cecho "${pif_uuid[$i]}" blue 			                ; printspaces "${COLLONGEST[0]}" "${#pif_uuid[$i]}"
				cecho "${pif_host_uuid[$i]}" blue 			            ; printspaces "${COLLONGEST[1]}" "${#pif_host_uuid[$i]}" 
				cecho "${pif_device[$i]}" blue 			                ; printspaces "${COLLONGEST[2]}" "${#pif_device[$i]}"
				cecho "${pif_MAC[$i]}" blue 			                ; printspaces "${COLLONGEST[3]}" "${#pif_MAC[$i]}"
				cecho "${pif_VLAN[$i]}" blue 			                ; printspaces "${COLLONGEST[4]}" "${#pif_VLAN[$i]}"
   				cecho "${pif_IP_configuration_mode[$i]}" blue 			; printspaces "${COLLONGEST[5]}" "${#pif_IP_configuration_mode[$i]}" 
				cecho "${pif_IP[$i]}" blue 			                    ; printspaces "${COLLONGEST[6]}" "${#pif_IP[$i]}"
				cecho "${pif_netmask[$i]}" blue 			            ; printspaces "${COLLONGEST[7]}" "${#pif_netmask[$i]}"
				cecho "${pif_gateway[$i]}" blue 			            ; printspaces "${COLLONGEST[8]}" "${#pif_gateway[$i]}"
				echo ""
			;;	
		   "name")
				cecho "${pif_uuid[$i]}" blue 			                ; printspaces "${COLLONGEST[0]}" "${#pif_uuid[$i]}"
				cecho "${pif_host_name_label[$i]}" blue 			    ; printspaces "${COLLONGEST[1]}" "${#pif_host_name_label[$i]}" 
				cecho "${pif_device[$i]}" blue 			                ; printspaces "${COLLONGEST[2]}" "${#pif_device[$i]}"
				cecho "${pif_MAC[$i]}" blue 			                ; printspaces "${COLLONGEST[3]}" "${#pif_MAC[$i]}"
				cecho "${pif_VLAN[$i]}" blue 			                ; printspaces "${COLLONGEST[4]}" "${#pif_VLAN[$i]}"
   				cecho "${pif_IP_configuration_mode[$i]}" blue 			; printspaces "${COLLONGEST[5]}" "${#pif_IP_configuration_mode[$i]}" 
				cecho "${pif_IP[$i]}" blue 			                    ; printspaces "${COLLONGEST[6]}" "${#pif_IP[$i]}"
				cecho "${pif_netmask[$i]}" blue 			            ; printspaces "${COLLONGEST[7]}" "${#pif_netmask[$i]}"
				cecho "${pif_gateway[$i]}" blue 			            ; printspaces "${COLLONGEST[8]}" "${#pif_gateway[$i]}"
				echo ""
			;;
		   "mixed")
				cecho "${pif_uuid[$i]}" blue 			                ; printspaces "${COLLONGEST[0]}" "${#pif_uuid[$i]}"
				cecho "${pif_host_name_label[$i]}" blue 			    ; printspaces "${COLLONGEST[1]}" "${#pif_host_name_label[$i]}" 
				cecho "${pif_device[$i]}" blue 			                ; printspaces "${COLLONGEST[2]}" "${#pif_device[$i]}"
				cecho "${pif_MAC[$i]}" blue 			                ; printspaces "${COLLONGEST[3]}" "${#pif_MAC[$i]}"
				cecho "${pif_VLAN[$i]}" blue 			                ; printspaces "${COLLONGEST[4]}" "${#pif_VLAN[$i]}"
   				cecho "${pif_IP_configuration_mode[$i]}" blue 			; printspaces "${COLLONGEST[5]}" "${#pif_IP_configuration_mode[$i]}" 
				cecho "${pif_IP[$i]}" blue 			                    ; printspaces "${COLLONGEST[6]}" "${#pif_IP[$i]}"
				cecho "${pif_netmask[$i]}" blue 			            ; printspaces "${COLLONGEST[7]}" "${#pif_netmask[$i]}"
				cecho "${pif_gateway[$i]}" blue 			            ; printspaces "${COLLONGEST[8]}" "${#pif_gateway[$i]}"
				echo ""
			;;
		esac
	done
}

setup
while getopts :dcunhx: opt ;do
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

# If no network UUID argument is passed, launch show_arraymenu
if [ -z "$NETWORKUUID" ]; then 
    getcmddata network-list params=uuid
    NETWORKUUID=$(show_arraymenu network_uuid)
fi

# Display Network Information
getnetinfo

# If no PIFs are present, we don't run getnetpifinfo
if ! [[ "${network_PIF_uuids[0]}" == "" ]] ; then
	getnetpifinfo
else
	echo ""
	echo "No PIFs present"
fi

# If no VIFs are present, we don't run getnetvifinfos
if ! [[ "${network_VIF_uuids[0]}" == "" ]] ; then
	getnetvifinfo
else
	echo ""
	echo "No VIFs present"
fi

echo ""









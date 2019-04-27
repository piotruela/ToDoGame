#!/bash/bin 



# Author           : Piotr Maszota ( pmaszota98@gmail.com )
# Created On       : 26.05.2018r.
# Last Modified By : Piotr Maszota ( pmaszota98@gmail.com )
# Last Modified On : 26.05.2018r. 
# Version          : 1.0
#
# Description      :
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


menu()
{    
    yad --question --image=dialog-question --title="Menu główne" \
    --text="Czy masz już konto?" \
    --button="Nie, chcę założyć konto":1 --button="Tak, chcę się zalogować":0 \
    --button="Wyjście z programu":2  
    foo=$?
    if [ $foo -eq 0 ] ; then 
        log_in;
    elif [ $foo -eq 1 ] ; then 
        create_account;   
    else
        return 2;     
    fi
}


create_account () 
{
    cd
    yad --info --title "Informacja" --button="OK!":0 --text "Program został stworzony aby pomóc Ci w organizacji dnia. Za każde wykonane zadanie otrzymasz punkty doświadczenia, za każde niewykonane zadanie stracisz punkty życia. Za systematyczność i pracowitość możesz otrzymać dodatkowe odznaki. Aby program spełnił swoje zadanie, wymagana jest Twoja szczerość"
    OUTPUT=$(yad --form --title="Nowe konto" --text "Wprowadź login i hasło"\
 --separator "," --button="Cofnij":1 --button="Stwórz konto":0 --button="Wyjdź z programu":2 \
    --field "Nazwa użytkownika" \
    --field "Hasło"  )
    foo=$?
    if [ $foo -eq 1 ] ; then
        return 1;
    elif [ $foo -eq 2 ] ; then 
        return 2;
    fi
    NAZWA=$(awk -F, '{print $1}' <<<$OUTPUT)
    HASLO=$(awk -F, '{print $2}' <<<$OUTPUT)  
    echo $NAZWA
    echo $HASLO
    cd ToDoGame;
    cd users;
    if [ -d "$NAZWA" -o "$NAZWA" == "zakazana" ] ; then
        yad --info --title "Zajęta nazwa" --text "Nazwa jest juz zajęta"
        create_account;
    fi
yad --info --title "Sukces" --button="Ok":0 --text="Rejestracja zakończona pomyślnie. Aby dodano Cię do bazy danych, konieczne będzie zresetowanie aplikacji"
    mkdir $NAZWA
    cd $NAZWA
    echo $NAZWA'|'$HASLO >> log_in.txt
    echo $NAZWA'|1|0|100' >> profile.txt
}


log_in () 
{
    OUTPUT=$(yad --form --title="Zaloguj" --text "Wprowadź login i hasło"\
    --separator "," --button="Cofnij":0 \
    --button="Zaloguj":2 \
    --field "Nazwa użytkownika" \
    --field "Hasło"  )
    foo=$?
    if [ $foo -eq 0 ] ; then
       return 1 
    fi
    NAZWA=$(awk -F, '{print $1}' <<<$OUTPUT)
    HASLO=$(awk -F, '{print $2}' <<<$OUTPUT)
    echo $NAZWA 
    echo $HASLO
    cd ToDoGame;
    cd users;
    if [ -d $NAZWA ] ; then  #jesli podany uzytkownik istnieje
    {
        cd $NAZWA;
        LOGIN=`cat log_in.txt | cut -d '|' -f 1`
        PASSWORD=`cat log_in.txt | cut -d '|' -f 2`
        echo $PASSWORD $HASLO
        if [ $PASSWORD = $HASLO ] ; then   #jesli haslo prawidlowe
            echo "Haslo sie zgadza"        
            return 3;
        else 
            yad --info --title "Błędne hasło" --text "Hasło niepoprawne" \
            --button="Spróbuj jeszcze raz"
            cd
            log_in;
        fi        
    }
    else 
        yad --info --title "Błędny login" \
    --text "Podanego użytkownika nie ma w bazie danych" --button="Spróbuj jeszcze raz"
    foo=$?
        if [ foo -eq 1 ] ; then 
           return 1;
        fi
    fi
}


profile_info () 
{
    LOGIN=`cat profile.txt | cut -d '|' -f 1`
    LVL=`cat profile.txt | cut -d '|' -f 2`
    EXP=`cat profile.txt | cut -d '|' -f 3`
    HP=`cat profile.txt | cut -d '|' -f 4`
    NEXT=$(($LVL * 100));
    yad --info --title="Informacje o profilu" --text=" Nazwa użytkownika:      $LOGIN\n Poziom:            $LVL\n Punkty doświadczenia:     $EXP/$NEXT\n Punkty życia:           $HP" \
    --button="Wróc do kokpitu":1
}


kokpit () 
{
    unset array
    unset newarray
    mapfile array < todo.txt
    index=0;
    for i in ${array[@]}
    {
        NAME[$index]=`echo ${array[$index]} |  cut -d '|' -f 1 `
        CATEG[$index]=`echo ${array[$index]} |  cut -d '|' -f 2 `
        IMPOR[$index]=`echo ${array[$index]} |  cut -d '|' -f 3 `
        DEADLINE[$index]=`echo ${array[$index]} |  cut -d '|' -f 4 `
        declare -a newarray=("${newarray[@]}" "${NAME[$index]}" "${CATEG[$index]}" \
        "${IMPOR[$index]}" " ${DEADLINE[$index]}")
        ((index++))
    }
    while [ 0 -eq 0 ] ; do
        OUTPUT=$(yad --list --height=600 --title="Kokpit" --width=500 \
        --column="Treść zadania":TEXT \
        --column="Kategoria":TEXT \
        --column="Stopień ważności":TEXT \
        --column="Termin":TEXT "${newarray[@]}" \
        --button="Dodaj nowe zadanie":1 --button="Obejrzyj profil":2 \
        --button="Wyloguj":3 --button="Wyjdź z programu":4)
        foo=$?
        if [ $foo -eq 0 ] ; then 
            echo $OUTPUT
            NAME=`echo $OUTPUT |  cut -d '|' -f 1 `
            CATEG=`echo $OUTPUT |  cut -d '|' -f 2 `
            IMPOR=`echo $OUTPUT |  cut -d '|' -f 3 `
            DEADLINE=`echo $OUTPUT |  cut -d '|' -f 4 `
            yad --info --title="$NAME" --text="Treść zadania: $NAME \n Kategoria: $CATEG \n Stopień ważności: $IMPOR \n Termin: $DEADLINE \n" --button="Odznacz jako wykonane":5 \
            --button="Odznacz jako niewykonane":6 
            if [ $? -eq 5 ] ; then #zadanie wykonanie  
                LOGIN=`cat profile.txt | cut -d '|' -f 1`
                LVL=`cat profile.txt | cut -d '|' -f 2`
                EXP=`cat profile.txt | cut -d '|' -f 3`
                HP=`cat profile.txt | cut -d '|' -f 4`
                HP=$((HP + IMPOR))
                EXP=$((EXP + IMPOR * 5))
                BONUS_EXP=$((IMPOR * 5))
                PROMOTION=$((LVL * 100))
                echo $LVL
                echo $EXP $PROMOTION
                yad --info --title="Gratulacje" --text="Gratulacje! Za wykonanie tego zadania otrzymujesz $IMPOR punktów życia i $BONUS_EXP punktów doświadczenia" --button="Ok"
                sed -i "/$NAME/d" ./todo.txt
                if [ "$EXP" -gt "$PROMOTION" ] ; then                
                    EXP=0
                    LVL=$((LVL + 1))
                    yad --info --title="Gratulacje" --text="Gratulacje! Awansujesz na poziom $LVL" --button="Ok"
                fi
                echo $LOGIN'|'$LVL'|'$EXP'|'$HP > profile.txt
                unset array
                unset newarray
                mapfile array < todo.txt
                index=0;
                for i in ${array[@]}
                {
                    NAME[$index]=`echo ${array[$index]} |  cut -d '|' -f 1 `
                    CATEG[$index]=`echo ${array[$index]} |  cut -d '|' -f 2 `
                    IMPOR[$index]=`echo ${array[$index]} |  cut -d '|' -f 3 `
                    DEADLINE[$index]=`echo ${array[$index]} |  cut -d '|' -f 4 `
            declare -a newarray=("${newarray[@]}" "${NAME[$index]}" "${CATEG[$index]}" \
            "${IMPOR[$index]}" " ${DEADLINE[$index]}")
            ((index++))
            }
            else  #zadanie niewykonane
                LOGIN=`cat profile.txt | cut -d '|' -f 1`
                LVL=`cat profile.txt | cut -d '|' -f 2`
                EXP=`cat profile.txt | cut -d '|' -f 3`
                HP=`cat profile.txt | cut -d '|' -f 4`
                HP=$((HP - IMPOR))
                echo $LOGIN'|'$LVL'|'$EXP'|'$HP > profile.txt
                yad --info --title="Zadanie niewykonane" --text="Za niewykonanie tego zadania tracisz $IMPOR punktów życia" --button="Ok"
            if [ $HP -lt 0 ] ; then
                yad --info --title="Porażka" --text="Niestety, skończyły Ci się punkty zdrowia, Twoje konto zostanie usunięte" --button="Ok"
                cd
                cd ToDoGame
                cd users
                rm -d -f -r $LOGIN
                return 1;
            fi
            sed -i "/$NAME/d" ./todo.txt
            unset array
            unset newarray
            mapfile array < todo.txt
            index=0;
            for i in ${array[@]}
            {
                NAME[$index]=`echo ${array[$index]} |  cut -d '|' -f 1 `
                CATEG[$index]=`echo ${array[$index]} |  cut -d '|' -f 2 `
                IMPOR[$index]=`echo ${array[$index]} |  cut -d '|' -f 3 `
                DEADLINE[$index]=`echo ${array[$index]} |  cut -d '|' -f 4 `
            declare -a newarray=("${newarray[@]}" "${NAME[$index]}" "${CATEG[$index]}" \
            "${IMPOR[$index]}" " ${DEADLINE[$index]}")
            ((index++))
            }
        fi
    elif [ $foo -eq 3 ] ; then
        cd
        return 1;
    elif [ $foo -eq 1 ] ; then
        add_task;
        unset array
        unset newarray
        mapfile array < todo.txt
        index=0;
        for i in ${array[@]}
        {
        NAME[$index]=`echo ${array[$index]} |  cut -d '|' -f 1 `
        CATEG[$index]=`echo ${array[$index]} |  cut -d '|' -f 2 `
        IMPOR[$index]=`echo ${array[$index]} |  cut -d '|' -f 3 `
        DEADLINE[$index]=`echo ${array[$index]} |  cut -d '|' -f 4 `
        declare -a newarray=("${newarray[@]}" "${NAME[$index]}" "${CATEG[$index]}" \
        "${IMPOR[$index]}" " ${DEADLINE[$index]}")
        ((index++))
        }
    elif [ $foo -eq 2 ] ; then
        profile_info;
    elif [ $foo -eq 4 ] ; then
        return 2;
    fi
    done
}
add_task ()
{
    OUTPUT=$(yad --form --title="Nowe zadanie" --text "Wprowadź nowe zadanie"\
    --separator "," --button="Cofnij":0 \
    --button="Zatwierdź":2 \
    --field "Treść zadania" \
    --field "Kategoria":CB \
    --field "Stopień ważności":CB \
    --field "Termin zadania":DT  "" 'Studia!Obowiązki domowe!Rozrywka!Kondycja fizyczna! Kondycja psychiczna!Hobby!Rodzina!Praca' '1!2!3!4!5!6!7!8!9' ""  )
    foo=$?
    echo $OUTPUT
    NAME=$(awk -F, '{print $1}' <<<$OUTPUT)
    CATEG=$(awk -F, '{print $2}' <<<$OUTPUT)
    IMPOR=$(awk -F, '{print $3}' <<<$OUTPUT)
    DEADLINE=$(awk -F, '{print $4}' <<<$OUTPUT)
    echo $NAME'|'$CATEG'|'$IMPOR'|'$DEADLINE >> todo.txt
    NEW_LINE="$NAME'|'$CATEG'|'$IMPOR'|'$DEADLINE"
}

###############MAIN#############################

yad --info --title="ToDoGame" --width=300 --text="Witaj w ToDoGame" --button="Przejdź dalej":0
while [ 0 -eq 0 ] ; do 
    menu;
    foo=$?
    if [ $foo -eq 2 ] ; then 
        break
    elif [ $foo -eq 3 ] ; then 
        kokpit;
        if [ $? -eq 2 ] ; then 
            break
        fi
    fi
done
cd

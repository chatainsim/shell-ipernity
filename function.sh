check_api(){
  if [ "$APIKEY" == "" ];then
    echo -e "\n############################################################"
    echo -e "\nError, you have to put you API key in the config.sh file\n"
    echo -e "Go here to get an API key : http://www.ipernity.com/apps/key/0\n"
    echo -e "############################################################\n"
    echo -e "Then when you have your API key, give it to me then I will update the configuration file :"
    echo -e "If you when to do it yourself, press CTRL+C then edit the config.sh file."
    read ApI
    echo -e "I will do the same with your secret key :"
    read KeY
    if [ -f "config.sh" ]; then
        cp config.sh config.sh.old
    fi
    echo "APIKEY=$ApI" > config.sh
    echo "APISECRET=$KeY" >> config.sh
    echo "APIFORMAT=json" >> config.sh
  fi
}
get_token() {
  . config.sh
  JSON_STRING=`call_api_method $APIKEY $APISECRET $APIFORMAT auth.getFrob`
  FROB=`echo "$JSON_STRING" | tr "\"" " " | awk ' { print $6 } '`
  echo "Goto "`get_user_auth $APIKEY $APISECRET $FROB perm_doc=write perm_blog=write`
  echo "and grant the permissions, then press <ENTER>"; read LINE
  JSON_STRING=`call_api_method $APIKEY $APISECRET $APIFORMAT auth.getToken frob=$FROB`
  TOKEN=`echo "$JSON_STRING" | tr "\"" " " | awk ' { print $6 } '`
  echo "Adding your token key to your config file ..."
  echo "TOKEN=$TOKEN" >> config.sh
  echo "Done, you can restart the script again. Thank you."
  exit 0
}
get_quota() {
  call_api_method $APIKEY $APISECRET $APIFORMAT account.getQuota auth_token=$TOKEN
}
upload_a_file() {
  call_api_method $APIKEY $APISECRET $APIFORMAT upload.file auth_token=$TOKEN file="$FILENAME" album_id=$ALBUM_ID
}
check_ticket() {
  call_api_method $APIKEY $APISECRET $APIFORMAT upload.checkTickets auth_token=$TOKEN tickets=$TICKET
}
show_quota(){
  MAX_QUOTA=`echo $TEST | awk -F ":" {'print $9 $10'} | awk -F "," {'print $2'} | awk -F "\"" {'print $4" "$2'}`
  USED_QUOTA=`echo $TEST | awk -F ":" {'print $14 $15'}| awk -F "," {'print $2'} | awk -F "\"" {'print $4" "$2'}`
  LEFT_QUOTA=`echo $TEST | awk -F ":" {'print $20 $21'}| awk -F "," {'print $2'} | awk -F "\"" {'print $4" "$2'}`
  IMG=`echo $TEST | awk -F ":" {'print $27 $28'}| awk -F "," {'print $2'} | awk -F "\"" {'print $4" "$2'}`
  AUDIO=`echo $TEST | awk -F ":" {'print $31 $32'}| awk -F "," {'print $2'} | awk -F "\"" {'print $4" "$2'}`
  VIDEO=`echo $TEST | awk -F ":" {'print $35 $36'}| awk -F "," {'print $2'} | awk -F "\"" {'print $4" "$2'}`
  OTHER=`echo $TEST | awk -F ":" {'print $39 $40'}| awk -F "," {'print $2'} | awk -F "\"" {'print $4" "$2'}`
  MAX_ALB=`echo $TEST | awk -F ":" {'print $42 $43'} | awk -F "," {'print $1'} | sed 's/"//g'`
  CREAT_ALB=`  echo $TEST | awk -F ":" {'print $42 $43'} | awk -F "\"" {'print $6'}`
  echo -e "\n   Here is infos about your account :\n"
  pro_is=`echo $TEST | awk -F ":" {'print $4'}| awk -F "," {'print $1'}| sed 's/"//g'`
  if [ "$pro_is" != "1" ]; then
    echo "	You does not have a Pro account, sorry."
  else
    echo "	Yeppy, you have a Pro account."
  fi
  echo -e "\n	Your quota max is $MAX_QUOTA."
  echo "	You already used $USED_QUOTA."
  echo "	You have $LEFT_QUOTA left."
  echo ""
  echo "	Max number of album is $MAX_ALB."
  echo "	You have already created $CREAT_ALB albums."
  echo ""
  echo "	The max filesize for photo is $IMG."
  echo "	The max filesize for audio is $AUDIO."
  echo "	The max filesize for video is $VIDEO."
  echo "	The max filesize for other is $OTHER."
  echo ""
}
get_album_id() {
  ID_ALB=`call_api_method $APIKEY $APISECRET $APIFORMAT album.getList auth_token=$TOKEN user_id=$USER per_page=9999`
  echo $ID_ALB | tr "\"" " " | grep -Po "album_id : [0-9]*" | awk {'print $3'} > tmp.alb
}
get_album() {
  ALB=`call_api_method $APIKEY $APISECRET $APIFORMAT album.get auth_token=$TOKEN album_id=$ID_ALBUM`
  echo $ALB | tr "\"" " " | grep -Po "title : [0-9a A-zZ/'-]*" | awk -F "title : " {'print $2'}
}
get_file_album() {
  FALB=`all_api_method $APIKEY album_id=$ID_ALBUM`
}
usage() {
	echo -e "\nNeed some help ?\nHow to use this script :\n"
	echo -e "\n  -q, --quota			Show you account information"
	echo -e "  -u, --upload			Upload a file"
	echo -e "  -f, --file FILENAME		Specified the file to upload"
	echo -e "  -a, --album ALBUM_ID		Specified the album id where to upload the file"
	echo -e "  -l, --list			List all your album with the id\n"
	echo -e "  Examples :"
	echo -e "  List all albums :		./ipernity.sh --list"
	echo -e "  Show quota :			./ipernity.sh --quota"
	echo -e "  Upload a file to an album :	./ipernity.sh --upload --album ALBUM_ID --file /mnt/photos/photos.jpg\n"
	echo -e " More to be added later.\n"
}

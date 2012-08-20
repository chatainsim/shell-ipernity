. Iper_API.sh
. function.sh
. config.sh
check_api
if [ "$TOKEN" == "" ]; then
	echo "Token is empty. We will try to get one for you..."
	get_token
fi
if [ "$1" == "" ];
then
        usage
        exit 1
fi
#get_token
TEST=`get_quota`
USER=`echo $TEST | tr "\"" " " | awk ' { print $6 } '`
while [ "$1" != "" ]; do
	case $1 in
		--new-album | -n )	shift
					NEW=1
					ALB_NAME="$1"
					shift
					;;
		--directory | -d )	shift
					DIRECT=1
					DIR="$1"
					shift
					;;
		--upload | -u )		shift
					UPLOAD=1
					;;
		--album | -a )		shift
					SET_ALBUM=1
					ALBUM_ID=$1
					shift
					;;
		--file | -f )		shift
					if [ "$1" != "" ]; then
						SET_FILE=1
						FILENAME="$1"
					else
						echo "Error, no file specified."
						exit 1
					fi
					shift
					;;
		--quota | -q )		show_quota
					exit 0
					;;
		--list | -l )		get_album_id
					while read FILE; do
						ID_ALBUM=$FILE
						echo $FILE";"`get_album`
					done < tmp.alb
					rm tmp.alb
					exit 0
					;;
		* )			usage
					exit 1
					;;
	esac
done
echo $ALB_NAME
if [ "$SET_ALBUM" != "1" ] || [ "$SET_FILE" != "1" ]; then
	echo "Error, file or folder empty, please check ..."
	exit 2
fi
if [ ! -f "$FILENAME" ]; then
	echo "Error, file does not exist."
	exit 2
fi
if [ "$UPLOAD" == "1" ]; then
	RESULT=`upload_a_file`
	TICKET=`echo $RESULT | awk -F "\"" {'print $4'}`
	while [ "$STATUS" != "1" ]; do
		RESULT=`check_ticket`
		STATUS=`echo $RESULT | awk -F "\"" {'print $6'}`
		SLEEP=`echo $RESULT | awk -F "\"" {'print $18'}`
		ERROR=`echo $RESULT | awk -F "\"" {'print $10'}`
		if [ "$STATUS" == "0" ] && [ "$ERROR" == "0" ]; then
			echo "Waiting for ticket $TICKET check during $SLEEP seconds ..."
			sleep $SLEEP
		else
			if [ "$STATUS" == "1" ]; then
				echo "Upload of file done with success."
				exit 0
			fi
			if [ "$ERROR" == "1" ]; then
				echo "Error on file upload."
				exit 2
			fi
		fi
	done
fi

#get_album_id
#while read FILE; do
#  ID_ALBUM=$FILE
#  echo $FILE";"`get_album`
#done < tmp.alb
#upload_a_file

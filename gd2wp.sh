#!/bin/bash

if ! pgrep dotoold > /dev/null;then
   dotoold &
   echo 'started dotoold'
fi

wp='https://yourwordpresssitegoeshere';


function wpSave {
   echo "Processing $1"
   echo "Opening $2"
   nohup vivaldi "$2"   >/dev/null 2>&1 &
   sleep 15

   #xdotool key ctrl+a
   kdotool search Vivaldi windowactivate;
   echo key ctrl+k:30 | dotoolc
   echo ctrl-a
   sleep 1
   #xdotool key ctrl+c
   echo key ctrl+k:46 | dotoolc
   echo ctrl-c
   sleep 1
   #xdotool key ctrl+w
   echo key ctrl+k:17 | dotoolc
   echo ctrl-w
   sleep 1
   echo prepare mousemove
   #xdotool mousemove 500 270 #eval $(xdotool getmouselocation --shell); echo $X $Y
   echo mouseto 0.25 0.26 | dotool
   echo mouse to Type/choose a block
   sleep 0.3
   #xdotool click 1
   echo click left | dotoolc
   echo clicked mouse
   sleep 0.3

   #xdotool key ctrl+v
   echo key ctrl+k:47 | dotoolc
   echo ctrl+v
   sleep 15
   #xdotool key ctrl+alt+shift+m
   echo key ctrl+alt+shift+k:50 | dotoolc
   echo ctrl+alt+shift+k:50
   sleep 2
   #xdotool mousemove 837 558 #eval $(xdotool getmouselocation --shell); echo $X $Y
   echo mousemove 20 150 | dotoolc
   sleep 0.3
   #xdotool click 1
   echo click left | dotool
   sleep 1
   #xdotool key ctrl+a
   echo key ctrl+k:30 | dotoolc
   sleep 1
   #xdotool key ctrl+c
   echo key ctrl+k:46 | dotoolc
   echo key ctrl+c
   sleep 1
   #xdotool key 'Delete'
   echo key k:111 | dotoolc
   echo key delete
   sleep 1
   #xdotool mousemove 1503 151 #eval $(xdotool getmouselocation --shell); echo $X $Y
   echo mouseto 0.78 0.125 | dotool
   sleep 0.5
   echo moved mouse to exit code editor
   #xdotool click 1
   echo click left | dotoolc
   sleep 2
   #xdotool mousemove 1540 88 #eval $(xdotool getmouselocation --shell); echo $X $Y
   echo mouseto 0.8 0.07 | dotool
   sleep 1
   echo mouse to save button
   sleep 0.3
   #xdotool click 1
   echo click left | dotoolc
   sleep 5
   wpfile="/Share/Data/KC/ThaiBG/vedabase/html4editing/wp.$i.txt"
   if [[ -f "$wpfile" ]]; then
      rm "$wpfile"
   fi
   #nohup kwrite "$wpfile"  >/dev/null 2>&1 &
   #sleep 3
   #xdotool search --name "wp.$i.txt" windowactivate
   #sleep 1
   #xdotool key ctrl+a
   #sleep 1
   #xdotool key 'Delete'
   #sleep 1
   #xdotool key ctrl+v
   #sleep 1
   #xdotool key ctrl+s
   #sleep 2
   #xdotool key ctrl+q
   xclip -o > "$wpfile"
   #xclip -o >  ~/xclip.txt
   echo "Finished with $i"
   exit




}
v=$(xdotool search --name 'Edit Post');
if [ "$v" == '' ];then
   echo "Didn't find Vivaldi, opening";

   nohup vivaldi "$wp"   >/dev/null 2>&1 &

   sleep 20

else
   echo "Vivaldi already opened, switching to it";
   xdotool windowactivate "$v"
fi
readarray -t array < chapterUrls.txt

for i in $(seq 0 20); do #total 20 pages, so "0 20"
   wpSave $i ${array[$i]}
done







#vivaldi "$wp"

#raw

#cd ../

#perl code4pdfhtml.pl

#cd xps4print


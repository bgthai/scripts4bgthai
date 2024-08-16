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

   xdotool key ctrl+a
   sleep 1
   xdotool key ctrl+c
   sleep 1
   xdotool key ctrl+w
   sleep 1
   #xdotool mousemove 535 302 #eval $(xdotool getmouselocation --shell); echo $X $Y
   #xdotool mousemove 500 260 #eval $(xdotool getmouselocation --shell); echo $X $Y
   xdotool mousemove 500 270 #eval $(xdotool getmouselocation --shell); echo $X $Y
   sleep 0.3
   xdotool click 1
   sleep 0.3
   xdotool key ctrl+v
   sleep 15
   xdotool key ctrl+alt+shift+m
   sleep 2
   xdotool mousemove 837 558 #eval $(xdotool getmouselocation --shell); echo $X $Y
   sleep 0.3
   xdotool click 1
   sleep 0.3
   xdotool key ctrl+a
   sleep 1
   xdotool key ctrl+c
   sleep 1
   xdotool key 'Delete'
   sleep 1
   xdotool mousemove 1503 151 #eval $(xdotool getmouselocation --shell); echo $X $Y
   sleep 0.3
   xdotool click 1
   sleep 2
   #to save button
   #xdotool mousemove 1579 83 #eval $(xdotool getmouselocation --shell); echo $X $Y
   xdotool mousemove 1540 88 #eval $(xdotool getmouselocation --shell); echo $X $Y
   sleep 0.3
   xdotool click 1
   sleep 5
   wpfile="/whereyouwanttosaveyourfiles/wp.$i.txt"
   if [[ -f "$wpfile" ]]; then
      rm "$wpfile"
   fi
   xclip -o > "$wpfile"
   echo "Finished with $i"




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


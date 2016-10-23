#!/bin/bash


# Unset globbing
set -f

# Now readarray delimits with newlines
IFS='
'

# No case sensitivity for string matching
shopt -s nocasematch

mysql << EOF
source create-table.sql
EOF

# Get master list of car models#{{{
model_list="cars-to-find"
flag=0
wget -O $model_list "http://parts.pickapart.ca/" && flag=1

if (( flag == 1 )); then
  echo "Page Download Success"
else
  echo "Page Download Failed"
  exit 1
fi


# Remove all lines that do not contain " - "
# The lines that do have this are the lines with the models of the cars we want.
sed -i '/ - /!d' $model_list

# Delete the beginning of the line that doesn't matter
sed -i 's/^.* - //' $model_list

# Delete the end of the line that doesn't Matter
sed -i "s@</option>@@g" $model_list

#}}}


readarray CARS < ./cars-to-find

let new_car_total_count=0
for CAR in "${CARS[@]}"; do
  echo "======================================================================="
  CAR=${CAR//$'\n'/}
  rm -rf "car_details"
# Find cars on the lot#{{{
echo "Downloading car list from webpage: http://parts.pickapart.ca/index.php"
echo "Car = ${CAR}"
# This submits a form on pickapart.ca to get a list of ${CAR}s in the lot.
flag=0
curl --form-string 'md=submit' --form-string "model=${CAR}" 'http://parts.pickapart.ca/index.php' > "car_details" && flag=1

# cp car_details ${CAR}_details
if (( flag == 1 )); then
  echo "2nd Page Download Success"
else
  echo "Page Download Failed"
  exit
fi

dos2unix car_details

# A newline followed by a closing td tag is to be appended to the previous line.
# In order to solve some issues where this part is on a different line for some
# vehicles
sed -i '$!N;s/\n\s*<\/td>/<\/td>/;P;D' car_details

# Remove all lines from html that are not necessary at all (before the parts we don't need, and after)#{{{

# Open ${CAR}_list_html
declare -a ARRAY
exec 10<&0
fileName="car_details"
exec < "$fileName"
let count=0

# Each line gets stored in an array.
while read LINE; do
  ARRAY[$count]=$LINE
  ((count++))
done

exec 0<&10 10<&-


# Used to find the lines we need.
regex="<tr [[:print:]]*photo-group[[:print:]]*</tr>"
#}}}

# make tdtags file that contains only the useful information.#{{{

ELEMENTS=${#ARRAY[@]}
firstLine=0


for((i=0;i<ELEMENTS;i++)); do
  if [[ ${ARRAY[${i}]} =~ $regex ]] ; then
    if (( firstLine < 1 )); then
      echo "${BASH_REMATCH[0]}" > car_details
      let firstLine=$firstLine+1
    else
      echo "${BASH_REMATCH[0]}" >> car_details
    fi
  fi
done

# At the end of all td tags start a new line.
sed -i "s@</td>@</td>\n@g" car_details


# Put urls on there on lines
sed -i "s@http@\nhttp@g" car_details | sed -in "s/\(^http[s]*:[a-Z0-9/.=?_-]*\)\(.*\)/\1/p"
# Delete all lines containing <tr bgcolor=
sed -i '/<tr bgcolor=/d' car_details
# Delete everything after the url on the line
sed -i 's/JPG.*/JPG/' car_details

# remove "<td>" from each line
sed -i "s@<td>@@g" car_details
# remove "</td>" from each line
sed -i "s@</td>@@g" car_details
# remove "</tr>" from each line
sed -i "s@</tr>@@g" car_details
#}}}

# Populate Arrays for the data for the new cars#{{{

# Open "${CAR}_tdtags_latest_cars"
declare -a DATE_ADDED
declare -a CAR_MAKE
declare -a CAR_MODEL
declare -a CAR_YEAR
declare -a CAR_BODY_STYLE
declare -a CAR_ENGINE
declare -a CAR_TRANSMISSION
declare -a CAR_DESCRIPTION
declare -a CAR_ROW
declare -a CAR_STOCK_NUMBERS
let date_added_count=0
let car_make_count=0
let car_model_count=0
let car_year_count=0
let car_body_style_count=0
let car_engine_count=0
let car_transmission_count=0
let car_description_count=0
let car_row_count=0
let car_stock_array_count=0

# CAR_ARRAY now contains all the car information for ${CAR}s.
# Note that bash does not have 2D arrays, so it is stored in a 1D array.

# Delete all lines containing "http"
sed -i '/http/d' car_details

exec 10<&0
fileName="car_details"
exec < "$fileName"

# index 0 = Date added
# index 1 = Make
# index 2 = Model
# index 3 = Year
# index 4 = Body Style (ex. 4DSDN, 2DCPE etc)
# index 5 = Engine
# index 6 = Transmission
# index 7 = Description
# index 8 = Row # (The row at the lot that the car is in)
# index 9 = Stock #

# index 10 = Date added for the next car
# etc
# Each line gets stored in an array.

let count=0
while read LINE; do
  # Get date added
  if (( count % 10 == 0 )); then
    DATE_ADDED[$date_added_count]=$LINE
    ((date_added_count++))
  # Get car make
  elif (( count % 10 == 1 )); then
    CAR_MAKE[$car_make_count]=$LINE
    ((car_make_count++))
  # Get car models
  elif (( count % 10 == 2 )); then
    CAR_MODEL[$car_model_count]=$LINE
    ((car_model_count++))
  # Get car year
  elif (( count % 10 == 3 )); then
    CAR_YEAR[$car_year_count]=$LINE
    ((car_year_count++))
  # Get car body styles
  elif (( count % 10 == 4 )); then
    CAR_BODY_STYLE[$car_body_style_count]=$LINE
    ((car_body_style_count++))
  # Get car engine type
  elif (( count % 10 == 5 )); then
    CAR_ENGINE[$car_engine_count]=$LINE
    ((car_engine_count++))
  # Get car transmission type
  elif (( count % 10 == 6 )); then
    CAR_TRANSMISSION[$car_transmission_count]=$LINE
    ((car_transmission_count++))
  # Get car description
  elif (( count % 10 == 7 )); then
    CAR_DESCRIPTION[$car_description_count]=$LINE
    ((car_description_count++))
  # Get car row
  elif (( count % 10 == 8 )); then
    CAR_ROW[$car_row_count]=$LINE
    ((car_row_count++))
  # Get stock numbers
  elif (( count % 10 == 9 )); then
    CAR_STOCK_NUMBERS[$car_stock_array_count]=$LINE
    ((car_stock_array_count++))
  fi

  ((count++))
done

exec 0<&10 10<&-

# number of cars = size of array / 10
num_of_cars_current=$car_stock_array_count


for((i=0;i<num_of_cars_current;i++)); do
mysql << EOF
use master_pickapart;
insert into cars values (
'${DATE_ADDED[$i]}',
'${CAR_MAKE[$i]}',
'${CAR_MODEL[$i]}',
${CAR_YEAR[$i]},
'${CAR_BODY_STYLE[$i]}',
'${CAR_ENGINE[$i]}',
'${CAR_TRANSMISSION[$i]}',
'${CAR_DESCRIPTION[$i]}',
'${CAR_ROW[$i]}',
'${CAR_STOCK_NUMBERS[$i]}'
);
EOF

done

#}}}

#}}}
done

unset IFS
set +f

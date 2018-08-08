#!/bin/bash

# Now readarray delimits with newlines
IFS='
'

# No case sensitivity for string matching
shopt -s nocasematch

#Name of the file that contains the necessary information.
ARGS_FILE=arguments_for_script

# If the arguments file exists then read the file and get the arguments, and
# insert them into the ncftpput command
if [ -e "$ARGS_FILE" ]; then
  # This is a file with three arguments that will be filled into the script
  # below.
  readarray -t ARGUMENTS < $ARGS_FILE

  #Username
  USER_ARG=${ARGUMENTS[0]}
  #server password
  PASS_ARG=${ARGUMENTS[1]}
fi

wget -O tmp.html http://www.pickapart.ca || exit 1

grep "<td " tmp.html > page.html

date=$(grep "class=\"body" tmp.html | \
       head -n 1 | \
       sed 's@^.*</strong>\s\+@@g' | \
       sed 's@-.*$@@g')

rm -rf tmp.html

sed -i 's@</tr>@@g' page.html
sed -i 's@<tr>@@g' page.html
sed -i 's/<td[^>]*>//g' page.html
sed -i 's@</td>@\n@g' page.html
sed -i 's@<br>\$@\n@g' page.html
sed -i 's/^\s\+//g' page.html
sed -i 's/\s\+$//g' page.html
sed -i '/^$/d' page.html

count=0
id=''

while read line; do
  ((count++))
  # Price
  if (( count % 2 == 0 )); then
    mysql -u "${USER_ARG}" -p"${PASS_ARG}" << EOF
    use stmhallc_cars;
    insert into on_sale_date values (
    ${id},
    STR_TO_DATE('${date}', '%b %d, %Y'),
    ${line}
    );
EOF

  # Item Name
  else
    id=$(mysql -s -u "${USER_ARG}" -p"${PASS_ARG}" << EOF
    use stmhallc_cars;
    select id from on_sale_items where item = '${line}' limit 1;
EOF
)

  if [ -z "${id}" ]; then
    mysql -u "${USER_ARG}" -p"${PASS_ARG}" << EOF
    use stmhallc_cars;
    insert into on_sale_items values (
    NULL,
    '${line}'
    );
EOF
  fi
  id=$(mysql -s -u "${USER_ARG}" -p"${PASS_ARG}" << EOF
  use stmhallc_cars;
  select id from on_sale_items where item = '${line}' limit 1;
EOF
)
  fi
done < page.html

rm -rf page.html

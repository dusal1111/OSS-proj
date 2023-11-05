#!/bin/bash
echo "--------------------------------"
echo "User Name: Yeonmi Kim"
echo "Student Number: 12223713"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------------"

stop="N"
until [ $stop = "Y" ]
do
	read -p "Enter your choice [ 1-9 ] " choice
	case $choice in
	1)
		echo
		read -p "Please enter the 'movie id'(1~1682):" movieid
		echo
		cat $1 | awk -F'|' -v id=$movieid '$1 == id {print $0}'
		echo
		;;
	2)
		echo
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n):" answer
		if [ $answer = "y" ]; then
			echo
			cat $1 | awk -F'|' '$7==1{print $1,$2}' | sort -n | head
		fi
		echo
		;;
	3)
		echo
		read -p "Please enter the 'movie id'(1~1682):" movieid
		ratings=$(cat $2 | awk -v id=$movieid '$2==id{print $3}')	
		num=$(echo $ratings | tr ' ' '\n' | wc -l)
		total=$(echo $ratings | tr ' ' '\n' | awk '{sum+=$1} END {print sum}')
		average=$(echo "scale=6; $total / $num" | bc | awk '{printf "%.6g", $0}')
		echo -e "\naverage rating of $movieid: $average \n"
		;;
	4)
		echo
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" answer
		if [ $answer = "y" ]; then
			echo
			head $1 | sed 's/|http[^|]*|/||/g'
		fi
		echo
		;;
	5)
		echo
		read -p "Do you want to get the data about users from 'u.user'?(y/n):" answer
		if [ $answer = "y" ]; then
			echo
			head $3 | awk -F'|' '{printf ("user %s is %s years old %s %s\n", $1, $2, ( $3 == "M" ) ? "male" : "female", $4)}'
		fi
		echo
		;;
	6)
		echo
		read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" answer
		if [ $answer = "y" ]; then
			echo
			tail $1 | sed 's/Jan/01/g' | sed 's/Feb/02/g' | sed 's/Mar/03/g' | sed 's/Apr/04/g' | sed 's/May/05/g' | sed 's/Jun/06/g' | sed 's/Jul/07/g' | sed 's/Aug/08/g' | sed 's/Sep/09/g' | sed 's/Oct/10/g' | sed 's/Nov/11/g' | sed 's/Dec/12/g' | sed -E 's/([0-9]{2})-([0-9]{2})-([0-9]{4})/\3\2\1/g'
		fi
		echo
		;;
	7)
		echo
		read -p "Please enter the 'user id'(1~943):" userid
		echo
		list=$(cat $2 | awk -v id=$userid 'id==$1{print $2}' | sort -n)
		echo $list | tr ' ' '|'
		echo
		list=$(echo $list | tr ' ' '\n' | head)
		for movieid in $list; do
			cat $1 | awk -F'|' -v id=$movieid '$1==id{printf ("%s|%s\n", $1, $2)}'
		done
		echo
		;;
	8)
		echo
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and occupation'as 'programmer'?(y/n):" answer
		if [ $answer = "y" ]; then
			echo
			users=$(cat $3 | awk -F'|' '$2<30 && $2>19 && $4=="programmer"{print $1}')
			list=""
			for userid in $users; do
				list+=$(cat $2 | awk -v id=$userid 'id==$1{print $2}')
				list+=" "
			done
			movielist=$(echo $list | tr ' ' '\n' | sort -n | uniq)
			for movieid in $movielist; do
				ratings=""
				for userid in $users; do
					ratings+=$(cat $2 | awk -v uid=$userid -v mid=$movieid '$1==uid && $2==mid{print $3}')
					ratings+=" "
				done
				num=$(echo $ratings | tr ' ' '\n' | wc -l)
				total=$(echo $ratings | tr ' ' '\n' | awk '{sum+=$1} END {print sum}')
				average=$(echo "scale=6; $total / $num" | bc | awk '{printf "%.6g", $0}')
				echo "$movieid $average"
			done
		fi
		;;
	9)
		echo "Bye!"
		stop="Y"
		;;
	*)
		echo "Error: Invalid input"
		;;
	esac
done
exit 0
		

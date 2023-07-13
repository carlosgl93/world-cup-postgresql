#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "truncate games, teams")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ -z $YEAR ]]
then
  break
fi 
if [[ $YEAR != "year" ]]
then
  TEAMWINNER="$($PSQL "select * from teams where name = '$WINNER'")"
  TEAMLOSER="$($PSQL "select * from teams where name = '$OPPONENT'")"
  if [[ -z $TEAMWINNER ]]
  then
    echo -e "\nteam winner wasnt  in the table, inserting\n";
    echo "$($PSQL "insert into teams(name) values('$WINNER')")"
  fi
  if [[ -z $TEAMLOSER ]]
  then
    echo -e "\nteam loser wasnt in the table, inserting\n" 
    echo "$($PSQL "insert into teams(name) values('$OPPONENT')")"
  fi

  WINNER_ID="$($PSQL "select team_id from teams where name = '$WINNER'")"
  OPPONENT_ID="$($PSQL "select team_id from teams where name = '$OPPONENT'")"
  MATCH="$($PSQL "select * from games as g right join teams as t on g.winner_id = t.team_id where winner_id = '$WINNER_ID' and opponent_id = '$OPPONENT_ID'")"
  
  if [[ -z $MATCH ]]
  then
    echo "$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', '$WINNER_ID', '$OPPONENT_ID', $WINNER_GOALS, $OPPONENT_GOALS)")"
  fi

fi

done

./queries.sh

#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess  -t -q --no-align -c"

echo "Enter your username:"
read USERNAME
Q_USERNAME=$($PSQL "SELECT username from users where username='$USERNAME';")

if [[ -z $Q_USERNAME ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME');"
 else 
  Q_NR_GAMES=$($PSQL "SELECT COUNT(game_id) from games where user_id=(select user_id from users where username='$USERNAME');") 
  Q_B_GAME=$($PSQL "SELECT min(finishing_round) from games where user_id=(select user_id from users where username='$USERNAME' ) group by user_id;")
  echo "Welcome back, $USERNAME! You have played $Q_NR_GAMES games, and your best game took $Q_B_GAME guess$( [[ $Q_B_GAME -ne 1 ]] && echo "es" )."
fi

GUESS=0
RN=$(( RANDOM % 1000 + 1 ))
ROUNDS=0
USER_ID=$($PSQL "SELECT user_id from users where username='$USERNAME';")
#$PSQL "INSERT INTO games(guess, correct_guess, round_id) VALUES($GUESS,$RN,$ROUNDS);"

echo "Guess the secret number between 1 and 1000:"
while [[ $GUESS -ne $RN ]]; do
  read GUESS
  ((ROUNDS++))
  if [[ $GUESS =~ ^-?[0-9]+$ ]];
    then
    if [[ $GUESS -eq $RN ]]; then
      echo "You guessed it in $ROUNDS tries. The secret number was $RN. Nice job!"
      $PSQL "INSERT INTO games(finishing_round,correct_guess,user_id) VALUES($ROUNDS,$RN,$USER_ID);"
      exit 0
    fi
    if [[ $GUESS -gt $RN ]]; then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    else echo "That is not an integer, guess again:"
  fi
done






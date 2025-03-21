#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")

if [[ -z $USER_ID ]]
then
  USER_INSERT_RESULT=$($PSQL "insert into users(name) values('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "select count(*) from games where user_id=$USER_ID")
  BEST_GAME=$($PSQL "select min(guesses) from games where user_id=$USER_ID")
  
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


NUMBER_TO_GUESS=$(($RANDOM % 1000 + 1))

echo "Guess the secret number between 1 and 1000:"
read GUESS

GUESSES=1

while (( NUMBER_TO_GUESS != GUESS ))
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if (( NUMBER_TO_GUESS < GUESS ))
    then
      echo "It's lower than that, guess again:"
    elif (( NUMBER_TO_GUESS > GUESS ))
    then
      echo "It's higher than that, guess again:"
    else
      break
    fi 

    GUESSES=$(( GUESSES + 1 ))
  fi

  read GUESS
done

INSERT_GUESS_RESULT=$($PSQL "insert into games(user_id, guesses) values($USER_ID, $GUESSES)")
echo "You guessed it in $GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
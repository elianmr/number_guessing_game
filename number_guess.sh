#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

# SECRET_NUMBER=$(shuf -i 1-1000 -n 1)
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

GUESS_NUMBER(){
  
if [[ $1 ]]
then
  USERNAME_SELECTED=$1
  IFS='|' read USERNAME GAMES_PLAYED BEST_GAME <<< "$USERNAME_SELECTED"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

  echo -e "\nGuess the secret number between 1 and 1000:"
   
  read NUMBER_ENTERED
  NUMBER_OF_GUESSES=1
  
  while [[ $NUMBER_ENTERED != $SECRET_NUMBER ]]
  do
        
   if [[ ! $NUMBER_ENTERED =~ ^[0-9]+$ ]]
    then
     echo -e "\nThat is not an integer, guess again:"
     read NUMBER_ENTERED
    else
     NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
     if [[ $NUMBER_ENTERED > $SECRET_NUMBER ]]
     then
       echo -e "\nIt's lower than that, guess again:"
       read NUMBER_ENTERED
      else [[ $NUMBER_ENTERED < $SECRET_NUMBER ]]
        echo -e "\nIt's higher than that, guess again:"
        read NUMBER_ENTERED
      fi
    fi

  done

  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

  GAMES_UPDATED=$((GAMES_PLAYED + 1))

  # fewest number of guesses it took that user to win the game
  if [[ $NUMBER_OF_GUESSES < $BEST_GAME || -z $BEST_GAME ]]
  then 
    UPDATE=$($PSQL "UPDATE users SET games_played = $GAMES_UPDATED, best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  else
    UPDATE=$($PSQL "UPDATE users SET games_played = $GAMES_UPDATED WHERE username = '$USERNAME'")
  fi

}

echo -e "\nEnter your username:"
read USERNAME_INPUT

USERNAME_SELECTED=$($PSQL "SELECT username,games_played,best_game FROM users WHERE username = '$USERNAME_INPUT'")

if [[ -z $USERNAME_SELECTED ]]
then

  USERNAME=$USERNAME_INPUT
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  
  INSERT=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',0,NULL)")
  GUESS_NUMBER

else
  GUESS_NUMBER $USERNAME_SELECTED
fi


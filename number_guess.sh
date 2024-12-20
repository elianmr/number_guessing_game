#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

SECRET_NUMBER=$(shuf -i 1-1000 -n 1)

echo -e "\nEnter your username:"
read USERNAME_INPUT

USERNAME=$($PSQL "SELECT username,games_played,best_game FROM users")

GUESS_NUMBER(){
  echo -e "\nGuess the secret number between 1 and 1000:"
  
  NUMBER_ENTERED=0
  NUMBER_OF_GUESSES=0
  
  while (( $NUMBER_ENTERED != SECRET_NUMBER ))
  do
    
    read NUMBER_ENTERED
    
    if [[ $NUMBER_ENTERED =~ ^[0-9+]$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
    else
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
      if [[ $NUMBER_ENTERED > $SECRET_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
      else [[ $NUMBER_ENTERED < $SECRET_NUMBER ]]
        echo -e "\nIt's higher than that, guess again:"
      fi
    fi
  done

  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  
  GAMES_UPDATED=$((GAMES_PLAYED + 1))

  # fewest number of guesses it took that user to win the game
  if [[ $NUMBER_OF_GUESSES < $BESTGAME ]]
  then 
    UPDATE=$($PSQL "UPDATE users SET games_played = $GAMES_UPDATED, best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  else
    UPDATE=$($PSQL "UPDATE users SET games_played = $GAMES_UPDATED WHERE username = '$USERNAME'")
  fi

}

if [[ -z $USERNAME ]]
then

  USERNAME=$USERNAME_INPUT
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  
  INSERT=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',0,0)") # MOVE TO THE END
  echo $INSERT
 
  GUESS_NUMBER

else
  echo $USERNAME | while IFS='|' read USERNAME GAMES_PLAYED BESTGAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BESTGAME guesses."
    GUESS_NUMBER
  done
fi


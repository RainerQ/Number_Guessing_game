#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


MAIN_PROGRAM(){

#Generate a random number
RANDOM_NUMBER=$((1 + RANDOM % 1000))
#echo $RANDOM_NUMBER

echo "Enter your username:"
read USER_INPUT



USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USER_INPUT'")
echo $USER_ID

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USER_INPUT! It looks like this is your first time here."
  FIRST_TIME=$($PSQL "INSERT INTO users(username) VALUES('$USER_INPUT')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USER_INPUT'")
  FIRST_TIME_GAMES=$($PSQL "INSERT INTO games(user_id) VALUES($USER_ID)")
  START_GUESSING $USER_ID $RANDOM_NUMBER

else
  USERNAME=$($PSQL "SELECT username FROM users WHERE user_id = '$USER_ID'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users FULL JOIN games USING(user_id) WHERE user_id = '$USER_ID'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users FULL JOIN games USING(user_id) WHERE user_id = '$USER_ID'")  
  
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

  START_GUESSING $USER_ID $RANDOM_NUMBER

fi


}

START_GUESSING(){

INPUT=$USER_ID
SECRET_NUMBER=$RANDOM_NUMBER
echo $SECRET_NUMBER


#echo $INPUT
(( NUMBER_OF_GUESSES ++ ))



echo "Guess the secret number between 1 and 1000:"
read INPUT_TO_GUESS


# Check if input is a number

if [[ ! $INPUT_TO_GUESS =~ ^[0-9]+$ ]]; 
then
    echo "That is not an integer, guess again:"
    START_GUESSING
else


    #Input is a number.
    if [[ $INPUT_TO_GUESS == $SECRET_NUMBER ]]
    then
      #FIRST_GAME_PLAYED=$($PSQL "INSERT INTO games(games_played) VALUES(1)")
      #INSERT_NUMBER_OF_GUESSES=$($PSQL "INSERT INTO users(username) VALUES('$USER_INPUT')")

      SAVE_USER $INPUT $NUMBER_OF_GUESSES 
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      
    elif [[ $INPUT_TO_GUESS > $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      START_GUESSING
    else
      echo "It's higher than that, guess again:" 
      START_GUESSING
    fi  



fi


}

SAVE_USER(){

GAMES_COUNT=1
NUMBER_OF_GUESSES_COUNT=$NUMBER_OF_GUESSES
BEST_GAME_COUNT=$NUMBER_OF_GUESSES_COUNT
INPUT_USER_ID=$INPUT

echo $GAMES_COUNT
echo $NUMBER_OF_GUESSES_COUNT
echo $BEST_GAME_COUNT
echo $INPUT_USER_ID

FIRST_INSERT=$($PSQL "UPDATE games SET number_of_guesses = '$NUMBER_OF_GUESSES_COUNT' WHERE user_id = '$INPUT_USER_ID'")
SECOND_INSERT=$($PSQL "UPDATE games SET best_game = '$BEST_GAME_COUNT' WHERE user_id = '$INPUT_USER_ID'")
THIRD_INSERT=$($PSQL "UPDATE games SET games_played = '$GAMES_COUNT' WHERE user_id = '$INPUT_USER_ID'")

#FIRST_INSERT=$($PSQL "INSERT INTO games(games_played) VALUES('$GAMES_COUNT') WHERE user_id = '$INPUT_USER_ID'")
#SECOND_INSERT=$($PSQL "INSERT INTO games(number_of_guesses) VALUES('$NUMBER_OF_GUESSES_COUNT') WHERE user_id = '$INPUT_USER_ID'")
#THIRD_INSERT=$($PSQL "INSERT INTO games(best_game) VALUES('$BEST_GAME_COUNT') WHERE user_id = '$INPUT_USER_ID'")
}







MAIN_PROGRAM




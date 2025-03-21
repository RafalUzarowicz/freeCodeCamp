#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

PRINT_ATOM_INFO() {
  if [[ -z $1 ]]
  then
    echo "Please provide an element as an argument."
    return
  fi

  ELEMENT_ATOMIC_OR_SYMBOL_OR_NAME=$1

  if [[ $ELEMENT_ATOMIC_OR_SYMBOL_OR_NAME =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where atomic_number=$ELEMENT_ATOMIC_OR_SYMBOL_OR_NAME")
  else
    ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where '$ELEMENT_ATOMIC_OR_SYMBOL_OR_NAME' in (symbol, name)")
  fi

  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
    return
  fi

  IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME <<< $($PSQL "select atomic_number, symbol, name from elements where atomic_number=$ATOMIC_NUMBER")
  IFS="|" read -r TYPE MASS MELTING BOILING <<< $($PSQL "select type, atomic_mass, melting_point_celsius, boiling_point_celsius from properties join types using(type_id) where atomic_number=$ATOMIC_NUMBER")

  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

PRINT_ATOM_INFO $1
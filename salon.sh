#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAKE_APPOINTMENT() {
  echo -e $1

  # Get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS='|' read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Get selected id
  read SERVICE_ID_SELECTED
  # if selected id not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAKE_APPOINTMENT "\nI could not find that service. What would you like today?\n"
  else
    AVAILABLE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if service not found
    if [[ -z $AVAILABLE_ID ]]
    then 
      MAKE_APPOINTMENT "\nI could not find that service. What would you like today?\n"
     else 
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      # get customer by phone number
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if not found
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # create new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      # Get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      
      read SERVICE_TIME
      # Get customer ID
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      echo "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAKE_APPOINTMENT "Welcome to My Salon, how can I help you?\n"


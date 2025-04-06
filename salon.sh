#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Display available services
echo -e "\nWelcome to the Salon! Here are our services:"
SERVICES=$($PSQL "SELECT service_id, name FROM services")

echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
do
  echo "$SERVICE_ID) $NAME"
done

# Prompt for service selection and validate
echo -e "\nPlease choose a service by entering its number:"
read SERVICE_ID_SELECTED

VALID_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

while [[ -z $VALID_SERVICE ]]
do
  echo -e "\nInvalid selection. Please try again:"
  
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  VALID_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

# Prompt for phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nYou're new! Please enter your name:"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Ensure CUSTOMER_ID is valid before booking appointment
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nSomething went wrong. Please try again."
  exit 1
fi

# Prompt for appointment time
echo -e "\nEnter your preferred appointment time:"
read SERVICE_TIME

$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

echo -e "\nI have put you down for a $VALID_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME. See you soon! 😊"

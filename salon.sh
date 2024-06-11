#!/bin/bash

# Command to run psql
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display services
display_services() {
  echo -e "\nHere are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
  done
}

# Main script
display_services

while true; do
  # Prompt for service ID
  echo -e "\nPlease enter the service ID you would like to schedule:"
  read SERVICE_ID_SELECTED

  # Check if service ID exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]; then
    echo "Invalid service ID. Please try again."
    display_services
    continue
  fi

  # Prompt for phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]; then
    # If customer does not exist, prompt for name
    echo -e "\nIt looks like you are a new customer. Please enter your name:"
    read CUSTOMER_NAME

    # Insert new customer into customers table
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  fi

  # Get customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  # Prompt for appointment time
  echo -e "\nPlease enter the time you would like to schedule the appointment:"
  read SERVICE_TIME

  # Insert appointment into appointments table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  # Output success message
  SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//g')
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *//g')
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  break
done

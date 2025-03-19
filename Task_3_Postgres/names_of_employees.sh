#!/bin/bash

# Prompt user for department name
read -p "Enter department name: " dept

# Run the query inside the PostgreSQL container
docker exec -it 3-db-db-1 psql -U ituser -d company_db -c "
SELECT first_name, last_name
FROM employees
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = '$dept');
"
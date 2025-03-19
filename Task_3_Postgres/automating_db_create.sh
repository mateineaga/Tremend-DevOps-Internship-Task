#!/bin/bash
rm log.txt

docker exec -it 3-db-db-2 psql -U postgres -c "
CREATE ROLE ituser WITH LOGIN PASSWORD 'password';
ALTER ROLE ituser CREATEDB;
"

docker exec -it 3-db-db-2 psql -U postgres -c "
CREATE ROLE admin_cee WITH LOGIN PASSWORD 'password';
ALTER ROLE admin_cee CREATEDB;
"

docker exec -it 3-db-db-2 psql -U postgres -c "
CREATE DATABASE company_db_copy OWNER ituser;
"

docker exec -i 3-db-db-2 psql -U ituser -d company_db_copy < /home/vagrant/pgdata/dump.sql

echo "First query" >> log.txt
echo "##########" >> log.txt
echo "" >> log.txt

docker exec -i 3-db-db-2 psql -U ituser -d company_db_copy -c "SELECT COUNT(*) FROM employees;" >> log.txt

echo "" >> log.txt
echo "######" >> log.txt
echo "" >> log.txt

echo "Second query" >> log.txt
echo "##########" >> log.txt
echo "" >> log.txt

read -p "Enter department name: " dept

docker exec -i 3-db-db-2 psql -U ituser -d company_db_copy -c "
SELECT first_name, last_name
FROM employees
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = '$dept');
" >> log.txt

echo "" >> log.txt
echo "######" >> log.txt
echo "" >> log.txt

echo "######" >> log.txt
echo "Third query" >> log.txt
echo "##########" >> log.txt
echo "" >> log.txt

docker exec -i 3-db-db-2 psql -U ituser -d company_db_copy -c "
SELECT d.department_name,
       MAX(s.salary) AS highest_salary,
MIN(s.salary) AS lowest_salary
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY d.department_name;
" >> log.txt

echo "" >> log.txt
echo "######" >> log.txt

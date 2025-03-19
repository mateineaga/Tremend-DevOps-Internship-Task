#!/bin/bash

docker exec -it 3-db-db-1 psql -U ituser -d company_db -c "
SELECT d.department_name,
       MAX(s.salary) AS highest_salary,
              MIN(s.salary) AS lowest_salary
              FROM employees e
              JOIN salaries s ON e.employee_id = s.employee_id
              JOIN departments d ON e.department_id = d.department_id
              GROUP BY d.department_name
              ORDER BY d.department_name;
              "
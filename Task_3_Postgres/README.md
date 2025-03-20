## Task 3 - Postgres queries

## 1. Pull and run a PostgreSQL container

I used a docker compose file to start the postgres container

```
services:
  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_USER: ituser
      POSTGRES_DB: company_db
    volumes:
      - /home/vagrant/pgdata:/var/lib/postgresql/data
```

Commands used to create a database called "company_db" and to switch to another user "ituser".

```
CREATE ROLE ituser WITH LOGIN PASSWORD 'password';

ALTER ROLE ituser CREATEDB;

CREATE DATABASE company_db OWNER ituser;
```

To check the creation of the database we use "\l" to see all the databases created. Afterwards we login to the user "ituser", to manipulate database "company_db" with the command:

```
psql -U ituser -d company_db
```

---

## 2. Create a dataset using the sql script provided

First we copy the script into the container with the command

```
docker cp /home/vagrant/Internship-Resources-2025/3-db/populatedb.sql 3-db-db-1:/populate_db.sql 
```

Then we connect to the container and run the script as being the "ituser" on "company_db" database, with the command:

```
psql -U ituser -d company_db -f /populate_db.sql
```


---

## 3. Run the following SQL queries

### 3.1 Find the total number of employees

To find the number of employees we use the command:

```
SELECT COUNT(*) FROM employees;
```

### 3.2 Retrieve the names of employees in a specific department by user input

I created a local script called "names_of_employees.sh", which prompts for user input and executes a command into docker container created earlier.

```
#!/bin/bash

read -p "Enter department name: " dept

docker exec -it 3-db-db-1 psql -U ituser -d company_db -c "
SELECT first_name, last_name
FROM employees
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = '$dept');
"
```

### 3.3 Calculate the highest and lowest salaries per department. 

To ensure easier setup for next steps from this tasks and for an easier use, I created a local script called "max_min_salaries.sh", which shows up the maximum and the minimum salary from each department. As the previous query, this query is executed into the docker container.

```
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
```

## 4. Dump the dataset into a file

To dump the current database I've used the following command. The directory where I dump the database is mounted on my local /home/vagrant/pgdata, so seeing it from this local directory confirms that everything went well.

```
pg_dump -U ituser -d company_db > /var/lib/postgresql/data/dump.sql
```


## 5. Write a Bash script that: Automates the database creation process, Creates a second admin user called "admin_cee", Imports the dataset created at Step 4., Executes the queries from Step 3 and outputs the results to a log file. 

```
docker compose -p myproject up -d
docker compose -p myproject down -d
rm -rf /home/vagrant/pgdata2/*
```

I modified the docker compose up, just to create a plain postgres database to test the automating script, with the following configuration:

```
services:
  db:
    image: postgres
    restart: always
    container_name: 3-db-db-1
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_USER: ituser
      POSTGRES_DB: company_db
    volumes:
      - /home/vagrant/pgdata:/var/lib/postgresql/data

  db2:
    image: postgres
    restart: always
    container_name: 3-db-db-2
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_USER: postgres
      POSTGRES_DB: postgres
    volumes:
      - /home/vagrant/pgdata2:/var/lib/postgresql/data
```

To ensure proper naming and proper volume control, the commands used were:

```
docker compose -p myproject up -d
docker compose -p myproject down -d
rm -rf /home/vagrant/pgdata2/*
```

The file "automating_db_create.sh" contains all the automating steps, previosuly implemented, but on a new postgres container.

```
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
```

The output have been saved to a logfile called "log.txt".

---

## Bonus

The volume have been mounted since the beginning, from local directory /home/vagrant/pgdata to /var/lib/postgresql/data, this being the directory where all the databases get stored. For the second one, the automated database, the host volume is /home/vagrant/pgdata2.

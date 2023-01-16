#!/bin/bash

read -p "Enter hostname: " hostname
read -p "Enter port: " port
read -p "Enter username: " username
read -p "Enter password: " -s password
read -p "Enter database name: " dbname

# Check if the user has enough privileges
result=$(mysql --protocol=TCP -h "$hostname" -P "$port" -u "$username" -p"$password" -D "$dbname" -e "SHOW GRANTS FOR CURRENT_USER();")
if ! echo "$result" | grep -q "ALL PRIVILEGES" && ! echo "$result" | grep -q "DROP" ; then
  echo "Error: User does not have enough privilege to drop tables"
  exit 1
fi

# Use the specified database
mysql --protocol=TCP -h "$hostname" -P "$port" -u "$username" -p"$password" -e "USE $dbname;"

# Disable foreign key checks
mysql --protocol=TCP -h "$hostname" -P "$port" -u "$username" -p"$password" -e "SET FOREIGN_KEY_CHECKS = 0;"

# Get list of tables
result=$(mysql --protocol=TCP -h "$hostname" -P "$port" -u "$username" -p"$password" -D "$dbname" -e "SHOW TABLES;")

# Iterate over each table and drop it
while read -r table; do
    mysql --protocol=TCP -h "$hostname" -P "$port" -u "$username" -p"$password" -D "$dbname" -e "DROP TABLE $table;"
done <<< "$result"

# Enable foreign key checks
mysql --protocol=TCP -h "$hostname" -P "$port" -u "$username" -p"$password" -e "SET FOREIGN_KEY_CHECKS = 1;"

echo "All tables have been dropped successfully"

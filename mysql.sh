#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense_shell_logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

USERID=$(id -u)

VALIDATION(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2... $R failure $N"
        exit 1
    else
        echo -e "$2...$G success $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR: you do not have access"
        exit 1
}

CHECK_ROOT

mkdir -p /var/log/expense_shell_logs

echo "scripted started and executed at: $TIMESTAMP" &>>$LOG_FILE_NAME

dnf install mysql-server -y  &>>$LOG_FILE_NAME
VALIDATION $? "installing mysql"

systemctl enable mysqld  &>>$LOG_FILE_NAME
VALIDATION $? "enabling mysqld"

systemctl start mysqld  &>>$LOG_FILE_NAME
VALIDATION $? "starting mysql server"

mysql_secure_installation --set-root-pass ExpenseApp@1  &>>$LOG_FILE_NAME
VALIDATION $? "setting password"

mysql -h mysql.santhoshdatti.online -u root -pExpenseApp@1 -e 'show databases';
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ExpenseApp@1  &>>$LOG_FILE_NAME
else
    echo "mysql password is already setup"
fi
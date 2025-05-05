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
    fi
}

CHECK_ROOT

mkdir -p /var/log/expense_shell_logs &>>$LOG_FILE_NAME

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATION $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATION $? "enabling nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATION $? "staring nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATION $? "removing files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATION $? "downlaoding the code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATION $? "switching to html directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATION $? "unzipping code"

cp /home/ec2-user/expense-shell-practice/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
VALIDATION $? "coping expense.conf"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATION $? "restart nginx"


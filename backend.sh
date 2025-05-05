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

mkdir -p /var/log/expense_shell_logs

echo "scripted started and executed at: $TIMESTAMP" &>>$LOG_FILE_NAME

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATION $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATION $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATION $? "installing nodejs"

id expense  &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATION $? "expense user added"
else
    echo -e "user is already $Y existed $N"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATION $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATION $? "downloading the code"

cd /app

rm -rf /app *

unzip /tmp/backend.zip &>>$LOG_FILE_NAME 
VALIDATION $? "unzipping of the code"

npm install &>>$LOG_FILE_NAME
VALIDATION $? "npm installation"

cp /home/ec2-user/expense-shell-practice/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
VALIDATION $? "coping backend.service"

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATION $? "installing mysql server"

mysql -h mysql.santhoshdatti.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATION $? "Setting up the transactions schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATION $? "backend reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATION $? "enable"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATION $? "restart backend"


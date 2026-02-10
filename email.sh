#!/bin/bash
# Check if the email address is provided as an argument
echo "hello world "
echo "Welcome to DevOps Training"
TO_ADDRESS="shaikvalims@gmail.com"
SUBJECT="Disk Utilization Alert"
EMAIL_BODY="TEST EMAIL FORM VALI"

{
echo "To: $TO_ADDRESS"
echo "Subject: $SUBJECT"
echo "Content-Type: text/html"
echo ""
echo "$EMAIL_BODY"
} | msmtp "$TO_ADDRESS"

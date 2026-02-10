#!/bin/bash

# Threshold for alert (e.g., 85%)
THRESHOLD=70

# Temporary file for HTML email
EMAIL_FILE="template.html"

# Collect disk usage details
DISK_USAGE=$(df -h --output=source,pcent,target | tail -n +2)

# Start HTML email
cat <<EOF > $EMAIL_FILE
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Disk Utilization Alert</title>
  <style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; }
    .container { background-color: #ffffff; max-width: 600px; margin: 20px auto;
                 border: 1px solid #ddd; border-radius: 6px; padding: 20px; }
    h2 { color: #d9534f; margin-top: 0; }
    .alert { background-color: #f8d7da; color: #721c24; padding: 10px;
             border-radius: 4px; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .footer { font-size: 12px; color: #888; text-align: center; margin-top: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <h2>🚨 Disk Utilization Alert</h2>
    <div class="alert">
      The following mount points have exceeded the disk usage threshold of ${THRESHOLD}%.
    </div>
    <table>
      <tr>
        <th>Filesystem</th>
        <th>Usage</th>
        <th>Mount Point</th>
      </tr>
EOF

# while IFS= read -r line; do
#     FS=$(echo $line | awk '{print $1}')
#     USAGE=$(echo $line | awk '{print $2}' | tr -d '%')
#     MOUNT=$(echo $line | awk '{print $3}')

#     # Always print the row
#     cat <<ROW >> $EMAIL_FILE
#       <tr>
#         <td>$FS</td>
#         <td>${USAGE}%</td>
#         <td>$MOUNT</td>
#       </tr>
# ROW


while IFS= read -r line; do
    FS=$(echo $line | awk '{print $1}')
    USAGE=$(echo $line | awk '{print $2}' | tr -d '%')
    MOUNT=$(echo $line | awk '{print $3}')

    if [ "$USAGE" -ge "$THRESHOLD" ]; then
        COLOR=" style=\"color:red; font-weight:bold;\""
    else
        COLOR=""
    fi

#     if [ "$USAGE" -ge "$THRESHOLD" ]; then
#     cat <<ROW >> $EMAIL_FILE
#       <tr>
#         <td>$FS</td>
#         <td>${USAGE}%</td>
#         <td>$MOUNT</td>
#       </tr>
# ROW
#fi


    cat <<ROW >> $EMAIL_FILE
      <tr>
        <td$COLOR>$FS</td>
        <td$COLOR>${USAGE}%</td>
        <td$COLOR>$MOUNT</td>
      </tr>
ROW
done <<< "$DISK_USAGE"

# if [ "$USAGE" -ge "$THRESHOLD" ]; then
#     COLOR=" style=\"color:red; font-weight:bold;\""
# else
#     COLOR=""
# fi


cat <<ROW >> $EMAIL_FILE
  <tr>
    <td$COLOR>$FS</td>
    <td$COLOR>${USAGE}%</td>
    <td$COLOR>$MOUNT</td>
  </tr>
ROW




cat <<EOF >> $EMAIL_FILE
    </table>
    <p>Please take immediate action to free up space or extend storage capacity.</p>
    <div class="footer">
      This is an automated message. Do not reply.
    </div>
  </div>
</body>
</html>
EOF

#!/bin/bash

TO="shaikvalims@gmail.com"
SUBJECT="Disk Utilization Alert"


{
  echo "To: $TO"
  echo "Subject: $SUBJECT"
  echo "Content-Type: text/html"
  echo
  cat $EMAIL_FILE
} | msmtp "$TO"

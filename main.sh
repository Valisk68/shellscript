#!/bin/bash

# Threshold for alert (e.g., 85%)
THRESHOLD=85

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


while read -r line; do
    FS=$(echo $line | awk '{print $1}')
    USAGE=$(echo $line | awk '{print $2}' | tr -d '%')
    MOUNT=$(echo $line | awk '{print $3}')

    if [ "$USAGE" -ge "$THRESHOLD" ]; then
        cat <<ROW >> $EMAIL_FILE
      <tr>
        <td>$FS</td>
        <td>${USAGE}%</td>
        <td>$MOUNT</td>
      </tr>
ROW
    fi
done <<< "$DISK_USAGE"



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


mailx -a "Content-Type: text/html" -s "Disk Utilization Alert" shaikvalims@gmail.com < $EMAIL_FILE

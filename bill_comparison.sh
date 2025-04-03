#!/bin/bash

# Database Credentials
DB_USER="your_user"
DB_PASS="your_password"
DB_SID="your_db"

# Output JavaScript File
OUTPUT_FILE="billingData.js"

# Bill Run ID (Modify as needed)
BILL_RUN_ID=12345

# SQL Query to Fetch Data
SQL_QUERY="SELECT TO_CHAR(BILL_DATE, 'DD-MON-YYYY'), COL1, COL2, COL3, COL4, COL5, COL6, COL7 FROM BILLING_TABLE WHERE BILL_RUN_ID = $BILL_RUN_ID ORDER BY BILL_DATE;"

# Fetch Data from Oracle DB
RESULT=$(sqlplus -s $DB_USER/$DB_PASS@$DB_SID <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 1000
$SQL_QUERY
EXIT;
EOF
)

# Initialize column arrays
echo "const billingData = {" > $OUTPUT_FILE
echo "    dates: []," >> $OUTPUT_FILE
echo "    col1: []," >> $OUTPUT_FILE
echo "    col2: []," >> $OUTPUT_FILE
echo "    col3: []," >> $OUTPUT_FILE
echo "    col4: []," >> $OUTPUT_FILE
echo "    col5: []," >> $OUTPUT_FILE
echo "    col6: []," >> $OUTPUT_FILE
echo "    col7: []" >> $OUTPUT_FILE

echo "};" >> $OUTPUT_FILE

# Process Each Line of Output
while IFS= read -r line; do
    DATE=$(echo $line | awk '{print $1}')
    COL1=$(echo $line | awk '{print $2}')
    COL2=$(echo $line | awk '{print $3}')
    COL3=$(echo $line | awk '{print $4}')
    COL4=$(echo $line | awk '{print $5}')
    COL5=$(echo $line | awk '{print $6}')
    COL6=$(echo $line | awk '{print $7}')
    COL7=$(echo $line | awk '{print $8}')
    
    # Append values to respective arrays
    sed -i "/dates: \[/ s/$/ \"$DATE\",/" $OUTPUT_FILE
    sed -i "/col1: \[/ s/$/ $COL1,/" $OUTPUT_FILE
    sed -i "/col2: \[/ s/$/ $COL2,/" $OUTPUT_FILE
    sed -i "/col3: \[/ s/$/ $COL3,/" $OUTPUT_FILE
    sed -i "/col4: \[/ s/$/ $COL4,/" $OUTPUT_FILE
    sed -i "/col5: \[/ s/$/ $COL5,/" $OUTPUT_FILE
    sed -i "/col6: \[/ s/$/ $COL6,/" $OUTPUT_FILE
    sed -i "/col7: \[/ s/$/ $COL7,/" $OUTPUT_FILE

done <<< "$RESULT"

# Final formatting to close the arrays
sed -i 's/,]/]/g' $OUTPUT_FILE

echo "JavaScript file created: $OUTPUT_FILE"

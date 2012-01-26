#!/bin/bash
#
#

TMP=`mktemp -d`
ASSERT="../assert"
EXIT=0

should_pass(){
    local THIS_EXIT=$1
    local THIS_OUT=$2
    if [ $THIS_EXIT -eq 0 ]; then
	    echo "- PASSED"
    else
        echo "- FAILED !!!"
        echo "stdout was:"
        echo "-----------------------------------------------"
        echo "$THIS_OUT"
        echo "-----------------------------------------------"
        EXIT=1
    fi
}

should_fail(){
    local THIS_EXIT=$1
    local THIS_OUT=$2
    if [ $THIS_EXIT -ne 0 ]; then
	    echo "- PASSED"
    else
        echo "- FAILED !!! Expected assertion to fail but it passed"
        echo "stdout was:"
        echo "-----------------------------------------------"
        echo "$THIS_OUT"
        echo "-----------------------------------------------"
        EXIT=1
    fi
}

# Test stdout
echo "Pass on containing text \"test\""
OUT=`echo "test this" | $ASSERT --stdout-contains "test"`
should_pass $? "$OUT"

echo "Fail if text \"dontmatch\" doesn't match"
OUT=`echo "test this" | $ASSERT --stdout-contains "dontmatch"`
should_fail $? "$OUT"

echo "Pass if stdout doesn't match \"dontmatch\""
OUT=`echo "test this" | $ASSERT --stdout-does-not-contain "dontmatch"`
should_pass $? "$OUT"

echo "Fail if stdout does contain \"test\""
OUT=`echo "test this" | $ASSERT --stdout-does-not-contain "test"`
should_fail $? "$OUT"

echo "Pass if the text is exactly \"test this\""
OUT=`echo "test this" | $ASSERT --stdout-is-exactly "test this"`
should_pass $? "$OUT"

echo "Fail if it isn't exactly"
OUT=`echo "test this" | $ASSERT --stdout-is-exactly "test"`
should_fail $? "$OUT"

# Exit codes
echo "Pass on a 0 exit"
OUT=`$ASSERT -c "ls /" --exit-code-is 0`
should_pass $? "$OUT"

echo "Fail on a non-zero"
OUT=`$ASSERT -c "ls /doesnotexist" --exit-code-is 0 2>&1`
should_fail $? "$OUT"

echo "Pass if exit code isn't 0"
OUT=`$ASSERT -c "ls /doesnotexist" --exit-code-is-not 0 2>&1`
should_pass $? "$OUT"

echo "Fail if exit code is 0"
OUT=`$ASSERT -c "ls $TMP" --exit-code-is-not 0`
should_fail $? "$OUT"

# File
echo "Pass if file $TMP/testfile exists"
touch $TMP/testfile
OUT=`$ASSERT --file-#$TMP/testfile#-exists`
should_pass $? "$OUT"

echo "Fail if file $TMP/testfilenotexist does not exist"
OUT=`$ASSERT --file-#$TMP/testfilenotexist#-exists`
should_fail $? "$OUT"

echo "Pass if file $TMP/testfilenotexist does not exist"
OUT=`$ASSERT --file-#$TMP/testfilenotexist#-does-not-exist`
should_pass $? "$OUT"

echo "Fail if file $TMP/testfile does exist"
OUT=`$ASSERT --file-#$TMP/testfile#-does-not-exist`
should_fail $? "$OUT"

echo "Pass if file $TMP/testfile mode is 644"
chmod 644 $TMP/testfile
OUT=`$ASSERT --file-#$TMP/testfile#-has-mode 644`
should_pass $? "$OUT"

echo "Fail if file $TMP/testfile mode is _not_ 644"
chmod 744 $TMP/testfile
OUT=`$ASSERT --file-#$TMP/testfile#-has-mode 644`
should_fail $? "$OUT"

echo "Pass if file $TMP/testfile owner is $USER"
chown $USER $TMP/testfile
OUT=`$ASSERT --file-#$TMP/testfile#-has-owner $USER`
should_pass $? "$OUT"

echo "Fail if file $TMP/testfile owner is nonexistant"
OUT=`$ASSERT --file-#$TMP/testfile#-has-owner nonexistant`
should_fail $? "$OUT"

echo "Pass if group is $USER for $TMP/testfile. Assuming user $USER has group called $USER"
chown :$USER $TMP/testfile
OUT=`$ASSERT --file-#$TMP/testfile#-has-group $USER`
should_pass $? "$OUT"

echo "Fail if group is nonexistant for $TMP/testfile"
OUT=`$ASSERT --file-#$TMP/testfile#-has-group nonexistant`
should_fail $? "$OUT"

echo "Pass if file $TMP/testfile contains \"test string\""
echo "test string" > $TMP/testfile
OUT=`$ASSERT --file-#$TMP/testfile#-contains "test string"`
should_pass $? "$OUT"

echo "Fail if file $TMP/testfile contains \"notthisstring\""
echo "test string" > $TMP/testfile
OUT=`$ASSERT --file-#$TMP/testfile#-contains "notthisstring"`
should_fail $? "$OUT"

# Process
#
# Create a dummy process
cat > $TMP/test-assert-exec << EOF
#!/bin/bash
# Get the PID
echo \$\$ > $TMP/test-assert-exec.pid
# Loop and do nothing
while true; do
    sleep 10 
done
EOF
# Make it executable and run it
chmod 755 $TMP/test-assert-exec
$TMP/test-assert-exec &

# Process tests
echo "Pass if process bash exists"
OUT=`$ASSERT --process-#bash#-exists`
should_pass $? "$OUT"

echo "Fail if process somethingthatwontexist exists"
OUT=`$ASSERT --process-#somethingthatwontexist#-exists`
should_fail $? "$OUT"

echo "Pass if process somethingthatwontexist doesn't exist"
OUT=`$ASSERT --process-#somethingthatwontexist#-does-not-exist`
should_pass $? "$OUT"

echo "Fail if process bash exists"
OUT=`$ASSERT --process-#bash#-does-not-exist`
should_fail $? "$OUT"

echo "Pass if process bash has owner $USER"
OUT=`$ASSERT --process-#bash#-has-owner $USER`
should_pass $? "$OUT"

echo "Fail if process bash has owner userthatdoesnotexist"
OUT=`$ASSERT --process-#bash#-has-owner userthatdoesnotexist`
should_fail $? "$OUT"

echo "Pass if bash command line arguments contain test-assert-exe"
OUT=`$ASSERT --process-#bash#-cmd-line-contains test-assert-exe`
should_pass $? "$OUT"

echo "Fail if bash command line arguments contain probablydoesnotexist"
OUT=`$ASSERT --process-#bash#-cmd-line-contains probablydoesnotexist`
should_pass $? "$OUT"


# Cleanup !
echo "Cleaning up!"
echo "Killing test process with PID `cat $TMP/test-assert-exec.pid`"
kill `cat $TMP/test-assert-exec.pid`
echo "Removing temp directory $TMP"
rm -rf $TMP

# Work out how we should exit
echo 
echo "#############################"
if [  $EXIT -eq 0 ]; then
	echo "TESTS PASSED"
else
	echo "TESTS FAILED"
fi
exit $EXIT

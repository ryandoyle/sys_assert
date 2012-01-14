#!/bin/bash
#
#

TMP=`mktemp -d`
ASSERT="../assert"
EXIT=0

should_pass(){
	echo "PASSED"
}

should_fail(){
}

# Test stdout
echo "- Pass on containing text"
echo "test this" | $ASSERT --stdout-contains "test"
test $? -eq 0 || EXIT=1

echo "- Fail if text doesn't match"
echo "test this" | $ASSERT --stdout-contains "dontmatch"
test $? -ne 0 || EXIT=1

echo "- Pass if stdout doesn't match"
echo "test this" | $ASSERT --stdout-does-not-contain "dontmatch"
test $? -eq 0 || EXIT=1

echo "- Fail if it does contain"
echo "test this" | $ASSERT --stdout-does-not-contain "test"
test $? -eq 1 || EXIT=1

echo "- Pass if the text is exactly"
echo "test this" | $ASSERT --stdout-is-exactly "test this"
test $? -eq 0 || EXIT=1

echo "- Fail if it isn't exactly"
echo "test this" | $ASSERT --stdout-is-exactly "test"
test $? -eq 1 || EXIT=1

# Exit codes
echo "- Pass on a 0 exit"
$ASSERT -c "ls /" --exit-code-is 0
test $? -eq 0 || EXIT=1

echo "- Fail on a non-zero"
$ASSERT -c "ls /doesnotexist" --exit-code-is 0
test $? -eq 1 || EXIT=1

echo "- Pass if exit code isn't 0"
$ASSERT -c "ls /doesnotexist" --exit-code-is-not 0
test $? -eq 1 || EXIT=1 && echo "FAILED"

# Work out how we should exit
if [  $EXIT -eq 0 ]; then
	echo "TESTS PASSED"
else
	echo "TESTS FAILED"
fi
exit $EXIT

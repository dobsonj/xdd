#!/bin/sh
#
# Acceptance test for XDD.
#
# Validate that verbose transfers produce exactly 1 log
#

#
# Test identity
#
test_name=$(basename $0)
echo "Beginning $test_name . . ."

#
# Source the test configuration environment
#
source ./test_config

if [ -n $XDDTEST_XDD_REMOTE_PATH ] ; then
  xddcp_opts="-b $XDDTEST_XDD_REMOTE_PATH"
else
  xddcp_opts=""
fi

if [ -n $XDDTEST_XDD_LOCAL_PATH ] ; then
    xddcp_opts="${xddcp_opts} -l $XDDTEST_XDD_LOCAL_PATH"
fi 



#
# Create a source file
#
test_sdir=$XDDTEST_SOURCE_MOUNT/$test_name
test_ddir=$XDDTEST_DEST_MOUNT/$test_name
rm -rf $test_sdir $test_ddir
mkdir -p $test_sdir $test_ddir
rm -rf xddcp-*-source*-*log xddcp-*-source*-target.0000.csv

#
# Test result
#
test_passes=0

#
# Perform a verbose transfer (ensure logs exist)
#
test_file=$test_sdir/source2
$XDDTEST_XDD_EXE -target $test_file -op write -reqsize 4096 -mbytes 4000 -qd 4 -datapattern random >/dev/null
$XDDTEST_XDDCP_EXE $xddcp_opts -v $test_file $XDDTEST_E2E_DEST:$test_ddir/v1-2
rc=$?
if [ 0 -ne $rc ]; then
    echo "Failure: transfer failed: $XDDTEST_XDDCP_EXE $xddcp_opts -v $test_file $XDDTEST_E2E_DEST:$test_ddir/v1-2"
    test_passes=0
else
    ls xddcp-*-source2-*.log &>/dev/null
    log_missing=$?
    ls xddcp-*-source2-*-target.0000.csv &>/dev/null
    csv_missing=$?
    if [ 0 -eq $log_missing -a 0 -ne $csv_missing ]; then
	test_passes=1
    else
	echo "Failure: did not produce only the verbose log when requested."
    fi
fi

# Output test result
if [ "1" == "$test_passes" ]; then
  echo "Acceptance $test_name - Check: PASSED."
  exit 0
else
  echo "Acceptance $test_name - Check: FAILED."
  exit 1
fi
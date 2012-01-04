#!/bin/sh
#
# Acceptance test for XDD.
#
# Validate the post analysis with kernel tracing flag with xddcp for the -w flag
#

#
# Source the test configuration environment
#
source ./test_config

# Perform pre-test 
echo "Beginning XDDCP Post Analysis w/o Kernel Tracing Test 1 . . ."
test_dir=$XDDTEST_SOURCE_MOUNT/postanalysis-w
rm -rf $test_dir
mkdir -p $test_dir
ssh $XDDTEST_E2E_DEST "rm -rf $XDDTEST_DEST_MOUNT/postanalysis-w"
ssh $XDDTEST_E2E_DEST "mkdir -p $XDDTEST_DEST_MOUNT/postanalysis-w"

source_file=$test_dir/file1
dest_file=$XDDTEST_DEST_MOUNT/postanalysis-w/file1

#
# Create the source file
#
$XDDTEST_XDD_EXE -target $source_file -op write -reqsize 4096 -mbytes 4096 -qd 4 -datapattern random >/dev/null

#
# Start a long copy
#
export PATH=$(dirname $XDDTEST_XDD_EXE):/usr/bin:$PATH
bash -x $XDDTEST_XDDCP_EXE -w 5 $source_file $XDDTEST_E2E_DEST:$dest_file &
pid=$!

wait $pid
rc=$?

test_passes=0
if [ 0 -eq $rc ]; then

    #
    # Check for existence of post analysis files with kernel tracing
    #
    test_passes=1
    xfer_files=$(ls -1 ANALYSIS*/analysis.dat | wc -l)
    if [ "$xfer_files" != "1" ]; then
	test_passes=0
	echo "ERROR: Failure in Post Analysis with Kernel Tracing Test 1"
	echo "\tfile analysis.dat is missing"
    fi
    xfer_files=$(ls -1 ANALYSIS*/*eps | wc -l)
    if [ "$xfer_files" != "9" ]; then
	test_passes=0
	echo "ERROR: Failure in Post Analysis with Kernel Tracing Test 1"
	echo "\tNumber of *eps files is: $xfer_files, should be 9"
    fi
else
    echo "ERROR: XDDCP exited with: $rc"
fi

# Perform post-test cleanup
#rm -rf $test_dir
#create directory to save all source side files
test_dir=$XDDTEST_LOCAL_MOUNT/postanalysis-w
rm   -rf           $test_dir
mkdir -p           $test_dir
mv ANALYSIS*       $test_dir
mv *bin            $test_dir
mv *csv            $test_dir
mv *log            $test_dir
#mv *out            $test_dir
#mv *ascii          $test_dir

# Output test result
if [ "1" == "$test_passes" ]; then
  echo "Acceptance XDDCP-w: XDDCP Post Analysis w/o Kernel Tracing - Check: PASSED."
  exit 0
else
  echo "Acceptance XDDCP-w: XDDCP Post Analysis w/o Kernel Tracing - Check: FAILED."
  exit 1
fi

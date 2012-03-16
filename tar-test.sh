#!/bin/bash
# number of test* functions to try
num_fxns=6
test_log=/tmp/tar-tests/tar-test.log

## Function to auto-detect the number of dirs to strip
set_strip_components() {
	if [ -z "${APP_EXTRACT_DIR}" ]; then
		strip_components="--strip-components=0"
	else
		local dirs_to_strip=$(echo "$APP_EXTRACT_DIR" | tr '/' '\n' | wc -l)
		strip_components="--strip-components=${dirs_to_strip}"
	fi
}

## Various methods to try and bypass the weird bash issue
fxn1() {
	set_strip_components
	tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" "$APP_EXTRACT_DIR" 1>&2 2>> $test_log
	export result=$?
}
fxn2() {
	set_strip_components
	tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" $APP_EXTRACT_DIR 1>&2 2>> $test_log
	export result=$?
}
fxn3() {
	set_strip_components
	[ -n "$APP_EXTRACT_DIR" ] && local app_extract_dir=$(echo -n "\"${APP_EXTRACT_DIR}\"")
	tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" $app_extract_dir 1>&2 2>> $test_log
	export result=$?
}
fxn4() {
	set_strip_components
	local app_extract_dir="$(echo "$APP_EXTRACT_DIR" | sed -e 's| |\\ |g')"
	local need_to_eval=$(echo "$APP_EXTRACT_DIR" | grep -c '\\')
	[ "$need_to_eval" != '0' ] && local EVAL='eval'
	$EVAL tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" $app_extract_dir 1>&2 2>> $test_log
	export result=$?
}

fxn5() {
	set_strip_components
	local app_extract_dir="$(echo "$APP_EXTRACT_DIR" | sed -e 's| |\\ |g')"
	local need_to_eval=$(echo "$APP_EXTRACT_DIR" | grep -c '\\')
	[ "$need_to_eval" != '0' ] && local EVAL='eval'
	$EVAL tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" "$app_extract_dir" 1>&2 2>> $test_log
	export result=$?
}
fxn6() {
	set_strip_components
	tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" ${APP_EXTRACT_DIR:+"$APP_EXTRACT_DIR"} 1>&2 2>> $test_log
	export result=$?
}
## Test various ways to extract
run_tests() {
	n=$1
	i=0
	for i in $(seq 1 $n); do
		result=1
		eval fxn${i}
		echo -n -e "\e[0;36mFXN #$i.....\e[0m" | tee -a $test_log
		if [ "$result" != '0' ]; then
			echo -e "\e[0;31mFAIL!\e[0m" | tee -a $test_log
		else
			echo -e "\e[0;32mSUCCESS!\e[0m" | tee -a $test_log
		fi
	done
}

## CLEANUP tar test files
rm -rf /tmp/tar-tests
mkdir /tmp/tar-tests

#BEGIN Archive Type Tests
echo -e "\e[1;36mTEST1: NULL string\e[0m" | tee -a $test_log
TAR_PARMS='-C /tmp/tar-tests'
FOUND_APP_ARCHIVE=null-test.tar.gz
APP_EXTRACT_DIR=''
run_tests $num_fxns

echo -e "\e[1;36mTEST2: SPACES\e[0m" | tee -a $test_log
FOUND_APP_ARCHIVE=spaces-test.tar.gz
APP_EXTRACT_DIR='spaces test success'
run_tests $num_fxns

echo -e "\e[1;36mTEST3: Wildcards\e[0m" | tee -a $test_log
FOUND_APP_ARCHIVE=wildcard-test.tar.gz
APP_EXTRACT_DIR="wildcard-*"
run_tests $num_fxns

echo -e "\e[1;36mTEST4: Multiple directories\e[0m" | tee -a $test_log
FOUND_APP_ARCHIVE=multiple-directory-test.tar.gz
APP_EXTRACT_DIR="multiple-directory-test-success/multiple-directory-test-success"
run_tests $num_fxns

echo -e "\e[1;36mTEST5: Multiple directories with spaces test\e[0m" | tee -a $test_log
APP_EXTRACT_DIR='multiple directory spaces test success/multiple directory spaces test success'
FOUND_APP_ARCHIVE=multiple-directory-spaces.tar.gz
run_tests $num_fxns 


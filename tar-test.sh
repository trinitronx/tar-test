#!/bin/bash
# number of test* functions to try
num_fxns=3

## Various methods to try and bypass the weird bash issue
fxn1() {
	tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" "$APP_EXTRACT_DIR"
	export result=$?
}
fxn2() {
	tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" $APP_EXTRACT_DIR
	export result=$?
}
fxn3() {
	[ -n "$APP_EXTRACT_DIR" ] && local app_extract_dir=$(echo -n "\"${APP_EXTRACT_DIR}\"")
	tar $TAR_PARMS $strip_components --wildcards --overwrite -xzf "$FOUND_APP_ARCHIVE" $app_extract_dir
	export result=$?
}

## Test various ways to extract
run_tests() {
	n=$1
	i=0
	for i in $(seq 1 $n); do
		result=1
		eval fxn${i}
		echo -n -e "\e[0;36mFXN #$i.....\e[0m" 
		if [ "$result" != '0' ]; then
			echo -e "\e[0;31mFAIL!\e[0m" 
		else
			echo -e "\e[0;32mSUCCESS!\e[0m" 
		fi
	done
}

## CLEANUP tar test files
rm -rf /tmp/tar-tests
mkdir /tmp/tar-tests

#BEGIN Archive Type Tests
echo -e "\e[1;36mTEST1: NULL string\e[0m" 
TAR_PARMS='-C /tmp/tar-tests'
FOUND_APP_ARCHIVE=null-test.tar.gz
strip_components=--strip-components=0
APP_EXTRACT_DIR=''
run_tests $num_fxns

echo -e "\e[1;36mTEST2: SPACES\e[0m" 
FOUND_APP_ARCHIVE=spaces-test.tar.gz
APP_EXTRACT_DIR='spaces test success'
strip_components=--strip-components=1
run_tests $num_fxns

echo -e "\e[1;36mTEST3: Wildcards\e[0m" 
FOUND_APP_ARCHIVE=wildcard-test.tar.gz
APP_EXTRACT_DIR="wildcard-*"
strip_components=--strip-components=1
run_tests $num_fxns

echo -e "\e[1;36mTEST4: Multiple directories\e[0m" 
FOUND_APP_ARCHIVE=multiple-directory-test.tar.gz
APP_EXTRACT_DIR="multiple-directory-test-success/multiple-directory-test-success"
strip_components=--strip-components=2
run_tests $num_fxns

echo -e "\e[1;36mTEST5: Multiple directories with spaces test\e[0m" 
APP_EXTRACT_DIR='multiple directory spaces test success/multiple directory spaces test success'
FOUND_APP_ARCHIVE=multiple-directory-spaces.tar.gz
strip_components=--strip-components=2
run_tests $num_fxns



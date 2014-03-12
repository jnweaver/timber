#!/usr/bin/env bash

if [ $# -lt 3 ]; then
	echo "usage: $0 <db-name> <db-user> <db-pass> [wp-version]"
	exit 1
fi

DB_NAME=$1
DB_USER=$2
DB_PASS=$3
WP_VERSION=${4-master}

set -ex

# set up testing suite
svn co --ignore-externals --quiet http://develop.svn.wordpress.org/tags/$WP_VERSION/ $WP_TESTS_DIR

cd $WP_TESTS_DIR
cp wp-tests-config-sample.php wp-tests-config.php

# replace wp-test-config.php placeholder values with arguments
TMP_FILE=`mktemp /tmp/wp-tests-config.XXX`
sed -e "s/youremptytestdbnamehere/$DB_NAME/" wp-tests-config.php > $TMP_FILE
mv $TMP_FILE wp-tests-config.php

TMP_FILE=`mktemp /tmp/wp-tests-config.XXX`
sed -e "s/yourusernamehere/$DB_USER/" wp-tests-config.php > $TMP_FILE
mv $TMP_FILE wp-tests-config.php

TMP_FILE=`mktemp /tmp/wp-tests-config.XXX`
sed -e "s/yourpasswordhere/$DB_PASS/" wp-tests-config.php > $TMP_FILE
mv $TMP_FILE wp-tests-config.php

# create database
RESULT=`mysql --user=$DB_USER --password=$DB_PASS --skip-column-names -e "SHOW DATABASES LIKE '$DB_NAME'"`
if [ "$RESULT" != $DB_NAME ]; then
    mysqladmin create $DB_NAME --user="$DB_USER" --password="$DB_PASS"
fi

#
# Copyright 2010-2011 Elifarley Cruz <elifarley@gmail.com>
#
# This software may be used and distributed according to the terms of the
# GNU General Public License version 2 or any later version.

mysql_dump() {
  [[ -n $DB_PASSWORD ]] || {
    echo "DB_PASSWORD not defined. Usage:"
    EXP_db_dump_usage
  }

  echo "START mysql_dump"
  echo "Host    : $DB_HOST"
  echo "Database: $DB_NAME"

  local dump_name="${1:-$DB_NAME.$module}"; shift

  add_prefix "--ignore-table=$DB_NAME." 1 _excluded_tables $excluded_tables

  [[ -n $included_tables ]] && echo 'Included tables:' && echo $included_tables
  ((${#_excluded_tables[@]})) && echo "${#_excluded_tables[@]} excluded tables:" && echo $excluded_tables
  [[ -n $db_extra ]] && echo "db_extra: $db_extra"
  echo "other   : $@"

  mysqldump -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASSWORD" "$@" $db_extra "${_excluded_tables[@]}" "$DB_NAME" ${included_tables//,/ } > "$module_cache/$dump_name.sql" || exit $?

  echo "END   mysql_dump"

}

mysql_import() {
  [[ -n $DB_PASSWORD ]] || {
    echo "DB_PASSWORD not defined. Usage:"
    EXP_db_import_usage
  }

  echo "START mysql_import"
  echo "Host    : $DB_HOST"
  echo "Database: $DB_NAME"

  local dump_name="${1:-$DB_NAME.$module}"; shift

  [[ -n $db_extra ]] && echo "db_extra: $db_extra"
  echo "other   : $@"

  local _mysql_params=(-h "$DB_HOST" -u "$DB_USER" --password="$DB_PASSWORD" "$@" $db_extra "$DB_NAME")
  ((_force)) || {
    echo "Option '--force' missing - operation aborted"
    echo "Command that would have been executed:"
    echo mysql "${_mysql_params[@]}" '<' "$module_cache/$dump_name.sql"
	exit 1
  }

  mysql "${_mysql_params[@]}" < "$module_cache/$dump_name.sql" || exit $?

  echo "END   mysql_import"

}

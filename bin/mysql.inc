mysql_dump() {
  echo "START mysql_dump"
  echo "Host    : $DB_HOST"
  echo "Database: $DB_NAME"

  local dump_name="${1:-$DB_NAME.$module}"; shift

  add_prefix "--ignore-table=$DB_NAME." 1 _excluded_tables $excluded_tables

  [ -n "$included_tables" ] && echo 'Included tables:' && echo $included_tables
  ((${#_excluded_tables[@]})) && echo "${#_excluded_tables[@]} excluded tables:" && echo $excluded_tables
  [ -n "$db_extra" ] && echo "db_extra: $db_extra"
  echo "other   : $@"

  mysqldump -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASSWORD" "$@" $db_extra "${_excluded_tables[@]}" "$DB_NAME" ${included_tables//,/ } > "$module_cache/$dump_name.sql" || exit $?

  echo "END   mysql_dump"

}

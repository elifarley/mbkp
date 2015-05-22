# About
**mbkp** is a modular backup tool in 2 senses: it groups common backup configuration in named modules, and its source code departs from the monolithic style by grouping similar functions in separate modules.

# Goals
* Simplify backup management
* Leverage similarities between source version control and backup (mbkp status / mbkp log are similar to hg status / hg log or svn status / svn log, for instance)
* Source code should use best practices in shell / Bash scripting and be easy to extend

# Main Features
* Backup configurations are stored in modules
* Easily create, export and import configuration modules
* Built-in help
* Concurrent backups of a module are detected and skipped
* Simple backup of MySQL databases
* List of DB tables to skip
* List of files to include and exclude is relative to the source (no need to repeat the source prefix for every line)
* Various pre- and post-hooks
* Compatible with older and current versions of [[http://duplicity.nongnu.org/|Duplicity]]

```shell
$ mbkp
MBKP - Modular Backup
Usage:
mbkp <command> [<param1> <param2> ...]

Basic commands:

backup  perform a full or incremental backup
status  show changed files in the working directory
list    show all files in backup
verify  verify the integrity of the repository
restore restore a backup
call    call a hook
log     list the chains and sets in the backup repository
cache-size    show cache sizes
cache-zap     zap cache data
config-new    create configuration for a new module
config-export export all configuration files
config-import import all configuration files
config-edit   edit a configuration file
help    show help on a given command
```

#Examples

* Create a backup configuration module named 'etc':
```
mbkp config-new etc
# or you can use a shorthand:
mbkp cn etc
```

* Opens configuration for the 'etc' module in vim (or $EDITOR if configured):

```
mbkp config-edit etc
# or
mbkp ce etc

```


* Opens the common configuration file (user-specific) for all modules in vim (or $EDITOR if configured):

```
mbkp config-edit
```

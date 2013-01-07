= DESCRIPTION:
Creates and configures mysql databases, users and user access to specified databases.

= REQUIREMENTS:
1. mysql
2. mysql-server

= ATTRIBUTES:
  mysql => { root_password, users{}, databases[]}
	   
= USAGE:
Application specific db configuration

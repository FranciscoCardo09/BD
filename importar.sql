Si usas MySQL o MariaDB
Primero debes tener la base de datos creada. Si no, la creas:

	mysql -u tu_usuario -p
	CREATE DATABASE nombre_basedatos;
	EXIT;
    
Luego importas el archivo:

	mysql -u tu_usuario -p nombre_basedatos < /ruta/al/archivo/basedatos.sql

Ejemplo, si está en Descargas y tu base se llama proyecto:

	mysql -u root -p proyecto < ~/Descargas/basedatos.sql

Te va a pedir la contraseña y listo, se importará todo el esquema y los datos.
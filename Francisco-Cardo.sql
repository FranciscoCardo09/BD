USE Chinook;
-- 1) ¿Qué problemas pueden ocurrir si una tabla está en 1FN pero no en 2FN? Muestre
-- un ejemplo incluyendo las sentencias CREATE TABLE correspondientes.


-- 2) Obtener los pares de empleados que comparten el dia de la semana de cumpleaños
-- (Lunes, Martes, etc) y la última letra del nombre debe ser una vocal, mostrar nombre, apellido y dia de
-- los empleados, solo considerar los años que son impares.
SELECT 
	e.FirstName as Empleado_1_nombre,
    e.LastName as Empleado_1_apellido,
    e2.FirstName as Empleado_2_nombre,
    e2.LastName as Empleado_2_apellido,
    e.BirthDate as Fecha_cumpleaños
FROM 
	Employee e
-- No se me ocurre como sacar el dia
JOIN Employee e2 ON e.BirthDate = e2.BirthDate and e.Employeeid < e2.EmployeeId
WHERE 
-- No se me ocurre como sacar el año impar
	e.FirstName Like "%A" 
    or e.FirstName like "%E"
    or e.FirstName like "%I"
    or e.FirstName like "%O"
    or e.FirstName like "%U"
    or e.FirstName like "%a"
    or e.FirstName like "%e"
    or e.FirstName like "%i"
    or e.FirstName like "%o"
    or e.FirstName like "%u";
    
-- 3) Generar un informe por género por mes, que muestre por cada mes el monto total
-- cobrado, el monto de factura máximo y mínimo, el monto diferencial ( máximo - mínimo) y el monto
-- total recaudado sin considerar la factura máxima y mínima(si el monto max y min se repiten solo se
-- resta 1 vez). Se debe validar el cálculo del total por ende no se puede usar el total de la tabla invoice.
SELECT 
	g.Name,
    il.InvoiceLineId
FROM
	Genre g
JOIN Track t ON t.GenreId = g.GenreID;


-- 4) Listar los milisegundos de las pistas que no son máximas, ni mínimas, ni promedio,
-- cuyos artistas pueden ser Iron Maiden, U2, Led Zeppelin o Battlestar Galactica pero su 
-- genero no puede ser de Rock o Metal. Ordenar por milisegundos de manera descendente.
SELECT
	t.Milliseconds
FROM 
	Track t
JOIN Album a on t.AlbumId = a.AlbumId
JOIN Artist ar on a.ArtistId = ar.ArtistId
WHERE t.GenreId IN(
		SELECT 
			g.GenreId
        FROM
			Genre g
		WHERE
			g.Name NOT LIKE "Rock" or g.Name NOT LIKE "Metal"
) 
AND
	ar.Name like "Iron Maiden" or 
    ar.Name like "U2" or 
    ar.Name like "Led Zeppelin" or 
    ar.Name like "Battlestar Galactica"
ORDER BY t.Milliseconds DESC;

    
-- 5) Obtener los tipo de media cuya sumatoria de ganancias por orden( precio Unitario *
-- cantidad - descuento) es mayor al promedio de ganancias de todos los tipo de media. Mostrar
-- el nombre del tipo de media, el monto total, el promedio general y una lista separada por
-- comas de las pistas y su ganancia por pista.

SELECT 
	mt.Name,
    (SELECT SUM(il.UnitPrice)
        FROM Track t
        JOIN InvoiceLine il ON il.TrackId = t.TrackId 
        WHERE t.MediaTypeId = mt.MediaTypeId
	) as sumatoria_ganancia,
    (SELECT SUM(il.UnitPrice)/ SUM(il.Quantity)
        FROM Track t
        JOIN InvoiceLine il ON il.TrackId = t.TrackId 
        WHERE t.MediaTypeId = mt.MediaTypeId
	) promedio,
    group_concat(t.Name, ' ', t.UnitPrice  SEPARATOR ', ') as lista
FROM
	MediaType mt
JOIN Track t on t.MediaTypeId = mt.MediaTypeId
GROUP BY mt.MediaTypeId;
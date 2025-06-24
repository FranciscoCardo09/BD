use Chinook;

-- 2)
SELECT 
  e1.FirstName AS Nombre1,
  e1.LastName AS Apellido1,
  DAYNAME(e1.BirthDate) AS DiaSemana,
  YEAR(e1.BirthDate) AS Año
FROM Employee e1
JOIN Employee e2 ON DAYNAME(e1.BirthDate) = DAYNAME(e2.BirthDate) AND e1.EmployeeId != e2.EmployeeId
WHERE e1.FirstName REGEXP '[aeiou]$' AND YEAR(e1.BirthDate) % 2 = 1;

-- 3)
SELECT
  g.Name AS Genero,
  MONTH(i.InvoiceDate) AS Mes,
  SUM(il.UnitPrice * il.Quantity) AS TotalCobrado,
  MAX(il.UnitPrice * il.Quantity) AS MontoMax,
  MIN(il.UnitPrice * il.Quantity) AS MontoMin,
  AVG(il.UnitPrice * il.Quantity) AS MontoProm
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name, MONTH(i.InvoiceDate);

-- 4)
SELECT
  ar.Name AS Artista,
  t.Name AS Pista,
  g.Name as genero,
  t.Milliseconds
FROM 
  Track t
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Genre g ON t.GenreId = g.GenreId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE t.GenreId IN (
    SELECT GenreId 
    FROM Genre 
    WHERE Name NOT LIKE 'Rock' AND Name NOT LIKE 'Metal'
)
AND t.Milliseconds NOT IN (
    (SELECT MAX(Milliseconds) FROM Track),
    (SELECT MIN(Milliseconds) FROM Track),
    (SELECT AVG(Milliseconds) FROM Track)
)
AND ar.Name IN ('Iron Maiden', 'U2', 'Led Zeppelin', 'Battlestar Galactica')
ORDER BY t.Milliseconds DESC;

-- 5)
SELECT 
	mt.Name,
    (SELECT SUM(il.UnitPrice * il.Quantity)
        FROM Track t2
        JOIN InvoiceLine il ON il.TrackId = t2.TrackId 
        WHERE t2.MediaTypeId = mt.MediaTypeId
	) as sumatoria_ganancia,
    
    (SELECT AVG(sub.total)
     FROM (
        SELECT SUM(il.UnitPrice * il.Quantity) AS total
        FROM Track t3
        JOIN InvoiceLine il ON il.TrackId = t3.TrackId
        JOIN MediaType m ON m.MediaTypeId = t3.MediaTypeId
        GROUP BY m.MediaTypeId
     ) sub
    ) AS promedio,
    
    (
    SELECT GROUP_CONCAT(CONCAT(pista.Nombre, ' ($', ROUND(pista.Ganancia, 2), ')') SEPARATOR ', ')
    FROM (
      SELECT 
        t2.Name AS Nombre,
        SUM(il2.UnitPrice * il2.Quantity) AS Ganancia
      FROM Track t2
      JOIN InvoiceLine il2 ON il2.TrackId = t2.TrackId
      WHERE t2.MediaTypeId = mt.MediaTypeId
      GROUP BY t2.TrackId
    ) AS pista
  ) AS lista_pistas
     
FROM MediaType mt
JOIN Track t on t.MediaTypeId = mt.MediaTypeId
GROUP BY mt.MediaTypeId
HAVING sumatoria_ganancia > promedio;
USE sakila;

-- 1. Obtener los pares de apellidos de actores que comparten nombres, considerando
-- solo los actores cuyo nombre comienza con una vocal. Mostrar el nombre, los 2
-- apellidos y las películas que comparten.

SELECT a1.first_name,
       a1.last_name AS apellido_1,
       a2.last_name AS apellido_2,
       GROUP_CONCAT(DISTINCT f.title SEPARATOR ', ') AS peliculas_compartidas
FROM actor a1
JOIN actor a2 ON a1.first_name = a2.first_name 
             AND a1.actor_id < a2.actor_id
JOIN film_actor fa1 ON fa1.actor_id = a1.actor_id
JOIN film_actor fa2 ON fa2.actor_id = a2.actor_id
JOIN film f ON f.film_id = fa1.film_id AND f.film_id = fa2.film_id
WHERE a1.first_name REGEXP '^[AEIOU]'
GROUP BY a1.first_name, a1.last_name, a2.last_name;
                
-- 2. Mostrar aquellas películas cuya cantidad de actores sea mayor al promedio de
-- actores por películas. Además, mostrar su cantidad de actores y una lista de los
-- nombres de esos actores.

SELECT
	f.title,
    COUNT(DISTINCT fa.actor_id) AS cantidad_actores,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ')
FROM
	film f
JOIN film_actor fa on fa.film_id = f.film_id
JOIN actor a ON a.actor_id = fa.actor_id
GROUP BY f.film_id
HAVING COUNT(DISTINCT fa.actor_id) > (
    SELECT AVG(cant) 
    FROM (
        SELECT COUNT(DISTINCT actor_id) AS cant
        FROM film_actor
        GROUP BY film_id
    ) AS sub
);

-- 3. Generar un informe por empleado mostrando el local, la cantidad y sumatoria de sus
-- ventas, su venta máxima, mínima, cuantas veces se repite la venta máxima y la
-- mínima, además mostrar en una columna una concatenación de todos los alquileres
-- mostrando el título de la película alquilada y el monto pagado. Considerar sólo los
-- datos del año actual.

SELECT 
	s.staff_id,
    s.first_name,
    s.last_name,
    
    -- Subquery para saber a qué tienda pertenece
    (SELECT store_id
     FROM store st
     WHERE st.manager_staff_id = s.staff_id) AS Tienda,

    -- Subquery para suma total de ventas
    (SELECT SUM(amount)
     FROM payment p
     WHERE p.staff_id = s.staff_id
     AND YEAR(p.payment_date) = YEAR(CURDATE())) AS Total_ventas,
     
     -- Subquery para su venta máxima
     (SELECT MAX(amount)
     FROM payment p
     WHERE p.staff_id = s.staff_id
     AND YEAR(p.payment_date) = YEAR(CURDATE())) AS Venta_máxima,
     
     -- Subquery para su venta mínima
     (SELECT MIN(amount)
     FROM payment p
     WHERE p.staff_id = s.staff_id
     AND YEAR(p.payment_date) = YEAR(CURDATE())) AS Venta_mínima,
     
     -- Subquery para su veces venta máxima
     (SELECT COUNT(*)
     FROM payment p
     WHERE p.staff_id = s.staff_id
       AND YEAR(p.payment_date) = YEAR(CURDATE())
       AND p.amount = (
           SELECT MAX(amount)
           FROM payment
           WHERE staff_id = s.staff_id
             AND YEAR(payment_date) = YEAR(CURDATE())
       )) AS veces_max,
       
    -- Cuántas veces hizo su venta mínima
    (SELECT COUNT(*)
     FROM payment p
     WHERE p.staff_id = s.staff_id
       AND YEAR(p.payment_date) = YEAR(CURDATE())
       AND p.amount = (
           SELECT MIN(amount)
           FROM payment
           WHERE staff_id = s.staff_id
             AND YEAR(payment_date) = YEAR(CURDATE())
       )) AS veces_min,
	
    -- Mostrar en una columna una concatenación de todos los alquileres mostrando el título de la película alquilada y el monto pagado.
	(SELECT GROUP_CONCAT(DISTINCT CONCAT(f.title, ' ($', p.amount, ')') SEPARATOR ', ')
     FROM payment p
     JOIN rental r ON r.rental_id = p.rental_id
     JOIN inventory i ON i.inventory_id = r.inventory_id
     JOIN film f ON f.film_id = i.film_id
     WHERE p.staff_id = s.staff_id
       AND YEAR(p.payment_date) = YEAR(CURDATE())
    ) AS alquileres
FROM
	staff s;
    
-- Objetivo: obtener el total de ventas por empleado, y luego filtrar los que vendieron más de $1000.
SELECT t.staff_id, t.total_ventas
FROM (
    SELECT staff_id, SUM(amount) AS total_ventas
    FROM payment
    GROUP BY staff_id
) AS t
WHERE t.total_ventas > 1000;

-- Mostrar los clientes que alquilaron más películas que el promedio general de alquileres por cliente
-- Mostrar su nombre, apellido, la cantidad de alquileres y los títulos que alquiló concatenados.

SELECT
	c.first_name,
    c.last_name,
    COUNT(DISTINCT r.rental_id) AS cantidad_alquileres,
    (SELECT GROUP_CONCAT(DISTINCT f.title SEPARATOR ', ')
     FROM rental r2
     JOIN inventory i ON i.inventory_id = r2.inventory_id
     JOIN film f ON f.film_id = i.film_id
     WHERE r2.customer_id = c.customer_id) AS titulos_alquilados
FROM
	customer c
JOIN rental r on r.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT r.rental_id) > (
    SELECT AVG(alq) 
    FROM (
        SELECT COUNT(DISTINCT rental_id) AS alq
        FROM rental
        GROUP BY customer_id
    ) AS sub
)
ORDER BY COUNT(DISTINCT r.rental_id) DESC;

-- Para cada categoría, mostrar el nombre de la categoría, el título de su película más larga y su duración.

SELECT 
    c.name AS categoria,
    (SELECT title
     FROM film f2
     JOIN film_category fc2 ON fc2.film_id = f2.film_id
     WHERE fc2.category_id = c.category_id
     ORDER BY f2.length DESC
     LIMIT 1) AS pelicula_mas_larga,
    (SELECT MAX(f.length)
     FROM film f
     JOIN film_category fc ON fc.film_id = f.film_id
     WHERE fc.category_id = c.category_id) AS duracion
FROM category c;




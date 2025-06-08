-- GROUP_CONCAT()
-- Forma: GROUP_CONCAT(columna SEPARATOR 'texto')
-- Qué devuelve: Una cadena con todos los valores de la columna unidos
-- Cuándo se usa: Para agrupar varios valores en una sola línea de texto

-- 🧠 FUNCIONES DE AGREGACIÓN --------------------------------------

-- COUNT()
-- Forma: COUNT() o COUNT(columna) o COUNT(DISTINCT columna)
-- Qué devuelve: Número de filas (o valores distintos si se usa DISTINCT)
-- Cuándo se usa: Cuando queremos contar registros o valores únicos
	SELECT COUNT() FROM film;
	SELECT COUNT(DISTINCT rating) FROM film;

-- SUM()
-- Forma: SUM(columna)
-- Qué devuelve: Suma de los valores numéricos
-- Cuándo se usa: Para obtener totales
	SELECT SUM(amount) FROM payment;

-- AVG()
-- Forma: AVG(columna)
-- Qué devuelve: Promedio de los valores numéricos
-- Cuándo se usa: Para obtener promedios
	SELECT AVG(length) FROM film;

-- MIN() / MAX()
-- Forma: MIN(columna), MAX(columna)
-- Qué devuelve: Valor mínimo o máximo de una columna
-- Cuándo se usa: Para encontrar extremos
	SELECT MIN(amount), MAX(amount) FROM payment;

-- GROUP_CONCAT()
-- Forma: GROUP_CONCAT(columna SEPARATOR 'texto')
-- Qué devuelve: Una cadena con todos los valores de la columna unidos
-- Cuándo se usa: Para agrupar varios valores en una sola línea de texto
	SELECT GROUP_CONCAT(title SEPARATOR ', ') FROM film;

-- Ejemplo con nombres completos de actores:
	SELECT film_id,
	GROUP_CONCAT(CONCAT(first_name, ' ', last_name))
	FROM actor a
	JOIN film_actor fa ON a.actor_id = fa.actor_id
	GROUP BY film_id;

-- 🧩 SUBQUERIES ----------------------------------------------

-- En SELECT (subquery escalar)
	SELECT first_name,
	(SELECT MAX(amount) FROM payment WHERE customer_id = c.customer_id) AS max_payment
	FROM customer c;

-- En WHERE
	SELECT * FROM film
	WHERE film_id IN (SELECT film_id FROM inventory WHERE store_id = 1);

-- En FROM
	SELECT avg_len
	FROM (SELECT AVG(length) AS avg_len FROM film) t;

-- Con EXISTS
	SELECT first_name
	FROM actor a1
	WHERE EXISTS (
	SELECT * FROM actor a2
	WHERE a2.first_name = a1.first_name AND a1.actor_id <> a2.actor_id
	);

-- 🧠 JOINs ----------------------------------------------

-- INNER JOIN simple
	SELECT * FROM film
	INNER JOIN language ON film.language_id = language.language_id;

-- JOIN con tres tablas
	SELECT f.title, c.name
	FROM film f
	JOIN film_category fc ON f.film_id = fc.film_id
	JOIN category c ON fc.category_id = c.category_id;

-- 🧠 GROUP BY + HAVING ----------------------------------------------

-- Contar cantidad de películas por rating
	SELECT rating, COUNT()
	FROM film
	GROUP BY rating
	HAVING COUNT() > 150;

-- Agrupando por múltiples columnas
	SELECT rating, AVG(length)
	FROM film
	GROUP BY rating
	HAVING AVG(length) > (SELECT AVG(length) FROM film);

-- 🧠 CASOS DE EXAMEN ----------------------------------------------

-- 1. Actores con mismos nombres que empiezan con vocal y películas en común
SELECT a1.first_name, a1.last_name, a2.last_name,
GROUP_CONCAT(DISTINCT f.title) AS peliculas
FROM actor a1
JOIN actor a2 ON a1.first_name = a2.first_name AND a1.actor_id < a2.actor_id
JOIN film_actor fa1 ON fa1.actor_id = a1.actor_id
JOIN film_actor fa2 ON fa2.actor_id = a2.actor_id
JOIN film f ON fa1.film_id = fa2.film_id AND fa1.film_id = f.film_id
WHERE a1.first_name REGEXP '^[AEIOU]'
GROUP BY a1.first_name, a1.last_name, a2.last_name;

-- 2. Películas con más actores que el promedio
SELECT f.title,
COUNT(DISTINCT fa.actor_id) AS cantidad_actores,
GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name)) AS actores
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON a.actor_id = fa.actor_id
GROUP BY f.film_id
HAVING COUNT(DISTINCT fa.actor_id) > (
SELECT AVG(cantidad)
FROM (
SELECT COUNT(*) AS cantidad
FROM film_actor
GROUP BY film_id
) AS sub
);

-- 3. Informe por empleado (ventas y alquileres del año actual)
SELECT
s.staff_id,
s.first_name,
s.last_name,
(SELECT store_id FROM store WHERE manager_staff_id = s.staff_id) AS tienda,
(SELECT COUNT() FROM payment p WHERE p.staff_id = s.staff_id AND YEAR(p.payment_date) = YEAR(CURDATE())) AS cantidad_ventas,
(SELECT SUM(amount) FROM payment p WHERE p.staff_id = s.staff_id AND YEAR(p.payment_date) = YEAR(CURDATE())) AS total_ventas,
(SELECT MAX(amount) FROM payment p WHERE p.staff_id = s.staff_id AND YEAR(p.payment_date) = YEAR(CURDATE())) AS venta_max,
(SELECT MIN(amount) FROM payment p WHERE p.staff_id = s.staff_id AND YEAR(p.payment_date) = YEAR(CURDATE())) AS venta_min,
(SELECT COUNT() FROM payment p WHERE p.staff_id = s.staff_id AND p.amount = (
SELECT MAX(amount) FROM payment WHERE staff_id = s.staff_id AND YEAR(payment_date) = YEAR(CURDATE()))) AS repite_max,
(SELECT COUNT(*) FROM payment p WHERE p.staff_id = s.staff_id AND p.amount = (
SELECT MIN(amount) FROM payment WHERE staff_id = s.staff_id AND YEAR(payment_date) = YEAR(CURDATE()))) AS repite_min,
(SELECT GROUP_CONCAT(DISTINCT CONCAT(f.title, ' ($', p.amount, ')') SEPARATOR ', ')
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
WHERE p.staff_id = s.staff_id AND YEAR(p.payment_date) = YEAR(CURDATE())) AS alquileres
FROM staff s;

-- 🧠 EXTRAS Y TIPS ----------------------------------------------

-- Filtrar por nombres que empiecen con vocal
WHERE first_name REGEXP '^[AEIOU]';

-- Subquery correlacionada
SELECT title FROM film f
WHERE length > (
SELECT AVG(length) FROM film WHERE rating = f.rating
);

-- Para convertir valores en 1 o 0 (TRUE/FALSE)
SELECT SUM(amount = 0.99) FROM payment;

-- Manejo de NULL en comparaciones
-- amount = NULL → nunca es TRUE, usar IS NULL o COALESCE
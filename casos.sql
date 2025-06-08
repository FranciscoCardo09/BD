-- 📄 CASOS COMUNES DE CONSULTAS SQL EN MYSQL (ESTILO SAKILA)
-- Cada bloque incluye un título, qué busca, y una forma típica de resolverlo.

-- 1. Encontrar el valor máximo de una columna (ej: pago más alto)
SELECT MAX(amount) AS pago_maximo
FROM payment;

-- 2. Encontrar el valor mínimo de una columna (ej: pago más bajo)
SELECT MIN(amount) AS pago_minimo
FROM payment;

-- 3. Encontrar la suma total de una columna
SELECT SUM(amount) AS total_pagado
FROM payment;

-- 4. Promedio de una columna (ignora NULLs automáticamente)
SELECT AVG(amount) AS promedio_pago
FROM payment;

-- 5. Cantidad total de registros
SELECT COUNT(*) AS total_registros
FROM customer;

-- 6. Cantidad de registros NO nulos en una columna
SELECT COUNT(amount) AS pagos_registrados
FROM payment;

-- 7. Contar valores distintos
SELECT COUNT(DISTINCT customer_id) AS clientes_unicos
FROM payment;

-- 8. Obtener pares que comparten algún atributo (por ejemplo, nombre)
SELECT a1.first_name, a1.last_name, a2.last_name
FROM actor a1
JOIN actor a2 ON a1.first_name = a2.first_name
             AND a1.actor_id < a2.actor_id;

-- 9. Encontrar elementos que tienen valores en común (películas compartidas)
SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name,
       GROUP_CONCAT(DISTINCT f.title) AS peliculas_en_comun
FROM actor a1
JOIN actor a2 ON a1.first_name = a2.first_name AND a1.actor_id < a2.actor_id
JOIN film_actor fa1 ON fa1.actor_id = a1.actor_id
JOIN film_actor fa2 ON fa2.actor_id = a2.actor_id
JOIN film f ON fa1.film_id = fa2.film_id AND fa1.film_id = f.film_id
GROUP BY a1.first_name, a1.last_name, a2.last_name;

-- 10. Mostrar listas concatenadas con GROUP_CONCAT
SELECT customer_id,
       GROUP_CONCAT(payment_id ORDER BY payment_id SEPARATOR ', ') AS pagos
FROM payment
GROUP BY customer_id;

-- 11. Clientes que alquilaron más películas que el promedio
SELECT customer_id, COUNT(*) AS total_alquileres
FROM rental
GROUP BY customer_id
HAVING COUNT(*) > (
    SELECT AVG(cantidad)
    FROM (
        SELECT COUNT(*) AS cantidad
        FROM rental
        GROUP BY customer_id
    ) AS sub
);

-- 12. Subquery en SELECT (ej: pago máximo por cliente)
SELECT customer_id,
       (SELECT MAX(amount) FROM payment p WHERE p.customer_id = c.customer_id) AS pago_max
FROM customer c;

-- 13. Subquery en WHERE (películas disponibles en tienda 1)
SELECT title
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM inventory
    WHERE store_id = 1
);

-- 14. Subquery con EXISTS (clientes que pagaron más de $5 alguna vez)
SELECT first_name, last_name
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM payment p
    WHERE p.customer_id = c.customer_id AND p.amount > 5
);

-- 15. Subquery en FROM (promedio de duración de películas)
SELECT promedio
FROM (
    SELECT AVG(length) AS promedio
    FROM film
) AS sub;

-- 16. Agrupar y filtrar con HAVING (ratings con menos de 200 películas)
SELECT rating, COUNT(*) AS cantidad
FROM film
GROUP BY rating
HAVING COUNT(*) < 200;

-- 17. Clientes con el monto total que gastaron y lista de películas alquiladas
SELECT c.first_name, c.last_name,
       SUM(p.amount) AS total_gastado,
       GROUP_CONCAT(DISTINCT f.title SEPARATOR ', ') AS peliculas
FROM customer c
JOIN payment p ON p.customer_id = c.customer_id
JOIN rental r ON r.rental_id = p.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY c.customer_id;

-- 18. Obtener película más larga por categoría
SELECT c.name AS categoria,
       (SELECT title
        FROM film f2
        JOIN film_category fc2 ON fc2.film_id = f2.film_id
        WHERE fc2.category_id = c.category_id
        ORDER BY f2.length DESC
        LIMIT 1) AS pelicula_mas_larga
FROM category c;

-- 19. Actores que no trabajaron en ninguna película
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id NOT IN (
    SELECT DISTINCT actor_id
    FROM film_actor
);

-- 20. Películas que no fueron alquiladas nunca
SELECT title
FROM film
WHERE film_id NOT IN (
    SELECT DISTINCT i.film_id
    FROM inventory i
    JOIN rental r ON r.inventory_id = i.inventory_id
);

-- 21. Categorías con más de X películas
SELECT c.name, COUNT(*) AS cantidad
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
GROUP BY c.category_id
HAVING COUNT(*) > 50;

-- 22. Actores que trabajaron en más de una película
SELECT a.actor_id, a.first_name, a.last_name, COUNT(*) AS cantidad_peliculas
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
HAVING COUNT(*) > 1;

-- 23. Películas con duración mayor al promedio general
SELECT title, length
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
);

-- 24. Clientes que alquilaron todas las películas de cierta categoría (por ejemplo: 'Action')
SELECT c.first_name, c.last_name
FROM customer c
WHERE NOT EXISTS (
    SELECT fc.film_id
    FROM film_category fc
    JOIN category cat ON cat.category_id = fc.category_id
    WHERE cat.name = 'Action'
    AND fc.film_id NOT IN (
        SELECT i.film_id
        FROM rental r
        JOIN inventory i ON i.inventory_id = r.inventory_id
        WHERE r.customer_id = c.customer_id
    )
);

SELECT
    categoria,
    GROUP_CONCAT(CONCAT(nombre_cliente, ' (', total_alquileres, ')') 
                 ORDER BY total_alquileres DESC SEPARATOR ', ') AS clientes_y_cantidades
FROM (
    SELECT
        c.name AS categoria,
        CONCAT(cl.first_name, ' ', cl.last_name) AS nombre_cliente,
        COUNT(*) AS total_alquileres
    FROM
        category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN customer cl ON r.customer_id = cl.customer_id
    GROUP BY
        c.name, cl.customer_id
) AS sub
GROUP BY
    categoria;

-- 25. Mostrar el rating que tiene la mayor cantidad de películas
SELECT rating
FROM film
GROUP BY rating
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 26. Mostrar las 3 películas más largas
SELECT title, length
FROM film
ORDER BY length DESC
LIMIT 3;

-- 27. Clientes que alquilaron al menos una película de cada tienda
SELECT c.first_name, c.last_name
FROM customer c
WHERE NOT EXISTS (
    SELECT store_id
    FROM store
    WHERE store_id NOT IN (
        SELECT DISTINCT i.store_id
        FROM rental r
        JOIN inventory i ON i.inventory_id = r.inventory_id
        WHERE r.customer_id = c.customer_id
    )
);

-- 28. Actores que trabajaron con más de 10 películas distintas
SELECT a.first_name, a.last_name, COUNT(DISTINCT fa.film_id) AS cantidad
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
HAVING cantidad > 10;
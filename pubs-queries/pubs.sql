-- Active: 1714881146400@@127.0.0.1@3306@pubs

USE pubs;

# 1. Mostrar el nombre, apellido de todos los empleados.
SELECT fname AS 'NOMBRE', lname AS 'APELLIDO' FROM employee;

# 2. Mostrar todos los nombre completo y precio de los titulo.
SELECT title AS 'TITULO', price AS 'PRECIO' FROM titles;

# 3. Mostrar todos los nombres completos de los autores registrados.
SELECT CONCAT(au_fname, ' ', au_lname) AS 'NOMBRE COMPLETO'
FROM authors;

# 4. Mostrar el nombre completo de todos los empleados ordenados por apellido y por nombre.
SELECT CONCAT(fname, ' ', lname) AS 'NOMBRE COMPLETO'
FROM employee
ORDER BY lname, fname;

# 5. Mostrar todos los empleados que inician con la letra “P” en el nombre.
SELECT CONCAT(fname, ' ', lname) AS 'NOMBRE COMPLETO'
FROM employee
WHERE
    fname LIKE 'P%';

# 6. Mostrar todos los títulos y precios, el precio no debe de superar los 15 dlls.
SELECT title AS 'TITULO', price AS 'PRECIO'
FROM titles
WHERE
    price <= 15;

# 7. Mostrar todos los nombres de los títulos que sea del tipo business.
SELECT title AS 'TITULO' FROM titles WHERE type = 'business';

# 8. Mostrar todos los nombres de los títulos que sea del tipo modcook.
SELECT title AS 'TITULO' FROM titles WHERE type = 'mod_cook';

# 9. Mostrar todos los autores
SELECT CONCAT(au_fname, ' ', au_lname) AS 'AUTORES' FROM authors;

# 10. Mostrar cuantos empleados existen
SELECT COUNT(*) AS 'CANTIDAD DE EMPLEADOS' FROM employee;

# 11. Mostrar cuantos títulos que existen.
SELECT COUNT(*) AS 'CANTIDAD DE TITULOS' FROM titles;

# 12. Mostrar cuantos autores existen.
SELECT COUNT(*) AS 'CANTIDAD DE AUTORES' FROM authors;

# 13. Mostrar cuantos libros existen por autor.
SELECT CONCAT(au_fname, ' ', au_lname) AS 'AUTOR', COUNT(*) AS 'CANTIDAD DE LIBROS'
FROM authors
    JOIN titleauthor ON authors.au_id = titleauthor.au_id
GROUP BY
    authors.au_id;

# 14. Mostrar el total de las ganancias que se ha recibo por la venta de ejemplares.
SELECT ti.title AS 'TITULO', SUM(ti.price * sa.qty)
FROM sales AS sa
    JOIN titles AS ti ON sa.title_id = ti.title_id
GROUP BY
    ti.title_id;

# 15. Mostrar cuantos autores existen por estado.
SELECT state AS 'ESTADO', COUNT(*) AS 'CANTIDAD DE AUTORES'
FROM authors
GROUP BY
    state;

# 16. Mostrar el máximo precio de un título.
SELECT MAX(price) AS 'PRECIO MAXIMO' FROM titles;

# 17. Mostrar el mínimo precio de un título.
SELECT MIN(price) AS 'PRECIO MINIMO' FROM titles;

# 18. Mostrar el promedio del costo de un título.
SELECT AVG(price) AS 'PROMEDIO DE PRECIO' FROM titles;

# 19. Mostrar el máximo, mínimo y el promedio del costo de los títulos.
SELECT MAX(price) AS 'PRECIO MAXIMO', MIN(price) AS 'PRECIO MINIMO', AVG(price) AS 'PROMEDIO DE PRECIO'
FROM titles;

# 20. Mostrar todos los autores que trabajan en cada editorial ordenados por editorial y nombre de autores.
SELECT CONCAT(au.au_fname, ' ', au.au_lname) AS 'AUTOR', pub.pub_name AS 'EDITORIAL'
FROM
    authors AS au
    JOIN titleauthor AS ta ON au.au_id = ta.au_id
    JOIN titles AS ti ON ta.title_id = ti.title_id
    JOIN publishers AS pub ON ti.pub_id = pub.pub_id
ORDER BY pub.pub_name, au.au_lname, au.au_fname;
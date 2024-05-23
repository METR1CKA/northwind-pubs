# Mostrar las ganancias por autor.

--- 1. Mostrar el total de ventas por libro.
DROP VIEW IF EXISTS libro_total;

CREATE VIEW libro_total AS
SELECT ti.title_id, SUM(sa.qty * ti.price) AS total_libro
FROM sales AS sa
    JOIN titles AS ti ON sa.title_id = ti.title_id
GROUP BY
    ti.title_id;

SELECT * FROM libro_total;
---

--- 2. Mostrar el total de regalías por libro.
DROP VIEW IF EXISTS regalias_libro;

CREATE VIEW regalias_libro AS
SELECT title_id, SUM(royaltyper) AS reg
FROM titleauthor
GROUP BY
    title_id;

SELECT * FROM regalias_libro;
---

SELECT IFNULL(
        CONCAT(au.au_fname, ' ', au.au_lname), 'Anónimo'
    ) AS 'AUTOR', SUM(
        libro.total_libro * (
            IFNULL(ta.royaltyper, 0) / 100
        )
    ) AS 'GANANCIAS', SUM(
        libro.total_libro * (1 - IFNULL(tr.reg, 0) / 100)
    ) AS 'GANANCIAS EDITORIAL'
FROM
    titleauthor AS ta
    RIGHT JOIN libro_total AS libro ON libro.title_id = ta.title_id
    LEFT JOIN regalias_libro AS tr ON tr.title_id = ta.title_id
    LEFT JOIN authors AS au ON ta.au_id = au.au_id
GROUP BY
    au.au_id;
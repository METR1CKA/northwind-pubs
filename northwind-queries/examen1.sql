-- Examen 1. Mostrar los productos que mas se vendieron en los ultimos 3 años por categoria y saber cual fue el cliente que mas compro y el que menos compro ese producto.
-- Las consultas deben de ser realizadas para identificar rapidamente la informacion que se interesa conocer.
-- Ejemplo, en esta consulta solo se pondra la información como se indica, es decir, si se identifica la coca como el producto que mas se vendio en un año determinado, solo se tendra que mostrar los clientes que compraron en ese año en que la coca fue la menor ganancia.
-- Consulta para identificar los productos
-- Consulta para identificar los años de esos productos
-- Consulta para identificar los clientes de esos productos en esos años (El que mas compro y otra del que menos comrpo)
-- Consulta final: COLUMNAS: categoria, Ultimo (Año), Penúltimo (Año), Antepenúltimo (Año)
-- Demostraciones en cada consulta

USE northwind;

-- Tablas a usar
SELECT * FROM `Categories`;

SELECT * FROM `Customers`;

SELECT * FROM `Products`;

SELECT * FROM `Orders`;

SELECT * FROM `Order Details`;

------------------------------------------------------------

------------------------------------------------------------
# Los ultimos 3 años
DROP VIEW IF EXISTS last_years;

CREATE VIEW last_years AS
SELECT DISTINCT
    YEAR(ord.`OrderDate`) AS OrderYear
FROM `Orders` AS ord
ORDER BY OrderYear DESC;

SELECT * FROM last_years;

------------------------------------------------------------

------------------------------------------------------------
# Sacar primer año
DROP VIEW IF EXISTS first_year;

CREATE VIEW first_year AS
SELECT MAX(OrderYear) AS order_year
FROM last_years;

SELECT * FROM first_year;

------------------------------------------------------------

------------------------------------------------------------
# Sacar 3er año
DROP VIEW IF EXISTS last_year;

CREATE VIEW last_year AS
SELECT MIN(OrderYear) AS order_year
FROM last_years;

SELECT * FROM last_year;
------------------------------------------------------------

------------------------------------------------------------
# Sacar segundo año
DROP VIEW IF EXISTS second_year;

CREATE VIEW second_year AS
SELECT OrderYear
FROM last_years
WHERE
    OrderYear NOT IN(
        SELECT *
        FROM first_year
    )
    AND OrderYear NOT IN(
        SELECT *
        FROM last_year
    );

SELECT * FROM second_year;
------------------------------------------------------------

------------------------------------------------------------
CREATE OR REPLACE VIEW recent_sales AS
SELECT
    od.`OrderID`,
    od.`ProductID`,
    pr.`ProductName`,
    cat.`CategoryName`,
    ord.`CustomerID`,
    od.`Quantity`,
    od.`UnitPrice`,
    (
        od.`UnitPrice` * od.`Quantity`
    ) AS TotalPrice,
    YEAR(ord.`OrderDate`) AS OrderYear
FROM
    `Order Details` AS od
    JOIN `Orders` AS ord ON od.`OrderID` = ord.`OrderID`
    JOIN `Products` AS pr ON od.`ProductID` = pr.`ProductID`
    JOIN `Categories` AS cat ON pr.`CategoryID` = cat.`CategoryID`
WHERE
    YEAR(ord.`OrderDate`) IN (
        SELECT OrderYear
        FROM last_years
    )
ORDER BY cat.`CategoryName`, pr.`ProductName`, OrderYear;

SELECT * FROM recent_sales;

SELECT re.`CategoryName`, re.`ProductName`, re.`OrderYear`, re.`TotalPrice`
FROM recent_sales AS re
WHERE
    re.`ProductName` = 'Chai'
ORDER BY re.`CategoryName`, re.`OrderYear`, re.`TotalPrice` DESC;

------------------------------------------------------------

------------------------------------------------------------
CREATE OR REPLACE VIEW top_products AS
SELECT rs.`CategoryName`, rs.`ProductName`, rs.`OrderYear`, SUM(rs.`Quantity`) AS TotalQuantity
FROM recent_sales AS rs
GROUP BY
    rs.`CategoryName`,
    rs.`ProductName`,
    rs.`OrderYear`
ORDER BY rs.`CategoryName`, rs.`OrderYear`, TotalQuantity DESC;

SELECT * FROM top_products;
------------------------------------------------------------

------------------------------------------------------------
DROP VIEW IF EXISTS customer_purchases;

CREATE VIEW customer_purchases AS
SELECT
    rs.`ProductName`,
    rs.`OrderYear`,
    rs.`CustomerID`,
    SUM(rs.`TotalPrice`) AS TotalPurchase,
    ROW_NUMBER() OVER (
        PARTITION BY
            rs.`ProductName`,
            rs.`OrderYear`
        ORDER BY SUM(rs.`TotalPrice`) DESC
    ) AS rnd,
    ROW_NUMBER() OVER (
        PARTITION BY
            rs.`ProductName`,
            rs.`OrderYear`
        ORDER BY SUM(rs.`TotalPrice`) ASC
    ) AS rna
FROM recent_sales rs
GROUP BY
    rs.`ProductName`,
    rs.`OrderYear`,
    rs.`CustomerID`
ORDER BY rs.`ProductName`, rs.`OrderYear`, TotalPurchase DESC;

SELECT cus_pur.`CustomerID`, cus_pur.`ProductName`, cus_pur.`OrderYear`, MAX(cus_pur.`TotalPurchase`)
FROM customer_purchases AS cus_pur
GROUP BY
    cus_pur.`CustomerID`,
    cus_pur.`ProductName`,
    cus_pur.`OrderYear`;

SELECT * FROM customer_purchases;

------------------------------------------------------------

------------------------------------------------------------
SELECT ps.`CategoryName`, IFNULL(
        GROUP_CONCAT(
            CASE
                WHEN ps.`OrderYear` = (
                    SELECT *
                    FROM first_year
                ) THEN CONCAT(
                    'MAX: (', CONCAT(
                        ps.`ProductName`, ' - ', cp_max.`CustomerID`, ' - ', cp_max.`TotalPurchase`
                    ), ') MIN: (', CONCAT(
                        ps.`ProductName`, ' - ', cp_min.`CustomerID`, ' - ', cp_min.`TotalPurchase`
                    ), ')'
                )
            END SEPARATOR '; '
        ), 'No hay ventas'
    ) AS 'Ultimo', IFNULL(
        GROUP_CONCAT(
            CASE
                WHEN ps.`OrderYear` = (
                    SELECT *
                    FROM second_year
                ) THEN CONCAT(
                    'MAX: (', CONCAT(
                        ps.`ProductName`, ' - ', cp_max.`CustomerID`, ' - ', cp_max.`TotalPurchase`
                    ), ') MIN: (', CONCAT(
                        ps.`ProductName`, ' - ', cp_min.`CustomerID`, ' - ', cp_min.`TotalPurchase`
                    ), ')'
                )
            END SEPARATOR '; '
        ), 'No hay ventas'
    ) AS 'Penultimo', IFNULL(
        GROUP_CONCAT(
            CASE
                WHEN ps.`OrderYear` = (
                    SELECT *
                    FROM last_year
                ) THEN CONCAT(
                    'MAX: (', CONCAT(
                        ps.`ProductName`, ' - ', cp_max.`CustomerID`, ' - ', cp_max.`TotalPurchase`
                    ), ') MIN: (', CONCAT(
                        ps.`ProductName`, ' - ', cp_min.`CustomerID`, ' - ', cp_min.`TotalPurchase`
                    ), ')'
                )
            END SEPARATOR '; '
        ), 'No hay ventas'
    ) AS 'Antepenultimo'
FROM
    product_sales_by_year AS ps
    JOIN customer_purchases AS cp_max ON ps.`ProductName` = cp_max.`ProductName`
    AND ps.`OrderYear` = cp_max.`OrderYear`
    AND cp_max.`TotalPurchase` = (
        SELECT MAX(cp.`TotalPurchase`)
        FROM customer_purchases AS cp
        WHERE
            cp.`ProductName` = ps.`ProductName`
            AND cp.`OrderYear` = ps.`OrderYear`
    )
    JOIN customer_purchases AS cp_min ON ps.`ProductName` = cp_min.`ProductName`
    AND ps.`OrderYear` = cp_min.`OrderYear`
    AND cp_min.`TotalPurchase` = (
        SELECT MIN(cp.`TotalPurchase`)
        FROM customer_purchases cp
        WHERE
            cp.`ProductName` = ps.`ProductName`
            AND cp.`OrderYear` = ps.`OrderYear`
    )
GROUP BY
    ps.`CategoryName`
ORDER BY ps.`CategoryName`, ps.`OrderYear`, ps.`ProductName`;
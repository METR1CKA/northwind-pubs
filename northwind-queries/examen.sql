-- Examen 1. Mostrar los productos que mas se vendieron en los ultimos 3 años por categoria y saber cual fue el cliente que mas compro y el que menos compro ese producto.
-- Las consultas deben de ser realizadas para identificar rapidamente la informacion que se interesa conocer.
-- Ejemplo, en esta consulta solo se pondra la información como se indica, es decir, si se identifica la coca como el producto que mas se vendio en un año determinado, solo se tendra que mostrar los clientes que compraron en ese año en que la coca fue la menor ganancia.
-- Consulta para identificar los productos
-- Consulta para identificar los años de esos productos
-- Consulta para identificar los clientes de esos productos en esos años (El que mas compro y otra del que menos comrpo)
-- Consulta final: COLUMNAS: categoria, Ultimo (Año), Penúltimo (Año), Antepenúltimo (Año)
-- Demostraciones en cada consulta

# Consulta para sacar los años
CREATE OR REPLACE VIEW exam_years AS
SELECT DISTINCT
    YEAR(OrderDate) AS Año
FROM orders
ORDER BY Año DESC
LIMIT 3;

SELECT * FROM exam_years;

# Consulta para sacar los productos
CREATE OR REPLACE VIEW top_products AS
SELECT
    cat.CategoryName,
    p.ProductName,
    YEAR(o.OrderDate) AS Año,
    SUM(
        od.Quantity * (od.UnitPrice - od.Discount)
    ) AS Ganancias,
    c.CustomerID,
    c.ContactName,
    ROW_NUMBER() OVER (
        PARTITION BY
            cat.CategoryName,
            YEAR(o.OrderDate)
        ORDER BY SUM(
                od.Quantity * (od.UnitPrice - od.Discount)
            ) DESC
    ) AS MaxRowNum,
    ROW_NUMBER() OVER (
        PARTITION BY
            cat.CategoryName,
            YEAR(o.OrderDate)
        ORDER BY SUM(
                od.Quantity * (od.UnitPrice - od.Discount)
            ) ASC
    ) AS MinRowNum
FROM
    `Products` AS p
    JOIN `Order Details` AS od ON p.ProductID = od.ProductID
    JOIN `Orders` AS o ON o.OrderID = od.OrderID
    JOIN `Categories` AS cat ON cat.CategoryID = p.CategoryID
    JOIN `Customers` as c ON c.CustomerID = o.CustomerID
WHERE
    YEAR(o.OrderDate) IN (
        SELECT Año
        FROM exam_years
    )
GROUP BY
    cat.CategoryName,
    p.ProductName,
    YEAR(o.OrderDate),
    c.CustomerID;

SELECT * FROM top_products;

# Consulta principal
SELECT
    CategoryName,
    MAX(
        CASE
            WHEN Año = (
                SELECT Año
                FROM exam_years
                LIMIT 0, 1
            ) THEN CONCAT(
                ProductName,
                '-',
                CustomerID,
                "(",
                Ganancias,
                ")"
            )
        END
    ) AS UltimoAño,
    MAX(
        CASE
            WHEN Año = (
                SELECT Año
                FROM exam_years
                LIMIT 1, 1
            ) THEN CONCAT(
                ProductName,
                '-',
                CustomerID,
                "(",
                Ganancias,
                ")"
            )
        END
    ) AS PenultimoAño,
    MAX(
        CASE
            WHEN Año = (
                SELECT Año
                FROM exam_years
                LIMIT 2, 1
            ) THEN CONCAT(
                ProductName,
                '-',
                CustomerID,
                "(",
                Ganancias,
                ")"
            )
        END
    ) AS AntepenultimoAño
FROM top_products
WHERE
    MaxRowNum = 1
    OR MinRowNum = 1
GROUP BY
    CategoryName;
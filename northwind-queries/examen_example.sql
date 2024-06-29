WITH
    Years AS (
        SELECT DISTINCT
            YEAR(OrderDate) AS Año
        FROM orders
        ORDER BY Año DESC
        LIMIT 3
    ),
    TopProducts AS (
        SELECT
            cat.CategoryName,
            p.ProductName,
            YEAR(o.OrderDate) AS Año,
            SUM(
                od.Quantity * (od.UnitPrice - od.Discount)
            ) AS Ganancias,
            c.CustomerID,
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
                FROM Years
            )
        GROUP BY
            cat.CategoryName,
            p.ProductName,
            YEAR(o.OrderDate),
            c.CustomerID
    )
SELECT
    CategoryName,
    GROUP_CONCAT(
        CASE
            WHEN Año = (
                SELECT Año
                FROM Years
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
    GROUP_CONCAT(
        CASE
            WHEN Año = (
                SELECT Año
                FROM Years
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
    GROUP_CONCAT(
        CASE
            WHEN Año = (
                SELECT Año
                FROM Years
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
FROM TopProducts
WHERE
    MaxRowNum = 1
    OR MinRowNum = 1
GROUP BY
    CategoryName;
-- Active: 1717300958354@@127.0.0.1@3306@northwind

USE northwind;

------------------------------------------------------------
DROP VIEW IF EXISTS employee_region;

# Consultar empleados con regiones
CREATE VIEW employee_region AS
SELECT DISTINCT
    em.`EmployeeID`,
    reg.`RegionDescription`
FROM
    `Employees` AS em
    JOIN `EmployeeTerritories` AS et ON em.`EmployeeID` = et.`EmployeeID`
    JOIN `Territories` AS ter ON et.`TerritoryID` = ter.`TerritoryID`
    JOIN `Region` AS reg ON ter.`RegionID` = reg.`RegionID`;

SELECT * FROM employee_region;
------------------------------------------------------------

------------------------------------------------------------
DROP VIEW IF EXISTS customer_product_gains;

# Calcular las ganancias por producto, cliente, región y año
CREATE VIEW customer_product_gains AS
SELECT cus.`CustomerID`, cus.`ContactName`, cus.`CompanyName`, er.`RegionDescription`, pr.`ProductName`, YEAR(ord.`OrderDate`) AS Año, SUM(
        od.`Quantity` * (
            od.`UnitPrice` - od.`Discount`
        )
    ) AS Ganancias
FROM
    Customers AS cus
    JOIN Orders AS ord ON cus.`CustomerID` = ord.`CustomerID`
    JOIN `Order Details` AS od ON ord.`OrderID` = od.`OrderID`
    JOIN Products AS pr ON od.`ProductID` = pr.`ProductID`
    JOIN employee_region AS er ON ord.`EmployeeID` = er.`EmployeeID`
GROUP BY
    er.`RegionDescription`,
    cus.`CustomerID`,
    pr.`ProductName`,
    YEAR(ord.`OrderDate`)
ORDER BY cus.`CustomerID`, cus.`ContactName`, er.`RegionDescription`, YEAR(ord.`OrderDate`);

SELECT * FROM customer_product_gains;

SELECT *
FROM customer_product_gains
WHERE
    ContactName = 'Ana Trujillo';
------------------------------------------------------------

------------------------------------------------------------
DROP VIEW IF EXISTS min_customer_product_gains;

# Identificar las ganancias mínimas por cliente y región
CREATE VIEW min_customer_product_gains AS
SELECT cpg.`CustomerID`, cpg.`ContactName`, cpg.`RegionDescription`, cpg.`ProductName`, MIN(cpg.`Ganancias`) AS MinGanancias
FROM customer_product_gains AS cpg
GROUP BY
    cpg.`CustomerID`,
    cpg.`RegionDescription`
ORDER BY cpg.`CustomerID`, cpg.`ContactName`, cpg.`RegionDescription`;

SELECT * FROM min_customer_product_gains;

SELECT *
FROM
    min_customer_product_gains AS mcpg
WHERE
    mcpg.`ContactName` = 'Ana Trujillo';
------------------------------------------------------------

------------------------------------------------------------
DROP VIEW IF EXISTS all_years_product_region;

# Mostrar todos los años de un producto en una región
CREATE VIEW all_years_product_region AS
SELECT cpg.`CustomerID`, cpg.`ContactName`, cpg.`RegionDescription`, cpg.`ProductName`, GROUP_CONCAT(
        DISTINCT cpg.`Año`
        ORDER BY cpg.`Año` ASC
    ) AS Años
FROM customer_product_gains AS cpg
GROUP BY
    cpg.`CustomerID`,
    cpg.`RegionDescription`
ORDER BY cpg.`CustomerID`, cpg.`Año`;

SELECT * FROM all_years_product_region;

SELECT *
FROM all_years_product_region AS aypr
WHERE
    aypr.`ContactName` = 'Ana Trujillo';
------------------------------------------------------------

------------------------------------------------------------
# Consulta final que utiliza las vistas para agrupar y concatenar los productos menos comprados por cliente y región
SELECT cpg.`ContactName` AS 'CONTACTO', cpg.`CompanyName` AS 'COMPAÑIA', IFNULL(
        GROUP_CONCAT(
            CASE
                WHEN cpg.`RegionDescription` = 'Northern' THEN CONCAT(
                    cpg.`ProductName`, ' - ', aypr.Años, ' - ', mcpg.MinGanancias
                )
            END SEPARATOR '; '
        ), 'N/A'
    ) AS 'NORTE', IFNULL(
        GROUP_CONCAT(
            CASE
                WHEN cpg.`RegionDescription` = 'Southern' THEN CONCAT(
                    cpg.`ProductName`, ' - ', aypr.Años, ' - ', mcpg.MinGanancias
                )
            END SEPARATOR '; '
        ), 'N/A'
    ) AS 'SUR', IFNULL(
        GROUP_CONCAT(
            CASE
                WHEN cpg.`RegionDescription` = 'Eastern' THEN CONCAT(
                    cpg.`ProductName`, ' - ', aypr.Años, ' - ', mcpg.MinGanancias
                )
            END SEPARATOR '; '
        ), 'N/A'
    ) AS 'ESTE', IFNULL(
        GROUP_CONCAT(
            CASE
                WHEN cpg.`RegionDescription` = 'Westerns' THEN CONCAT(
                    cpg.`ProductName`, ' - ', aypr.Años, ' - ', mcpg.MinGanancias
                )
            END SEPARATOR '; '
        ), 'N/A'
    ) AS 'OESTE'
FROM
    customer_product_gains AS cpg
    INNER JOIN min_customer_product_gains AS mcpg ON cpg.`CustomerID` = mcpg.`CustomerID`
    AND cpg.`RegionDescription` = mcpg.`RegionDescription`
    AND cpg.`ProductName` = mcpg.`ProductName`
    AND cpg.`Ganancias` = mcpg.`MinGanancias`
    INNER JOIN all_years_product_region AS aypr ON cpg.`CustomerID` = aypr.`CustomerID`
    AND cpg.`RegionDescription` = aypr.`RegionDescription`
    AND cpg.`ProductName` = aypr.`ProductName`
GROUP BY
    cpg.`CustomerID`,
    cpg.`RegionDescription`
ORDER BY cpg.`CustomerID`, cpg.`RegionDescription`;
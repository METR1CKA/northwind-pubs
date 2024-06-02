-- Active: 1717300958354@@127.0.0.1@3306@northwind
USE northwind;

------------------------------------------------------------
# Crear una vista que muestre todas los empleados region
DROP VIEW IF EXISTS employeeregion;

CREATE VIEW employeeregion AS
SELECT DISTINCT
    em.`EmployeeID`,
    reg.`RegionDescription`
FROM
    Employees AS em
    JOIN EmployeeTerritories AS et ON em.`EmployeeID` = et.`EmployeeID`
    JOIN Territories AS ter ON et.`TerritoryID` = ter.`TerritoryID`
    JOIN Region AS reg ON ter.`RegionID` = reg.`RegionID`;

SELECT * FROM employeeregion;
------------------------------------------------------------

------------------------------------------------------------
# Crear una vista que muestre todas las ganancias de los clientes
DROP VIEW IF EXISTS customerpurchases;

CREATE VIEW customerpurchases AS
SELECT
    cus.`CustomerID`,
    cus.`ContactName`,
    cus.`CompanyName`,
    YEAR(ord.`OrderDate`) AS OrderYear,
    er.`RegionDescription`,
    SUM(
        od.`Quantity` * od.`UnitPrice`
    ) AS TotalPurchase
FROM
    Customers AS cus
    INNER JOIN Orders AS ord ON cus.`CustomerID` = ord.`CustomerID`
    INNER JOIN `Order Details` AS od ON ord.`OrderID` = od.`OrderID`
    INNER JOIN EmployeeRegion AS er ON er.`EmployeeID` = ord.`EmployeeID`
GROUP BY
    cus.`CustomerID`,
    cus.`CompanyName`,
    YEAR(ord.`OrderDate`),
    er.`RegionDescription`;

SELECT * FROM customerpurchases;
------------------------------------------------------------

------------------------------------------------------------
# Crear la vista de las compras máximas por año y región
DROP VIEW IF EXISTS maxpurchases;

CREATE VIEW maxpurchases AS
SELECT
    OrderYear,
    RegionDescription,
    MAX(TotalPurchase) AS MaxTotalPurchase
FROM CustomerPurchases
GROUP BY
    OrderYear,
    RegionDescription;

SELECT * FROM maxpurchases;
------------------------------------------------------------

------------------------------------------------------------
# Mostrar una tabla que contenga los clientes que comparon mas por año y por region
SELECT cp.`RegionDescription` AS 'REGION', cp.`OrderYear` AS 'AÑO', cp.`ContactName` AS 'CLIENTE', cp.`CompanyName` AS 'COMPAÑIA', cp.`TotalPurchase` AS 'TOTAL'
FROM
    CustomerPurchases AS cp
    INNER JOIN MaxPurchases AS mp ON cp.`OrderYear` = mp.`OrderYear`
    AND cp.`RegionDescription` = mp.`RegionDescription`
    AND cp.`TotalPurchase` = mp.`MaxTotalPurchase`
ORDER BY cp.`OrderYear`, cp.`RegionDescription`;
------------------------------------------------------------

------------------------------------------------------------
# Mostrar una tabla que contenga los clientes que compraron más por año y por región
SELECT cp.OrderYear AS 'AÑO', GROUP_CONCAT(
        CASE
            WHEN cp.`RegionDescription` = 'Northern' THEN CONCAT(cp.`ContactName`)
        END SEPARATOR ', '
    ) AS 'Norte', GROUP_CONCAT(
        CASE
            WHEN cp.`RegionDescription` = 'Southern' THEN CONCAT(cp.`ContactName`)
        END SEPARATOR ', '
    ) AS 'Sur', GROUP_CONCAT(
        CASE
            WHEN cp.`RegionDescription` = 'Eastern' THEN CONCAT(cp.`ContactName`)
        END SEPARATOR ', '
    ) AS 'Este', GROUP_CONCAT(
        CASE
            WHEN cp.`RegionDescription` = 'Westerns' THEN CONCAT(cp.`ContactName`)
        END SEPARATOR ', '
    ) AS 'Oeste'
FROM
    CustomerPurchases AS cp
    INNER JOIN MaxPurchases AS mp ON cp.`OrderYear` = mp.`OrderYear`
    AND cp.`RegionDescription` = mp.`RegionDescription`
    AND cp.`TotalPurchase` = mp.`MaxTotalPurchase`
GROUP BY
    cp.`OrderYear`;
------------------------------------------------------------
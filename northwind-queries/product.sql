------------------------------------------------------------
# Eliminar la vista `employee_region` si ya existe
DROP VIEW IF EXISTS employee_region;

# Crear la vista `employee_region` para relacionar empleados con regiones
CREATE VIEW employee_region AS
SELECT DISTINCT
    em.`EmployeeID`,
    reg.`RegionDescription`
FROM
    `Employees` AS em
    JOIN `EmployeeTerritories` AS et ON em.`EmployeeID` = et.`EmployeeID`
    JOIN `Territories` AS ter ON et.`TerritoryID` = ter.`TerritoryID`
    JOIN `Region` AS reg ON ter.`RegionID` = reg.`RegionID`;

# Verificar el contenido de la vista `employee_region`
SELECT * FROM employee_region;
------------------------------------------------------------

------------------------------------------------------------
# Eliminar la vista `customer_product_gains` si ya existe
DROP VIEW IF EXISTS customer_product_gains;

# Crear la vista `customer_product_gains` para calcular las ganancias por producto, cliente, región y año
CREATE VIEW customer_product_gains AS
SELECT c.CustomerID, er.RegionDescription, p.ProductName, YEAR(o.OrderDate) AS Año, SUM(
        od.Quantity * (od.UnitPrice - od.Discount)
    ) AS Ganancias
FROM
    Customers AS c
    JOIN Orders AS o ON c.CustomerID = o.CustomerID
    JOIN `Order Details` AS od ON o.OrderID = od.OrderID
    JOIN Products AS p ON od.ProductID = p.ProductID
    JOIN employee_region AS er ON er.EmployeeID = o.EmployeeID
GROUP BY
    er.RegionDescription,
    c.CustomerID,
    p.ProductName,
    YEAR(o.OrderDate);

# Verificar el contenido de la vista `customer_product_gains`
SELECT * FROM customer_product_gains;
------------------------------------------------------------

------------------------------------------------------------
# Eliminar la vista `min_customer_product_gains` si ya existe
DROP VIEW IF EXISTS min_customer_product_gains;

# Crear la vista `min_customer_product_gains` para identificar las ganancias mínimas por cliente y región
CREATE VIEW min_customer_product_gains AS
SELECT
    CustomerID,
    RegionDescription,
    MIN(Ganancias) AS MinGanancias
FROM customer_product_gains
GROUP BY
    CustomerID,
    RegionDescription;

# Verificar el contenido de la vista `min_customer_product_gains`
SELECT * FROM min_customer_product_gains;
------------------------------------------------------------

------------------------------------------------------------
# Consulta final que utiliza las vistas para agrupar y concatenar los productos menos comprados por cliente y región
SELECT cpg.CustomerID, GROUP_CONCAT(
        CASE
            WHEN cpg.RegionDescription = 'Eastern' THEN CONCAT(cpg.ProductName, '-', cpg.Año)
        END SEPARATOR ', '
    ) AS Este, GROUP_CONCAT(
        CASE
            WHEN cpg.RegionDescription = 'Northern' THEN CONCAT(cpg.ProductName, '-', cpg.Año)
        END SEPARATOR ', '
    ) AS Norte, GROUP_CONCAT(
        CASE
            WHEN cpg.RegionDescription = 'Southern' THEN CONCAT(cpg.ProductName, '-', cpg.Año)
        END SEPARATOR ', '
    ) AS Sur, GROUP_CONCAT(
        CASE
            WHEN cpg.RegionDescription = 'Westerns' THEN CONCAT(cpg.ProductName, '-', cpg.Año)
        END SEPARATOR ', '
    ) AS Oeste
FROM
    customer_product_gains cpg
    INNER JOIN min_customer_product_gains mcpg ON cpg.CustomerID = mcpg.CustomerID
    AND cpg.RegionDescription = mcpg.RegionDescription
    AND cpg.Ganancias = mcpg.MinGanancias
GROUP BY
    cpg.CustomerID;

# Verificar el resultado final
------------------------------------------------------------
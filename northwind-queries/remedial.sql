-- Activa la base de datos Northwind
USE northwind;

------------------------------------------------------------
DROP VIEW IF EXISTS empleado_region;

-- Consultar empleados con regiones
CREATE OR REPLACE VIEW empleado_region AS
SELECT DISTINCT
    em.`EmployeeID`,
    reg.`RegionDescription`
FROM
    `Employees` AS em
    JOIN `EmployeeTerritories` AS et ON em.`EmployeeID` = et.`EmployeeID`
    JOIN `Territories` AS ter ON et.`TerritoryID` = ter.`TerritoryID`
    JOIN `Region` AS reg ON ter.`RegionID` = reg.`RegionID`;

DROP VIEW IF EXISTS regions;

CREATE OR REPLACE VIEW regions AS
SELECT DISTINCT
    reg.`RegionDescription`
FROM
    empleado_region AS reg
ORDER BY
    reg.`RegionDescription`
LIMIT 4;

SELECT * FROM empleado_region;

SELECT * FROM regions;

DROP VIEW IF EXISTS Eastern;

CREATE OR REPLACE VIEW Eastern AS
SELECT reg.`RegionDescription` AS region FROM regions AS reg LIMIT 0, 1;

SELECT * FROM Eastern;

DROP VIEW IF EXISTS Northern;

CREATE OR REPLACE VIEW Northern AS
SELECT reg.`RegionDescription` AS region FROM regions AS reg LIMIT 1, 1;

SELECT * FROM Northern;

DROP VIEW IF EXISTS Southern;

CREATE OR REPLACE VIEW Southern AS
SELECT reg.`RegionDescription` AS region FROM regions AS reg LIMIT 2, 1;

SELECT * FROM Southern;

DROP VIEW IF EXISTS Westerns;

CREATE OR REPLACE VIEW Westerns AS
SELECT reg.`RegionDescription` AS region FROM regions AS reg LIMIT 3, 1;

SELECT * FROM Westerns;
------------------------------------------------------------

------------------------------------------------------------
DROP VIEW IF EXISTS cliente_producto_ganancias;

-- Crear una vista para calcular las ganancias por producto, categoría y región
CREATE OR REPLACE VIEW cliente_producto_ganancias AS
SELECT
    pr.`ProductName`,
    catg.`CategoryName`,
    er.`RegionDescription`,
    -- YEAR(ord.`OrderDate`) AS Anio,
    SUM(od.`Quantity` * (od.`UnitPrice` - od.`Discount`)) AS Ganancias
FROM
    `Order Details` AS od
    JOIN `Orders` AS ord ON ord.`OrderID` = od.`OrderID`
    JOIN `Products` AS pr ON od.`ProductID` = pr.`ProductID`
    JOIN `Categories` AS catg ON pr.`CategoryID` = catg.`CategoryID`
    JOIN empleado_region AS er ON ord.`EmployeeID` = er.`EmployeeID`
GROUP BY
    pr.`ProductName`,
    catg.`CategoryName`,
    er.`RegionDescription`
ORDER BY
    pr.`ProductName`,
    catg.`CategoryName`,
    er.`RegionDescription`;

SELECT * FROM cliente_producto_ganancias;
------------------------------------------------------------

------------------------------------------------------------
DROP VIEW IF EXISTS cliente_producto_ganancias_porcentaje;

-- Crear una consulta para obtener el porcentaje de ganancias por producto, categoría y región
CREATE OR REPLACE VIEW cliente_producto_ganancias_porcentaje AS
SELECT
    cpg.`ProductName`,
    cpg.`CategoryName`,
    cpg.`RegionDescription`,
    cpg.`Ganancias`,
    ROUND((cpg.`Ganancias` / SUM(cpg.`Ganancias`) OVER (PARTITION BY cpg.`CategoryName`, cpg.`RegionDescription`)) * 100, 1) AS Porcentaje
FROM
    cliente_producto_ganancias AS cpg
ORDER BY
    cpg.`CategoryName`,
    cpg.`RegionDescription`,
    cpg.`Ganancias` DESC;

SELECT * FROM cliente_producto_ganancias_porcentaje;

-- Consulta para obtener el porcentaje de ganancias por categoría y región
SELECT
    _cpgp.`CategoryName`,
    _cpgp.`RegionDescription`,
    _cpgp.`Ganancias`,
    _cpgp.`Porcentaje`
FROM
    cliente_producto_ganancias_porcentaje AS _cpgp;

SELECT
    *
FROM
    cliente_producto_ganancias_porcentaje
WHERE
    `CategoryName` = 'Beverages'
    AND `RegionDescription` = 'Northern';
------------------------------------------------------------

------------------------------------------------------------
DROP VIEW IF EXISTS maximas_ganancias_por_categoria_region;

-- Crear la vista final para seleccionar el producto con el mayor porcentaje por categoría y región
CREATE OR REPLACE VIEW maximas_ganancias_por_categoria_region AS
SELECT
    cpp.`CategoryName`,
    cpp.`RegionDescription`,
    cpp.`ProductName`,
    cpp.`Ganancias`,
    cpp.`Porcentaje`
FROM
    cliente_producto_ganancias_porcentaje AS cpp
WHERE
    cpp.`Porcentaje` = (
        SELECT MAX(cpp2.`Porcentaje`)
        FROM cliente_producto_ganancias_porcentaje AS cpp2
        WHERE cpp2.`CategoryName` = cpp.`CategoryName`
        AND cpp2.`RegionDescription` = cpp.`RegionDescription`
    );

SELECT * FROM maximas_ganancias_por_categoria_region;

-- Consulta para obtener el porcentaje de ganancias mayores por categoría y región
SELECT
    mgpcr.`CategoryName`,
    mgpcr.`RegionDescription`,
    mgpcr.`Ganancias`,
    mgpcr.`Porcentaje`
FROM
    maximas_ganancias_por_categoria_region AS mgpcr;

SELECT
    *
FROM
    maximas_ganancias_por_categoria_region
WHERE
    `CategoryName` = 'Beverages'
    AND `RegionDescription` = 'Northern';
------------------------------------------------------------

------------------------------------------------------------
-- Consulta final para mostrar los productos con el porcentaje más alto por categoría y región
SELECT
    mcpg.`CategoryName` AS 'CATEGORÍA',
    GROUP_CONCAT(
        CASE
            WHEN mcpg.`RegionDescription` = (SELECT region FROM Northern)
            THEN CONCAT(mcpg.`ProductName`, ' (', mcpg.`Porcentaje`, '%)')
        END
    ) AS 'NORTE',
    GROUP_CONCAT(
        CASE
            WHEN mcpg.`RegionDescription` = (SELECT region FROM Southern)
            THEN CONCAT(mcpg.`ProductName`, ' (', mcpg.`Porcentaje`, '%)')
        END
    ) AS 'SUR',
    GROUP_CONCAT(
        CASE
            WHEN mcpg.`RegionDescription` = (SELECT region FROM Eastern)
            THEN CONCAT(mcpg.`ProductName`, ' (', mcpg.`Porcentaje`, '%)')
        END
    ) AS 'ESTE',
    GROUP_CONCAT(
        CASE
            WHEN mcpg.`RegionDescription` = (SELECT region FROM Westerns)
            THEN CONCAT(mcpg.`ProductName`, ' (', mcpg.`Porcentaje`, '%)')
        END
    ) AS 'OESTE'
FROM
    maximas_ganancias_por_categoria_region AS mcpg
GROUP BY
    mcpg.`CategoryName`
ORDER BY
    mcpg.`CategoryName`;

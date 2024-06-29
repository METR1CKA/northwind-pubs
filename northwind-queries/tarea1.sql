-- Active: 1717300958354@@127.0.0.1@3306@northwind

USE northwind;

# 1. Mostrar la cantidad de empleados.
SELECT COUNT(*) AS 'CANTIDAD DE EMPLEADOS' FROM `Employees`;

# 2. Mostrar la cantidad de productos.
SELECT COUNT(*) AS 'CANTIDAD DE PRODUCTOS' FROM `Products`;

# 3. Mostrar la cantidad de territorios.
SELECT COUNT(*) AS 'CANTIDAD DE TERRITORIOS' FROM `Territories`;

# 4. Mostrar la cantidad de regiones.
SELECT COUNT(*) AS 'CANTIDAD DE REGIONES' FROM `Region`;

# 5. Mostrar la cantidad de órdenes que se han generado.
SELECT COUNT(*) AS 'CANTIDAD DE ORDENES' FROM `Orders`;

# 6. Obtener la cantidad de empleados por región.
SELECT reg.`RegionDescription` AS 'REGION', COUNT(DISTINCT em.`EmployeeID`) AS 'CANTIDAD DE EMPLEADOS'
FROM
    `Employees` em
    JOIN `EmployeeTerritories` AS emt ON em.`EmployeeID` = emt.`EmployeeID`
    JOIN `Territories` AS te ON emt.`TerritoryID` = te.`TerritoryID`
    JOIN `Region` AS reg ON te.`RegionID` = reg.`RegionID`
GROUP BY
    reg.`RegionDescription`;

# 7. Obtener la cantidad de empleados por territorio. PENDIENTE
SELECT DISTINCT
    te.`TerritoryDescription` AS 'TERRITORIO',
    COUNT(DISTINCT em.`EmployeeID`) AS 'CANTIDAD DE EMPLEADOS'
FROM
    `Employees` AS em
    JOIN `EmployeeTerritories` AS emt ON em.`EmployeeID` = emt.`EmployeeID`
    JOIN `Territories` AS te ON emt.`TerritoryID` = te.`TerritoryID`
GROUP BY
    te.`TerritoryDescription`;

# 8. Obtener la cantidad de territorio que cubre cada empleado.
SELECT CONCAT(
        em.`FirstName`, ' ', em.`LastName`
    ) AS 'NOMBRE', COUNT(te.`TerritoryID`) AS 'CANTIDAD DE TERRITORIOS'
FROM
    `Employees` AS em
    JOIN `EmployeeTerritories` AS emt ON em.`EmployeeID` = emt.`EmployeeID`
    JOIN `Territories` AS te ON emt.`TerritoryID` = te.`TerritoryID`
GROUP BY
    em.`EmployeeID`;

# 9. Obtener las unidades vendidas de cada producto.
SELECT prod.`ProductName` AS 'NOMBRE', SUM(od.`Quantity`) AS 'UNIDADES VENDIDAS'
FROM
    `Products` AS prod
    JOIN `Order Details` AS od ON prod.`ProductID` = od.`ProductID`
    JOIN `Orders` AS ord ON od.`OrderID` = ord.`OrderID`
GROUP BY
    prod.`ProductID`;

# 10. Obtener la cantidad de órdenes que ha realizado cada empleado.
SELECT em.`EmployeeID` AS 'ID', CONCAT(
        em.`FirstName`, ' ', em.`LastName`
    ) AS 'NOMBRE', COUNT(ord.`OrderID`) AS 'CANTIDAD DE ORDENES'
FROM `Employees` AS em
    JOIN `Orders` AS ord ON em.`EmployeeID` = ord.`EmployeeID`
GROUP BY
    em.`EmployeeID`;

# 11. Obtener las ganancias por cada producto.
SELECT prod.`ProductID` AS 'ID', prod.`ProductName` AS 'NOMBRE', SUM(
        od.`UnitPrice` * od.`Quantity`
    ) AS 'GANANCIAS'
FROM
    `Products` AS prod
    JOIN `Order Details` AS od ON prod.`ProductID` = od.`ProductID`
    JOIN `Orders` AS ord ON od.`OrderID` = ord.`OrderID`
GROUP BY
    prod.`ProductID`;

# 12. Obtener las ganancias que ha generado cada cliente por producto.
SELECT cust.`CompanyName` AS 'CLIENTE', prod.`ProductName` AS 'PRODUCTO', SUM(
        od.`UnitPrice` * od.`Quantity`
    ) AS 'GANANCIAS'
FROM
    `Customers` AS cust
    JOIN `Orders` AS ord ON cust.`CustomerID` = ord.`CustomerID`
    JOIN `Order Details` AS od ON ord.`OrderID` = od.`OrderID`
    JOIN `Products` AS prod ON od.`ProductID` = prod.`ProductID`
GROUP BY
    cust.`CompanyName`,
    prod.`ProductName`;

# 13. Generar las ganancias por región.
SELECT reg.`RegionDescription` AS 'REGION', SUM(
        od.`UnitPrice` * od.`Quantity`
    ) AS 'GANANCIAS'
FROM
    `Region` AS reg
    JOIN `Territories` AS te ON reg.`RegionID` = te.`RegionID`
    JOIN `EmployeeTerritories` AS emt ON te.`TerritoryID` = emt.`TerritoryID`
    JOIN `Orders` AS ord ON emt.`EmployeeID` = ord.`EmployeeID`
    JOIN `Order Details` AS od ON ord.`OrderID` = od.`OrderID`
GROUP BY
    reg.`RegionDescription`;

# 14. Generar las ganancias por territorio y región.
SELECT te.`TerritoryDescription` AS 'TERRITORIO', reg.`RegionDescription` AS 'REGION', SUM(
        od.`UnitPrice` * od.`Quantity`
    ) AS 'GANANCIAS'
FROM
    `Employees` AS em
    JOIN `EmployeeTerritories` AS emt ON em.`EmployeeID` = emt.`EmployeeID`
    JOIN `Territories` AS te ON emt.`TerritoryID` = te.`TerritoryID`
    JOIN `Region` AS reg ON te.`RegionID` = reg.`RegionID`
    JOIN `Orders` AS ord ON em.`EmployeeID` = ord.`EmployeeID`
    JOIN `Order Details` AS od ON ord.`OrderID` = od.`OrderID`
GROUP BY
    te.`TerritoryDescription`,
    reg.`RegionDescription`;

# 15. Generar las ganancias por región y producto.
SELECT reg.`RegionDescription` AS 'REGION', prod.`ProductName` AS 'PRODUCTO', SUM(
        od.`UnitPrice` * od.`Quantity`
    ) AS 'GANANCIAS'
FROM
    `Employees` AS em
    JOIN `EmployeeTerritories` AS emt ON em.`EmployeeID` = emt.`EmployeeID`
    JOIN `Territories` AS te ON emt.`TerritoryID` = te.`TerritoryID`
    JOIN `Region` AS reg ON te.`RegionID` = reg.`RegionID`
    JOIN `Orders` AS ord ON em.`EmployeeID` = ord.`EmployeeID`
    JOIN `Order Details` AS od ON ord.`OrderID` = od.`OrderID`
    JOIN `Products` AS prod ON od.`ProductID` = prod.`ProductID`
GROUP BY
    reg.`RegionDescription`,
    prod.`ProductName`;

# 16. Obtener la cantidad de artículos por categoría.
SELECT cat.`CategoryName` AS 'CATEGORIA', COUNT(prod.`ProductID`) AS 'CANTIDAD DE ARTICULOS'
FROM
    `Products` AS prod
    JOIN `Categories` AS cat ON prod.`CategoryID` = cat.`CategoryID`
GROUP BY
    cat.`CategoryName`;

# 17. Mostrar los productos que sus unidades sean mayores a 30.
SELECT prod.`ProductName` AS 'PRODUCTO', od.`Quantity` AS 'UNIDADES'
FROM
    `Products` AS prod
    JOIN `Order Details` AS od ON prod.`ProductID` = od.`ProductID`
WHERE
    od.`Quantity` > 30;

# 18. Mostrar la cantidad de productos por categoría.
SELECT cat.`CategoryName` AS 'CATEGORIA', COUNT(prod.`ProductID`) AS 'CANTIDAD DE PRODUCTOS'
FROM
    `Products` AS prod
    JOIN `Categories` AS cat ON prod.`CategoryID` = cat.`CategoryID`
GROUP BY
    cat.`CategoryName`;

# 19. Mostrar los productos que son mayores a 40 dlls.
SELECT prod.`ProductName` AS 'PRODUCTO', od.`UnitPrice` AS 'PRECIO'
FROM
    `Products` AS prod
    JOIN `Order Details` AS od ON prod.`ProductID` = od.`ProductID`
WHERE
    od.`UnitPrice` > 40;

# 20. Mostrar la cantidad de territorios por región.
SELECT reg.`RegionDescription` AS 'REGION', COUNT(te.`TerritoryID`) AS 'CANTIDAD DE TERRITORIOS'
FROM
    `Region` AS reg
    JOIN `Territories` AS te ON reg.`RegionID` = te.`RegionID`
GROUP BY
    reg.`RegionDescription`;

# 21. Mostrar el nombre completo y la dirección del empleado.
SELECT CONCAT(
        em.`FirstName`, ' ', em.`LastName`
    ) AS 'NOMBRE', em.`Address` AS 'DIRECCION'
FROM `Employees` AS em;

# 22. Mostrar el nombre del cliente, la cantidad de orden, ordenados por nombre del cliente y número de orden.
SELECT ord.`OrderID` AS 'NUMERO DE ORDEN', cust.`CompanyName` AS 'CLIENTE', COUNT(ord.`OrderID`) AS 'CANTIDAD DE ORDENES'
FROM
    `Customers` AS cust
    JOIN `Orders` AS ord ON cust.`CustomerID` = ord.`CustomerID`
GROUP BY
    cust.`CompanyName`,
    ord.`OrderID`
ORDER BY cust.`CompanyName`, ord.`OrderID`;

# 23. Mostrar el nombre de la región y el nombre del territorio ordenados como se mencionaron.
SELECT reg.`RegionDescription` AS 'REGION', te.`TerritoryDescription` AS 'TERRITORIO'
FROM
    `Region` AS reg
    JOIN `Territories` AS te ON reg.`RegionID` = te.`RegionID`
ORDER BY reg.`RegionDescription`, te.`TerritoryDescription`;

# 24. Mostrar el nombre de la empresa, contactos y teléfonos de todos los clientes.
SELECT cust.`CompanyName` AS 'EMPRESA', cust.`ContactName` AS 'CONTACTO', cust.`ContactTitle` AS 'CARGO', cust.`Phone` AS 'TELEFONO'
FROM `Customers` AS cust;

# 25. Mostrar el total de unidades vendidas por producto.
SELECT prod.`ProductName` AS 'PRODUCTO', SUM(od.`Quantity`) AS 'UNIDADES VENDIDAS'
FROM
    `Products` AS prod
    JOIN `Order Details` AS od ON prod.`ProductID` = od.`ProductID`
GROUP BY
    prod.`ProductName`;
--1.      List all cities that have both Employees and Customers.

SELECT dbo.Employees.City
FROM dbo.Employees
INNER JOIN dbo.Customers
ON dbo.Employees.City = dbo.Customers.City
GROUP BY dbo.Employees.City

--2.      List all cities that have Customers but no Employee.

--a.      Use sub-query

SELECT DISTINCT City
FROM dbo.Customers
WHERE City NOT IN (
    SELECT DISTINCT City
    FROM dbo.Employees
);

--b.      Do not use sub-query

SELECT dbo.Customers.City
FROM dbo.Customers
LEFT OUTER JOIN dbo.Employees
ON dbo.Employees.City = dbo.Customers.City
WHERE dbo.Employees.City IS NULL
GROUP BY dbo.Customers.City

--3.      List all products and their total order quantities throughout all orders.

SELECT products.ProductName AS productName, SUM(orderDetails.Quantity) AS orderQuantity
FROM dbo.[Order Details] AS orderDetails
INNER JOIN dbo.Products AS products
ON orderDetails.ProductID = products.ProductID
GROUP BY products.ProductName

--4.      List all Customer Cities and total products ordered by that city.

SELECT customers.City, SUM(orderDetails.Quantity) AS orderQuantity
FROM dbo.Customers AS customers
INNER JOIN dbo.Orders AS orders
ON customers.CustomerID = orders.CustomerID
INNER JOIN dbo.[Order Details] AS orderDetails
ON orders.OrderID = orderDetails.OrderID
GROUP BY customers.City

--5.      List all Customer Cities that have at least two customers.


SELECT customers.City, COUNT(customers.City) AS CustomerCount
FROM dbo.Customers AS customers
GROUP BY customers.City
HAVING COUNT(customers.City) >= 2

--6.      List all Customer Cities that have ordered at least two different kinds of products.

SELECT customers.City, COUNT(orderDetails.ProductID)
FROM dbo.Customers AS customers
INNER JOIN dbo.Orders AS orders
ON orders.CustomerID = customers.CustomerID
INNER JOIN dbo.[Order Details] AS orderDetails
ON orderDetails.OrderID = orders.OrderID
GROUP BY customers.City, orderDetails.ProductID
HAVING COUNT(orderDetails.ProductID) >= 2

--7.      List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.

SELECT customers.CustomerID
FROM dbo.Customers AS customers
INNER JOIN dbo.Orders AS orders
ON customers.CustomerID = orders.CustomerID
WHERE customers.City != orders.ShipCity
GROUP BY customers.CustomerID


--8.      List 5 most popular products, their average price, and the customer city that ordered most quantity of it.

WITH ProductPopularity AS (
    SELECT p.ProductID, p.ProductName, AVG(p.UnitPrice) AS AvgPrice, 
           SUM(od.Quantity) AS TotalQuantity
    FROM dbo.[Order Details] AS od
    INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID
    GROUP BY p.ProductID, p.ProductName
),
ProductCityQuantity AS (
    SELECT p.ProductID, p.ProductName, c.City, SUM(od.Quantity) AS CityQuantity
    FROM dbo.[Order Details] AS od
    INNER JOIN dbo.Products AS p
    ON od.ProductID = p.ProductID
    INNER JOIN dbo.Orders AS o
    ON od.OrderID = o.OrderID
    INNER JOIN dbo.Customers AS c
    ON o.CustomerID = c.CustomerID
    GROUP BY p.ProductID, p.ProductName, c.City
),
TopCities AS (
    SELECT pp.ProductID, pp.ProductName, pp.AvgPrice, pp.TotalQuantity, pc.City, pc.CityQuantity,
           ROW_NUMBER() OVER (PARTITION BY pp.ProductID ORDER BY pc.CityQuantity DESC) AS Rank
    FROM ProductPopularity AS pp
    INNER JOIN ProductCityQuantity AS pc
    ON pp.ProductID = pc.ProductID
)
SELECT TOP(5) ProductName, AvgPrice, City AS TopCity, TotalQuantity
FROM TopCities
WHERE Rank = 1
ORDER BY TotalQuantity DESC

--9.      List all cities that have never ordered something but we have employees there.

--a.      Use sub-query

SELECT DISTINCT e.City
FROM dbo.Employees AS e
WHERE e.City NOT IN (
    SELECT DISTINCT o.ShipCity
    FROM dbo.Orders AS o
);

--b.      Do not use sub-query

SELECT DISTINCT e.City
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o
ON e.City = o.ShipCity
WHERE o.OrderID IS NULL;

--10.  List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)

WITH EmployeeOrderCity AS (
    SELECT TOP 1 e.City AS EmployeeCity, COUNT(o.OrderID) AS TotalOrders
    FROM dbo.Employees AS e
    INNER JOIN dbo.Orders AS o ON e.EmployeeID = o.EmployeeID
    GROUP BY e.City
    ORDER BY TotalOrders DESC
),

CustomerProductCity AS (
    SELECT TOP 1 c.City AS CustomerCity, SUM(od.Quantity) AS TotalQuantityOrdered
    FROM dbo.Customers AS c
    INNER JOIN dbo.Orders AS o ON c.CustomerID = o.CustomerID
    INNER JOIN dbo.[Order Details] AS od ON o.OrderID = od.OrderID
    GROUP BY c.City
    ORDER BY TotalQuantityOrdered DESC
)

SELECT eo.EmployeeCity AS City
FROM EmployeeOrderCity eo
INNER JOIN CustomerProductCity cp
ON eo.EmployeeCity = cp.CustomerCity;

--NO such city



--11. How do you remove the duplicates record of a table?

WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY column1, column2, ... ORDER BY someColumn) AS row_num
    FROM tableName
)
DELETE FROM CTE
WHERE row_num > 1;

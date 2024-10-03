SELECT TOP(10) * 
FROM dbo.[Order Details]

SELECT TOP(10) * 
FROM dbo.Orders

SELECT TOP(10) * 
FROM dbo.Products

SELECT TOP(10) * 
FROM dbo.Customers

SELECT TOP(10) * 
FROM dbo.Shippers

--14.  List all Products that has been sold at least once in last 27 years.

SELECT ProductID, OrderDate
FROM dbo.[Order Details] As orderDetails
INNER JOIN dbo.Orders As orders
ON orderDetails.OrderID = orders.OrderID
WHERE DATEDIFF(YEAR, orders.OrderDate, GETDATE()) <= 27


--15.  List top 5 locations (Zip Code) where the products sold most.

SELECT TOP(5) orders.ShipPostalCode, SUM(orderDetails.Quantity) AS TotalQuantity
FROM dbo.Orders As orders
INNER JOIN dbo.[Order Details] As orderDetails
ON orderDetails.OrderID = orders.OrderID
GROUP BY orders.ShipPostalCode
ORDER BY TotalQuantity DESC

--16.  List top 5 locations (Zip Code) where the products sold most in last 27 years.

SELECT TOP(5) orders.ShipPostalCode, SUM(orderDetails.Quantity) AS TotalQuantity
FROM dbo.Orders As orders
INNER JOIN dbo.[Order Details] As orderDetails
ON orderDetails.OrderID = orders.OrderID
WHERE DATEDIFF(YEAR, orders.OrderDate, GETDATE()) <= 27
GROUP BY orders.ShipPostalCode
ORDER BY TotalQuantity DESC

--17.   List all city names and number of customers in that city.     

SELECT City, COUNT(DISTINCT CustomerID) AS TotalCustomer
FROM dbo.Customers
GROUP BY City

--18.  List city names which have more than 2 customers, and number of customers in that city

SELECT City
FROM dbo.Customers
GROUP BY City
HAVING COUNT(DISTINCT CustomerID) > 2

--19.  List the names of customers who placed orders after 1/1/98 with order date.

SELECT customers.CustomerID, orders.OrderDate
FROM dbo.Customers AS customers
INNER JOIN dbo.orders AS orders
ON customers.CustomerID = orders.CustomerID
WHERE orders.OrderDate > '1998-01-01'

--20.  List the names of all customers with most recent order dates

SELECT customers.ContactName, orders.OrderDate
FROM dbo.Customers AS customers
INNER JOIN dbo.orders AS orders
ON customers.CustomerID = orders.CustomerID
ORDER BY orders.OrderDate DESC

--21.  Display the names of all customers  along with the  count of products they bought

SELECT customers.ContactName, products.productName
FROM dbo.Customers AS customers
INNER JOIN dbo.Orders AS orders
ON customers.CustomerID = orders.CustomerID
INNER JOIN dbo.[Order Details] AS orderDetails
ON orderDetails.orderID = orders.orderID
INNER JOIN dbo.Products AS products
ON products.ProductID = orderDetails.ProductID

--22.  Display the customer ids who bought more than 100 Products with count of products.

SELECT orders.CustomerID, COUNT(products.productName) AS totalProduct
FROM dbo.Orders AS orders
INNER JOIN dbo.[Order Details] AS orderDetails
ON orderDetails.orderID = orders.orderID
INNER JOIN dbo.Products AS products
ON products.ProductID = orderDetails.ProductID
GROUP BY orders.CustomerID
HAVING COUNT(products.productName) < 100

/*23.  List all of the possible ways that suppliers can ship their products. Display the results as below

    Supplier Company Name                Shipping Company Name

    ---------------------------------            ----------------------------------*/

SELECT suppliers.CompanyName AS [Supplier Company Name], shippers.CompanyName AS [Shipping Company Name]
FROM dbo.Suppliers AS suppliers
INNER JOIN dbo.Products AS Products
ON suppliers.SupplierID = Products.SupplierID
INNER JOIN dbo.[Order Details] AS orderDetails
ON orderDetails.ProductID = Products.ProductID
INNER JOIN dbo.Orders AS orders
ON orders.OrderID = orderDetails.OrderID
INNER JOIN dbo.Shippers AS shippers
ON shippers.ShipperID = orders.ShipVia
GROUP BY suppliers.CompanyName, shippers.CompanyName

--24.  Display the products order each day. Show Order date and Product Name.

SELECT products.ProductName AS productName, orders.OrderDate AS orderDate
FROM dbo.[Order Details] AS OrderDetails
INNER JOIN dbo.Orders AS orders
ON OrderDetails.OrderID = orders.OrderID
INNER JOIN dbo.Products AS products
ON OrderDetails.ProductID = products.ProductID
GROUP BY products.ProductName , orders.OrderDate

--25.  Displays pairs of employees who have the same job title.

SELECT e1.FirstName + ' ' + e1.LastName AS Employee1Name,
       e2.FirstName + ' ' + e2.LastName AS Employee2Name,
       e1.Title AS JobTitle
FROM dbo.Employees e1
INNER JOIN dbo.Employees e2
ON e1.Title = e2.Title
AND e1.EmployeeID > e2.EmployeeID
ORDER BY e1.Title, e1.EmployeeID, e2.EmployeeID;


--26.  Display all the Managers who have more than 2 employees reporting to them.

SELECT *, COUNT(ManagerName) as ReportsReceived
FROM (
SELECT e1.LastName + ' ' + e1.FirstName AS ManagerName
FROM dbo.Employees e1
INNER JOIN dbo.Employees e2
On e2.ReportsTo = e1.EmployeeID
) AS Subquery
GROUP BY Subquery.ManagerName
Having COUNT(ManagerName) > 2

/*27.  Display the customers and suppliers by city. The results should have the following columns

City

Name

Contact Name,

Type (Customer or Supplier)*/

SELECT customers.City AS City, customers.ContactName AS [Contact Name], 'Customer' AS [Type (Customer or Supplier)]
FROM dbo.Customers AS customers

UNION ALL 

SELECT suppliers.City AS City, suppliers.ContactName AS [Contact Name], 'Supplier' AS [Type (Customer or Supplier)]
FROM dbo.Suppliers AS suppliers
/*Name : Akshay Bhala
Suid: 434754362
netid: abhala@syr.edu*/
USE ist722_abhala_stage
;
--stage customers
select CustomerID,
		CompanyName,
		ContactName,
		Country,
		Region,
		City,
		PostalCode
Into stgnorthwindCustomer	
From Northwind.dbo.Customers

--stage Employee
select EmployeeID,
		FirstName,
		LastName,
		Title
Into stgnorthwindEmployee	
From Northwind.dbo.Employees

--stage products
select [ProductID]
	,[ProductName]
	,[Discontinued]
into stgnorthwindProduct
from Northwind.dbo.Products p
join [Northwind].[dbo].Suppliers s
		on p.[SupplierID]=s.[SupplierID]
	join [Northwind].[dbo].Categories c
		on c.[CategoryID]=p.CategoryID

--stage dates
select *
into stgNorthwindDates
from [ExternalSources2].[dbo].date_dimension
where Year between 1996 and 1998

--stage sales fact
select [ProductID]
	,d.[OrderID]
	,[CustomerID]
	,[EmployeeID]
	,[OrderDate]
	,[ShippedDate]
	,[UnitPrice]
	,[Quantity]
	,[Discount]
into [dbo].[stgNorthwindSales]
from [Northwind].[dbo].[Order Details] d
	join [Northwind].[dbo].[Orders] o
		on o.[OrderID]=d.[OrderID]

-- stage order fulfillment
select [OrderID],[OrderDate],[ShippedDate], DATEDIFF(DY,OrderDate,ShippedDate) delay

into [dbo].[stgNorthwindOrderFulfillment]
from [Northwind].[dbo].[Orders]

drop table dbo.stgNorthwindCustomer
drop table dbo.stgNorthwindDates
drop table dbo.stgNorthwindEmployee
drop table dbo.stgNorthwindProduct
drop table dbo.stgNorthwindSales
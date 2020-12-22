/*Name : Akshay Bhala
Suid: 434754362
netid: abhala@syr.edu*/

USE ist722_abhala_dw
;

--load DimEmployees
insert into [ist722_abhala_dw].[northwind].[DimEmployee]
											([EmployeeID],[FirstName], [LastName],[EmployeeTitle])
select EmployeeID, FirstName,LastName, Title
	from [ist722_abhala_stage].[dbo].[stgnorthwindEmployee]

select * from [northwind].[DimEmployee]

--load DimCustomer
insert into [ist722_abhala_dw].[northwind].[DimCustomer]
		([CustomerID],[CompanyName],[ContactName],
		[CustomerCountry],[CustomerRegion],[CustomerCity],[CustomerPostalCode])
select 
		[CustomerID],[CompanyName],[ContactName],[Country],
		case when [Region] is null then 'N/A' else [Region] end,
		[City],
		case when [PostalCode] is null then 'N/A' else [PostalCode] end
		from [ist722_abhala_stage].[dbo].[stgNorthwindCustomer];

select * from [northwind].[DimCustomer];


---load DimProduct
insert into [ist722_abhala_dw].[northwind].[DimProduct]
		([ProductID],[ProductName],[Discontinued])
select 
		[ProductID],[ProductName],[Discontinued]
		from [ist722_abhala_stage].[dbo].[stgNorthwindProduct];

Select * from [northwind].[DimProduct];

alter table northwind.DimDate alter column MonthofYear nvarchar(200) null 
--load DimDate
insert into northwind.DimDate
		([DateKey],[Date],[FullDateUSA],[DayOfWeek],[DayName],[DayOfMonth],[DayOfYear]
		,[WeekOfYear],[MonthName],[MonthOfYear],[Quarter],[QuarterName]
		,[Year],[IsWeekday])
select 
		[ExternalSources2].[dbo].[getDateKey]([Date]),
		[Date],[FullDateUSA],[DayOfWeekUSA],[DayName],[Month],[DayOfYear]
		,[WeekOfYear],[MonthName],[MonthYear],[Quarter],[QuarterName]
		,[Year],[IsWeekday]
		from [ist722_abhala_stage].[dbo].[stgNorthwindDates];

select * from northwind.DimDate;

select s.*,c.CustomerKey,e.EmployeeKey,p.ProductKey,
	[ExternalSources2].[dbo].[getDateKey](s.OrderDate) as OrderDateKey,
	[ExternalSources2].[dbo].[getDateKey](s.ShippedDate) as ShippedDateKey
from [ist722_abhala_stage].[dbo].[stgNorthwindSales] s
		join [ist722_abhala_dw].[northwind].DimCustomer c
			on s.CustomerID=c.CustomerID--match on business keys, not pk/fk
		join [ist722_abhala_dw].[northwind].DimEmployee e
			on s.EmployeeID=e.EmployeeID--match on business keys, not pk/fk
		join [ist722_abhala_dw].[northwind].DimProduct p
			on s.ProductID=p.ProductID--match on business keys, not pk/fk

--load FactSales

insert into [northwind].[FactSales]
		([ProductKey],[CustomerKey],[EmployeeKey]
		,[OrderDateKey]
		,[ShippedDateKey]
		,[OrderID]
		,[Quantity]
		,[ExtendedPriceAmount]
		,[DiscountAmount]
		,[SoldAmount])
select p.ProductKey, c.CustomerKey, e.EmployeeKey,
	[ExternalSources2].[dbo].[getDateKey](s.OrderDate) as OrderDateKey,
	case when [ExternalSources2].[dbo].[getDateKey](s.ShippedDate) is null then -1
	else [ExternalSources2].[dbo].[getDateKey](s.ShippedDate) end as ShippedDateKey,
	s.OrderID,
	Quantity,
	Quantity * UnitPrice as ExtendedPriceAmount,
	Quantity * UnitPrice * Discount as DiscountAmount,
	Quantity * UnitPrice * (1-Discount) as SoldAmount
from [ist722_abhala_stage].dbo.[stgNorthwindSales] s
	join [ist722_abhala_dw].[northwind].DimCustomer c
			on s.CustomerID=c.CustomerID
		join [ist722_abhala_dw].[northwind].DimEmployee e
			on s.EmployeeID=e.EmployeeID
		join [ist722_abhala_dw].[northwind].DimProduct p
			on s.ProductID=p.ProductID;
		


select * from  [northwind].[FactSales];

---load FactOrderFulfillment
insert into [northwind].[OrderFulfillmentFact] 
( [OrderID],[OrderDateKey]
 ,[ShipDateKey],[CountOrderDate],[CountShip Date],[Delay]
  )

SELECT b.OrderID, 

 [ExternalSources2].[dbo].[getDateKey](b.OrderDate) as OrderDateKey,

 case when [ExternalSources2].[dbo].[getDateKey](b.ShippedDate) is null then -1
 else [ExternalSources2].[dbo].[getDateKey](b.ShippedDate) end as ShipDateKey,

case when [ExternalSources2].[dbo].[getDateKey](b.OrderDate) is null then 0
 else 1 end as CountOrderDate, 

case when [ExternalSources2].[dbo].[getDateKey](b.ShippedDate) is null then 0
 else 1 end as CountShipDate, 

 case when (b.OrderDate) is null or (b.ShippedDate) is NULL then -1
 else DATEDIFF(day, b.OrderDate, b.ShippedDate ) end as [Delay]

 from  [ist722_abhala_stage].[dbo].[stgNorthwindOrderFulfillment] b

use ist722_abhala_dw

CREATE VIEW [northwind].[OrderMart]
AS
Select f.OrderID, OrderDateKey, ShipDateKey, CountOrderDate,[CountShip Date] ,[Delay]
from [northwind].[OrderFulfillmentFact] f

select * from northwind.OrderFulfillmentFacts



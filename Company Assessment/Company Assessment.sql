
--looks into items with the discontinued flag set to 1, nothing significant
select od.orderID, od.productID, o.orderDate, o.requiredDate, o.shippedDate, p.productName, p.discontinued
from order_details od
join orders o
on od.orderID = o.orderID
join products p
on od.productID = p.productID
where p.discontinued = 1

--Look at discontinued items which still have stock on hand, helpful to identify extra stock which may not be sold
select p.unitsInStock, p.unitsOnOrder, p.quantityPerUnit, p.discontinued, p.productName
from products p
where p.discontinued = 1
and unitsInStock > 0

--There are no units out of stock and not on order
select p.unitsInStock, p.unitsOnOrder, p.quantityPerUnit
from products p 
where p.discontinued = 0
and unitsInStock = 0
and unitsOnOrder = 0

--looks at orders details expanded, including category, product, employee, total price before discount, total price after discount
--going to use this for atleast a few visualizations, good base for future cte calculations
select od.*, c.categoryName, p.productName, c.picture, o.customerID, o.employeeID, (e.FirstName +' '+ e.LastName) as employee, 
(od.unitPrice*od.quantity) as preDiscount, ((od.unitPrice*od.quantity)*(1 - discount)) as totalOrder 
from order_details as od
join products p 
on p.productID = od.productID
join categories c
on c.categoryID = p.categoryID
join orders o 
on od.orderID = o.orderID
join Employees e
on e.employeeID = o.employeeID
;

--Sales split by categories, going to be used in Sales by Category Forecast visualization
with rollingSales(orderID, productID,quantity, unitPrice, discount, categoryName, productName, picture, customerID, employeeID, employee, 
	preDiscount, totalOrder,  orderDate)
as(
	select od.orderID, od.productID,od.quantity, od.unitPrice, od.discount, c.categoryName, p.productName, c.picture, o.customerID, o.employeeID, (e.FirstName +' '+ e.LastName) as employee, 
	(od.unitPrice*od.quantity) as preDiscount, ((od.unitPrice*od.quantity)*(1 - discount)) as totalOrder,  o.orderDate
	from order_details as od
	join products p 
	on p.productID = od.productID
	join categories c
	on c.categoryID = p.categoryID
	join orders o 
	on od.orderID = o.orderID
	join Employees e
	on e.employeeID = o.employeeID
)
select distinct orderDate, orderID, categoryName, (SUM(totalOrder) over (partition by categoryName order by orderID)) as rollingTotalSales 
from rollingSales
;


--Looks at how well each employee sells each category as a percent of total sales
with rollingSales2(orderID, productID,quantity, unitPrice, discount, categoryName, productName, picture, customerID, employeeID, employee, 
	preDiscount, totalOrder,  orderDate)
as(
	select od.orderID, od.productID,od.quantity, od.unitPrice, od.discount, c.categoryName, p.productName, c.picture, o.customerID, o.employeeID, (e.FirstName +' '+ e.LastName) as employee, 
	(od.unitPrice*od.quantity) as preDiscount, ((od.unitPrice*od.quantity)*(1 - discount)) as totalOrder,  o.orderDate
	from order_details as od
	join products p 
	on p.productID = od.productID
	join categories c
	on c.categoryID = p.categoryID
	join orders o 
	on od.orderID = o.orderID
	join Employees e
	on e.employeeID = o.employeeID
)
select distinct employee,categoryName, round((SUM(totalOrder) over (partition by employee, categoryName))*100/(SUM(totalOrder) over (partition by employee)),2) as rollingEmployeeSales,
round((SUM(totalOrder) over (partition by employee,categoryName)),2) as totalCategorySales
from rollingSales2
group by employee, categoryName, totalOrder
order by rollingEmployeeSales desc
;

with GlobalSales(orderID, productID, quantity, unitPrice, discount, categoryName, productName, customerID, employeeID, employee, 
	preDiscount, totalOrder,shipCountry)
as(
	select od.orderID, od.productID,od.quantity, od.unitPrice, od.discount, c.categoryName, p.productName, o.customerID, o.employeeID, (e.FirstName +' '+ e.LastName) as employee, 
	(od.unitPrice*od.quantity) as preDiscount, ((od.unitPrice*od.quantity)*(1 - discount)) as totalOrder, o.shipCountry
	from order_details as od
	join products p 
	on p.productID = od.productID
	join categories c
	on c.categoryID = p.categoryID
	join orders o 
	on od.orderID = o.orderID
	join Employees e
	on e.employeeID = o.employeeID
)
select distinct shipCountry, round((SUM(totalOrder) over (partition by shipCountry)),2) as saleByCountry
from GlobalSales 
group by shipCountry, totalOrder
;
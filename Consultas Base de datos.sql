/*a. Determinar el total de las ventas de los productos con la categoría que se provea
de argumento de entrada en la consulta, para cada uno de los territorios registrados en la base de datos.*/

/*b. Determinar el producto más solicitado para la región (atributo group de salesterritory) "North America"
y en que territorio de la región tiene mayor demanda.*/

/*c. Actualizar el stock disponible en un 5% de los productos de la categoría que se provea como argumento de entrada,
en una localidad que se provea como entrada en la instrucción de actualización.*/

/*d. Determinar si hay clientes que realizan ordenes en territorios diferentes al que se encuentran.*/

/*e. Actualizar la cantidad de productos de una orden que se provea como argumento en la instrucción de actualización.*/

/*f. Actualizar el método de envío de una orden que se reciba como argumento en la instrucción de actualización.*/

/*g. Actualizar el correo electrónico de una cliente que se reciba como argumento en la instrucción de actualización.*/

use AdventureWorks2019
go

/*a. Determinar el total de las ventas de los productos con la categoría que se provea
de argumento de entrada en la consulta, para cada uno de los territorios registrados en la base de datos.*/

create or alter procedure sp_Ejercicioa @cate int as
	begin
	select sum(Cantidades) as TotalVentas, N as Territorio, T as TerritorioID from
	(select B.SalesOrderID, sum(B.LineTotal) as Cantidades, E.Name N, E.TerritoryID T from 
	(select * from Sales.SalesOrderHeader) A
	inner join
	(select * from Sales.SalesOrderDetail) B
	on A.SalesOrderID = B.SalesOrderID
	inner join
	(select * from Production.Product) C
	on B.ProductID = C.ProductID
	inner join
	(select * from Production.ProductSubcategory where ProductCategoryID = @cate) D
	on C.ProductSubcategoryID = D.ProductSubcategoryID
	inner join
	(select * from Sales.SalesTerritory) E
	on A.TerritoryID = E.TerritoryID
	group by B.SalesOrderID, E.Name, E.TerritoryID) A
	group by A.N, A.T
	order by A.T
end
go

exec sp_Ejercicioa @cate = 1
go
go

/*b. Determinar el producto más solicitado para la región (atributo group de salesterritory) "North America"
y en que territorio de la región tiene mayor demanda.*/

create or alter procedure sp_Ejerciciob as
begin
	select top 1 D.Name as Producto, count(*) as Solicitudes, B.Name from
	(select * from Sales.SalesOrderHeader) A
	inner join
	(select *  from Sales.SalesTerritory where TerritoryID between '1' and '6') B
	on A.TerritoryID = B.TerritoryID
	inner join
	(select * from Sales.SalesOrderDetail) C
	on A.SalesOrderID = C.SalesOrderID
	inner join
	(select * from Production.Product) D
	on C.ProductID = D.ProductID
	group by D.Name, B.Name
	order by Solicitudes desc
end
go

exec sp_Ejerciciob
go

/*c. Actualizar el stock disponible en un 5% de los productos de la categoría que se provea como argumento de entrada,
en una localidad que se provea como entrada en la instrucción de actualización.*/

create or alter procedure sp_Ejercicioc @categ int, @LID int as
begin
	if not exists(select A.ProductID, B.Name, A.Quantity as Stock, A.LocationID from (
	(select * from Production.ProductInventory where LocationID = @LID) A
	inner join
	(select * from Production.Product) B
	on A.ProductID = B.ProductID
	inner join
	(select * from Production.ProductSubcategory where ProductCategoryID = @categ) C
	on C.ProductSubcategoryID = B.ProductSubcategoryID))
	begin
		print 'No existe dicha categoría en esa locación.'
	end
	else
	begin
		update Production.ProductInventory
		set Quantity = round(Quantity + Quantity*0.05,0)
		where LocationID = @LID and ProductID in (
		select B.ProductID from (
			(select * from Production.Product) B
			inner join
			(select * from Production.ProductSubcategory) C
			on B.ProductSubcategoryID = C.ProductSubcategoryID))
	end

end
go

exec sp_Ejercicioc @categ = 1, @LID = 60
go

/*d. Determinar si hay clientes que realizan ordenes en territorios diferentes al que se encuentran.*/

create or alter procedure sp_Ejerciciod as
begin
	select A.SalesOrderID as ID, A.TerritoryID as TerritorioPedido, C.TerritoryID as TerritorioMandado from (
	(select * from Sales.SalesOrderHeader) A
	inner join
	(select * from Person.Address) B
	on A.ShipToAddressID = B.AddressID
	inner join
	(select * from Person.StateProvince) C
	on B.StateProvinceID = C.StateProvinceID
	inner join
	(select * from Sales.SalesTerritory) D
	on C.TerritoryID = D.TerritoryID)
	where A.TerritoryID != C.TerritoryID
end
go

exec sp_Ejerciciod
go

/*e. Actualizar la cantidad de productos de una orden que se provea como argumento en la instrucción de actualización.*/

create or alter procedure sp_Ejercicioe @Id int, @PId int, @cant int as
begin
	if not exists (select * from Sales.SalesOrderDetail where SalesOrderID = @Id)
		print 'No existe dicha orden.'
	else 
	begin
		if not exists (select * from Sales.SalesOrderDetail where SalesOrderID = @Id and ProductID = @PId)
		print 'No hay dicho producto en esta orden.'
		else
		begin
			update Sales.SalesOrderDetail
			set OrderQty = @cant
			where ProductID = @PId and SalesOrderID = @Id
		end
	end
end
go

exec sp_Ejercicioe @Id = 43659, @PId = 776, @cant = 1
select * from Sales.SalesOrderHeader
go
/*f. Actualizar el método de envío de una orden que se reciba como argumento en la instrucción de actualización.*/


create or alter procedure sp_Ejerciciof @Ido int, @me int as
begin
	if not exists(select * from Sales.SalesOrderHeader where SalesOrderID = @Ido)
		print 'No existe dicha orden.'
	else
	begin
		update Sales.SalesOrderHeader
		set ShipMethodID = @me
		where SalesOrderID = @Ido
	end
end
go

exec sp_Ejerciciof @Ido = 3, @me = 1
go

/*g. Actualizar el correo electrónico de una cliente que se reciba como argumento en la instrucción de actualización.*/

create or alter procedure sp_Ejerciciog @idper int, @email nvarchar(200) as
begin
	if not exists( select * from 
		(select * from Person.BusinessEntityContact) A
		inner join
		(select * from Sales.Customer where CustomerID = @idper) B
		on A.PersonID = B.PersonID)
		print 'No existe dicho cliente'
	else
	begin
		update Person.EmailAddress
		set EmailAddress = @email
		where BusinessEntityID = (select B.BusinessEntityID from 
			(select * from Sales.Customer where CustomerID = @idper) A
			inner join
			(select * from Person.BusinessEntityContact) B
			on A.PersonID = B.PersonID
			)
	end
end
go

exec sp_Ejerciciog @idper = 18759, @email = 'AAAAA'
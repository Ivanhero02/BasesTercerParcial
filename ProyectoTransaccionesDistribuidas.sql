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

use AW_Sales
go

/*a. Determinar el total de las ventas de los productos con la categoría que se provea
de argumento de entrada en la consulta, para cada uno de los territorios registrados en la base de datos.*/
--No necesita Transacciones
create or alter procedure sp_Ejercicioa @cate int as
	begin
	select sum(Cantidades) as TotalVentas, N as Territorio, T as TerritorioID from
	(select B.SalesOrderID, sum(B.LineTotal) as Cantidades, E.Name N, E.TerritoryID T from 
	(select * from INSTANCIA1.AW_Sales.Sales.SalesOrderHeader) A
	inner join
	(select * from INSTANCIA1.AW_Sales.Sales.SalesOrderDetail) B
	on A.SalesOrderID = B.SalesOrderID
	inner join
	(select * from INSTANCIA3.AW_Production.Production.Product) C
	on B.ProductID = C.ProductID
	inner join
	(select * from INSTANCIA3.AW_Production.Production.ProductSubcategory where ProductCategoryID = @cate) D
	on C.ProductSubcategoryID = D.ProductSubcategoryID
	inner join
	(select * from INSTANCIA1.AW_Sales.Sales.SalesTerritory) E
	on A.TerritoryID = E.TerritoryID
	group by B.SalesOrderID, E.Name, E.TerritoryID) A
	group by A.N, A.T
	order by A.T
end
go

exec sp_Ejercicioa @cate = 1
go

/*b. Determinar el producto más solicitado para la región (atributo group de salesterritory) "North America"
y en que territorio de la región tiene mayor demanda.*/
--No necesita Transacciones
create or alter procedure sp_Ejerciciob as
begin
	select top 1 D.Name as Producto, count(*) as Solicitudes, B.Name from
	(select * from INSTANCIA1.AW_Sales.Sales.SalesOrderHeader) A
	inner join
	(select *  from INSTANCIA1.AW_Sales.Sales.SalesTerritory where TerritoryID between '1' and '6') B
	on A.TerritoryID = B.TerritoryID
	inner join
	(select * from INSTANCIA1.AW_Sales.Sales.SalesOrderDetail) C
	on A.SalesOrderID = C.SalesOrderID
	inner join
	(select * from INSTANCIA3.AW_Production.Production.Product) D
	on C.ProductID = D.ProductID
	group by D.Name, B.Name
	order by Solicitudes desc
end
go

exec sp_Ejerciciob
go

/*c. Actualizar el stock disponible en un 5% de los productos de la categoría que se provea como argumento de entrada,
en una localidad que se provea como entrada en la instrucción de actualización.*/
--Necesita Transacciones
create or alter procedure sp_Ejercicioc @categ int, @LID int as
begin
set XACT_ABORT on
	if not exists(select A.ProductID, B.Name, A.Quantity as Stock, A.LocationID from (
	(select * from INSTANCIA3.AW_Production.Production.ProductInventory where LocationID = @LID) A
	inner join
	(select * from INSTANCIA3.AW_Production.Production.Product) B
	on A.ProductID = B.ProductID
	inner join
	(select * from INSTANCIA3.AW_Production.Production.ProductSubcategory where ProductCategoryID = @categ) C
	on C.ProductSubcategoryID = B.ProductSubcategoryID))
	begin
		print 'No existe dicha categoría en esa locación.'
	end
	else
	begin
		begin tran TC
			begin try
				update INSTANCIA3.AW_Production.Production.ProductInventory
				set Quantity = round(Quantity + Quantity*0.05,0)
				where LocationID = @LID and ProductID in (
				select B.ProductID from (
					(select * from INSTANCIA3.AW_Production.Production.Product) B
					inner join
					(select * from INSTANCIA3.AW_Production.Production.ProductSubcategory where ProductCategoryID = @categ) C
					on B.ProductSubcategoryID = C.ProductSubcategoryID))
					commit tran TC
				end try
				begin catch
					rollback tran TC
				end catch
	end
end
go

exec sp_Ejercicioc @categ = 1, @LID = 60
select * from INSTANCIA3.AW_Production.Production.ProductInventory where LocationID = 60 and ProductID in (
				select B.ProductID from (
					(select * from INSTANCIA3.AW_Production.Production.Product) B
					inner join
					(select * from INSTANCIA3.AW_Production.Production.ProductSubcategory where ProductCategoryID = 1) C
					on B.ProductSubcategoryID = C.ProductSubcategoryID))
go

/*d. Determinar si hay clientes que realizan ordenes en territorios diferentes al que se encuentran.*/
--No necesita Transacciones
create or alter procedure sp_Ejerciciod as
begin
	select A.SalesOrderID as ID, A.TerritoryID as TerritorioPedido, C.TerritoryID as TerritorioMandado from (
	(select * from INSTANCIA1.AW_Sales.Sales.SalesOrderHeader) A
	inner join
	(select * from openquery(INSTANCIA2, 'select * from AW_Person.Person.Address' )) B
	on A.ShipToAddressID = B.AddressID
	inner join
	(select * from INSTANCIA2.AW_Person.Person.StateProvince) C
	on B.StateProvinceID = C.StateProvinceID
	inner join
	(select * from INSTANCIA1.AW_Sales.Sales.SalesTerritory) D
	on C.TerritoryID = D.TerritoryID)
	where A.TerritoryID != C.TerritoryID
end
go

exec sp_Ejerciciod
go

/*e. Actualizar la cantidad de productos de una orden que se provea como argumento en la instrucción de actualización.*/
--Necesita Transacciones
create or alter procedure sp_Ejercicioe @Id int, @PId int, @cant int as
begin
set XACT_ABORT on
	if not exists (select * from INSTANCIA1.AW_Sales.Sales.SalesOrderDetail where SalesOrderID = @Id)
		print 'No existe dicha orden.'
	else 
	begin
		if not exists (select * from INSTANCIA1.AW_Sales.Sales.SalesOrderDetail where SalesOrderID = @Id and ProductID = @PId)
		print 'No hay dicho producto en esta orden.'
		else
		begin
			begin tran
				update INSTANCIA1.AW_Sales.Sales.SalesOrderDetail
				set OrderQty = @cant
				where ProductID = @PId and SalesOrderID = @Id
			commit tran
		end
	end
end
go

exec sp_Ejercicioe @Id = 43659, @PId = 776, @cant = 100
select * from INSTANCIA1.AW_Sales.Sales.SalesOrderDetail where SalesOrderID = 43659
go
/*f. Actualizar el método de envío de una orden que se reciba como argumento en la instrucción de actualización.*/
--Necesita Transacciones

create or alter procedure sp_Ejerciciof @Ido int, @me int as
begin
set XACT_ABORT on
	if not exists(select * from INSTANCIA1.AW_Sales.Sales.SalesOrderHeader where SalesOrderID = @Ido)
		print 'No existe dicha orden.'
	else
	begin
	
		begin tran TF
			begin try
				if(@me in (select ShipMethodID from INSTANCIA2.AW_Person.Purchasing.ShipMethod))
					begin
						update INSTANCIA1.AW_Sales.Sales.SalesOrderHeader
						set ShipMethodID = @me
						where SalesOrderID = @Ido
						commit tran TF
					end
				else
					begin
						print 'Mal parámetro, papito'
						rollback tran TF
					end
			end try
			begin catch
				print 'Ocurrió un error, papito'
				rollback tran TF
			end catch
	end
end
go

exec sp_Ejerciciof @Ido = 43659, @me = 5
select ShipMethodID  from INSTANCIA1.AW_Sales.Sales.SalesOrderHeader where SalesOrderID = 43659
go

/*g. Actualizar el correo electrónico de una cliente que se reciba como argumento en la instrucción de actualización.*/
--Necesita Transacciones
create or alter procedure sp_Ejerciciog @idper int, @email nvarchar(200) as
begin
set XACT_ABORT on
		if not exists( select * from 
			(select * from INSTANCIA2.AW_Person.Person.BusinessEntityContact) A
			inner join
			(select * from INSTANCIA1.AW_Sales.Sales.Customer where CustomerID = @idper) B
			on A.PersonID = B.PersonID)
				print 'No existe dicho cliente'
		else
		begin
			begin tran TG
				begin try
					update INSTANCIA2.AW_Person.Person.EmailAddress
					set EmailAddress = @email
					where BusinessEntityID = (select B.BusinessEntityID from 
						(select * from INSTANCIA1.AW_Sales.Sales.Customer where CustomerID = @idper) A
						inner join
						(select * from INSTANCIA2.AW_Person.Person.BusinessEntityContact) B
						on A.PersonID = B.PersonID
						)
				commit tran TG
				end try
				begin catch
					rollback tran TG
				end catch
		end
end
go

exec sp_Ejerciciog @idper = 18759, @email = 'AAAAA'

/*
------------------------------------CONCLUSIÓN:------------------------------------
Para hacer este último proyecto primero analizamos todas las consultas que ya
teníamos del proyecto pasado para poder determinar cuáles de ellas necesitaban
estar metidas en una transacción explícita. Recordemos que cualquier tipo de 
lectura o acceso a datos es una transacción como tal, sin tener que haber
escrito el 'begin transaction'. Sin embargo para este caso, solamente aquellas
consultas en las que estábamos modificando, ingresando o eliminando valores
a las tablas fueron aquellas a las que le agregamos las transacciones explícitas.

Tras ello empezamos a hacer las pruebas correspondientes, pero el primer problema
que nos encontramos empezó porque todas las pruebas las hacíamos con Microsoft
Azure, utilizando una base de datos remota y ejecutando todo ahí. Pero en Azure
nos fue imposible ejecutarlas y que procedieran, ya que nosotros al tener el plan 
estudiantil solo nos es posible crear los servidores, pero no modificarlos al 
grado de transaccion, ya que esto solo se permite utilizando una instancia simulada
por parte mismo de Azure, y que para poder a acceder a este tipo de funcionalidad 
se necesita un plan de pago mayor al que nosotros tenemos de igual forma para poder 
acceder al MSDTC que no permite el funcionamiento entre SQLServer y Azure. 

por lo que tuvimos que cambiar el trayecto.

Ahí empezamos a hacer pruebas en las computadoras de la escuela utilizando la
red local para hacer las transacciones distribuidas, pero tuvimos problemas:
primero teníamos que acceder a los permisos de DTC y MSDTC para poder acceder
remotamente y ejecutar transacciones distribuidas. Sin embargo, tras haber hecho
esto en todas las computadoras necesarias para su ejecución seguía sin funcionar.
Ahí el profesor mencionó que podría ser el problema de las NAT y los puertos
necesarios podrían estar bloqueados para poder hacer los accesos para las
transacciones. Y por último llegamos al último intento que sí funcionó, que fue
usar dos servidores de bases de datos en un equipo local.

Teniendo dos servidores de SQL Server en la computadora #15 del laboratorio de
Telemática II pudimos hacer las transacciones distribuidas con el código 
anteriormente. También tuvimos que poner explícitamente la instrucción
'SET XACT_ABORT ON' para su funcionamiento, esto es porque normalmente se
encuentra apagado, lo que hace que no se puedan hacer transacciones anidadas
en los proveedores para los servidores vinculados, de esto tenemos la hipótesis
de que sucede porque estamos creando la transacción explícita inclusive si está
una transacción implícita ahí, por lo que serían unas transacciones anidadas, y
usando entonces la instrucción permite que se ejecuten las transacciones
distribuidas.
*/
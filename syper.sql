
/* subqueries */

	select ProductId 
	from CartProducts 
	where CartId = (select CartId from Customer where CustomerID = 5) 

	/*print package products*/
	SELECT * from Product 
	where ProductId in (select ProductId from PackageProducts WHERE PackagetId = 5)

	select sum(price) from Product 
	where ProductId in 
	(select ProductId from PackageProducts where PackagetId = 1)
	
	select count(ProductId) from Product 
	where ProductId in 
	(select ProductId from PackageProducts where PackagetId = 1)
 

/* subqueries */






/* VIEW */

	create view avrage_customer_purches
	as 
	select CustomerID,AVG(FinalPrice)as avg from Invoice group by CustomerID

	select * from avrage_customer_purches

	create view max_customer_purches
	as 
	select CustomerID,max(FinalPrice)as max from Invoice group by CustomerID

	create view package_products_count
	as 
	select Package.PackagetId, count(PackageProducts.ProductId) as 'Number of producs' 
	from Package 
	join PackageProducts 
	on PackageProducts.PackagetId = Package.PackagetId group by Package.PackagetId

	create view Company_sold_producs_count
	as 
	select Company.CompanyName ,count(InvoiceProducts.ProductId)as 'Sold Products' 
	from InvoiceProducts 
	join Product 
	on InvoiceProducts.ProductId = Product.ProductId 
	join Company 
	on  Product.CompanyId = Company.CompanyId group by Company.CompanyName

	select * from Company_sold_producs_count

/* END VIEW */



	/*-move product from cart to invoice--*/
	BEGIN TRANSACTION 
	exec insert_into_invoice 1,'ahmed' ,'libya co','new upgrade','discription', 0
	delete from CartProducts where CartId = [dbo].[getCartId](1)
	EXEC setCartProCount
	commit



/* PROCEDURE */

	/* add package to cart */ 
	create procedure addPackageToCart @CustomerID int,@PackageId int
	as
	begin
	if EXISTS(select * from Cart where CustomerID = @CustomerID)
	begin 
	insert into CartProducts(CartId,ProductId) 
	select (select CartID from Cart where CustomerID = @CustomerID),ProductId from PackageProducts where PackagetId = @PackageId
	update Cart set ProductCount = (select ProductCount from Cart where CustomerID = @CustomerID) +(select count(ProductId) from Product where ProductId in (select ProductId from PackageProducts where PackagetId = @PackageId)) where CustomerID = @CustomerID
	update Cart set TotalPrice = (select TotalPrice from Cart where CustomerID = @CustomerID) + (select sum(price) from Product where ProductId in (select ProductId from PackageProducts where PackagetId = @PackageId)) where CustomerID =@CustomerID
	end
	else 
	begin
	insert into Cart (CustomerID, ProductCount,TotalPrice,Discount) 
	values (@CustomerID,(select count(ProductId) from Product where ProductId in (select ProductId from PackageProducts where PackagetId = @PackageId)),(select sum(price) from Product where ProductId in (select ProductId from PackageProducts where PackagetId = @PackageId)),(select Discount from Package where PackagetId = @PackageId))
	insert into CartProducts(CartId,ProductId) 
	select (select CartID from Cart where CustomerID = @CustomerID),ProductId from PackageProducts where PackagetId = @PackageId
	end
	end

	/* add product to cart */ 
	create procedure addProToCart @CustomerID int,@ProductId int
	as
	begin
	if EXISTS(select * from Cart where CustomerID = @CustomerID)
	begin 
	insert into CartProducts(CartId,ProductId)
	values 
	((select CartID from Cart where CustomerID = @CustomerID),@ProductId)
	update Cart set ProductCount = (select ProductCount from Cart where CustomerID = @CustomerID) + 1 where CustomerID = @CustomerID
	update Cart set TotalPrice = (select TotalPrice from Cart where CustomerID = @CustomerID) + (select Price from Product where ProductId = @ProductId) where CustomerID =@CustomerID
	end
	else 
	begin
	insert into Cart (CustomerID, ProductCount,TotalPrice,Discount) 
	values (@CustomerID,1,(select Price from Product where ProductId = @ProductId),0)
	insert into CartProducts(CartId,ProductId)
	values 
	((select CartID from Cart where CartID = (SELECT @@IDENTITY)),@ProductId)
	end
	end

	create proc setInvoicetPrice
	as
	begin
	declare @InvoiceID int = 0
	declare @rowcount int 
	SELECT @rowcount = count(InvoiceID) FROM Invoice
	while @rowcount >0 
	begin
	update Invoice 
	set Price = (SELECT sum(Price) from [dbo].Invoice where InvoiceID in (SELECT InvoiceID FROM InvoiceProducts where InvoiceID = 2)) 
	where InvoiceID = @InvoiceID;
	set @InvoiceID = @InvoiceID +1
	set @rowcount = @rowcount -1
	end
	end
	exec setCartTotalPrice
	
	create proc setCartTotalPrice
	as
	begin
	declare @CartID int = 1
	declare @rowcount int 
	SELECT @rowcount = count(CartID) FROM Cart
	while @rowcount >0 
	begin
	update Cart 
	set TotalPrice = (SELECT sum(price) from [dbo].[Product] where ProductId in (SELECT ProductId FROM CartProducts where CartId = @CartID)) 
	where CartID = @CartID;
	set @CartID = @CartID +1
	set @rowcount = @rowcount -1
	end
	end
	exec setCartTotalPrice

	create proc setInvouceProCount
	as
	begin
	declare @InvoiceID int = 1
	declare @rowcount int 
	SELECT @rowcount = count(InvoiceID) FROM Invoice
	while @rowcount >0 
	begin
	update Invoice 
	set ProductCount = (SELECT [dbo].[getInvoiceProductsCount](@InvoiceID)) 
	where InvoiceID = @InvoiceID;
	set @InvoiceID = @InvoiceID +1
	set @rowcount = @rowcount -1
	end
	end

	create proc setCartProCount
	as
	begin
	declare @CartID int = 1
	declare @rowcount int 
	SELECT @rowcount = count(CartID) FROM Cart
	while @rowcount >0 
	begin
	update Cart 
	set ProductCount = (SELECT [dbo].[getCartProductsCount](@CartID)) 
	where CartID = @CartID;
	set @CartID = @CartID +1
	set @rowcount = @rowcount -1
	end
	end
	EXEC setCartProCount


	/* move products from package to cart */ 
	create proc pay_package (@packageid int)
	as 
	begin
	begin TRY
	insert into CartProducts(ProductId)
	select ProductId 
	from PackageProducts 
	where PackagetId = @packageid
	END TRY  
	BEGIN CATCH  
	   print 'inserting error'  
	END CATCH; 
	end

	/* upgrade customer to elite*/

	create proc upgrade_customer (@message varchar out)
	as
	begin
	declare @CustomerID int 
	declare @row_count int 
	select @row_count = CustomerID from Customer
	while @row_count > 0
	begin
	select @CustomerID = CustomerID from Invoice group by CustomerID having count(InvoiceID)>5 and CustomerID in(select CustomerID from Customer where State = 'Basic')
	if @CustomerID <> null
	begin
	update Customer set State = 'Elite' where CustomerID = @CustomerID
	set @message =CONCAT( 'customer ', @CustomerID,' has been update')
	end
	else
	break
	end
	end 


	create proc insert_into_invoice  
	(@CustomerID int, @issure varchar,@receiver varchar,@title varchar, @discription varchar, @discount smallmoney)
	as
	begin
	BEGIN TRY  
	INSERT INTO Invoice (CustomerID, IssuedDate, Issuer,Receiver,Title,Discription,ProductCount,Price,Discount,FinalPrice )
	VALUES (@CustomerID, GETDATE(), @issure,@receiver,@title, @discription,[dbo].[productCartCount](@CustomerID),[dbo].[productCartFinalPrice](@CustomerID), @discount, ([dbo].[productCartFinalPrice](@CustomerID)) -@discount ); 
	END TRY  
	BEGIN CATCH  
	   print 'inserting error'  
	END CATCH;  
	BEGIN TRY  
	insert into InvoiceProducts(ProductId)
	select ProductId 
	from CartProducts 
	where CartId = [dbo].[getCartId](@CustomerID)
	END TRY  
	BEGIN CATCH  
	   print 'inserting error'  
	END CATCH; 
	end

	DECLARE @messagee varchar;

	EXEC upgrade_customer @message = @messagee OUTPUT;
	SELECT @messagee AS	Message;

/* END PROCEDURE */



/* FUNCTIONS */


	create function getInvoiceProductsCount(@InvoiceId int)
	returns int
	as
	begin
	declare @count int
	SELECT @count = count(InvoiceProducts) FROM InvoiceProducts where InvoiceId = @InvoiceId
	return @count
	end

	create function getCartProductsCount(@CartId int)
	returns int
	as
	begin
	declare @count int
	SELECT @count = count(CartProductstId) FROM CartProducts where CartId = @CartId
	return @count
	end

	create function getCartId(@CustomerID as int)
	returns int
	as
	begin
	declare @CartId as int
	set @CartId = (select CartId from Cart where CustomerID = @CustomerID) 
	return @CartId;
	end

	select [dbo].[getCartId](6)

	create function productCartCount(@CustomerID as int)
	returns int
	as
	begin
	declare @Count as int
	set @Count = (select count(ProductId) AS Count from CartProducts where CartId =  [dbo].[getCartId](@CustomerID)) 
	return @Count;
	end

	select [dbo].[productCartCount](6)

	create function productCartFinalPrice(@CustomerID as int)
	returns money
	as
	begin
	declare @sum as money
	set @sum = (select sum(Price)- sum(Discount) from Product where ProductId in (select ProductId from CartProducts where CartId =  [dbo].[getCartId](4)))
	return @sum;
	end

	select [dbo].[productCartFinalPrice](6)

	/* GET PACKAGE COST*/
	create function get_package_cost (@package_id as int)
	returns money
	as
	begin
	declare @sum as money
	select @sum = sum(Price)  from Product 
	join PackageProducts on PackageProducts.ProductId = Product.ProductId
	where PackagetId =  @package_id
	return @sum
	end

	select [dbo].[get_package_cost](6)


	/* get Company Product Count */
	CREATE FUNCTION getCompanyProductCount()
	RETURNS TABLE
	AS
	RETURN
	SELECT Company.CompanyName,COUNT(ProductId) as 'Number of product' 
	from Product join Company 
	on Company.CompanyId = Product.CompanyId group by Company.CompanyName

/* END FUNCTIONS */


/* CURSOR */
	DECLARE showSchedule CURSOR SCROLL FOR SELECT * FROM [dbo].[CartProducts]
 
	 OPEN showSchedule
 
	FETCH FIRST FROM showSchedule
	FETCH LAST FROM showSchedule
	FETCH NEXT FROM showSchedule 
	FETCH ABSOLUTE 7 FROM showSchedule
	FETCH RELATIVE 2 FROM showSchedule

	CLOSE showSchedule

	DEALLOCATE showSchedule
/* END CURSOR */

/* TRIGGERS */

	CREATE TABLE TableLog(
	LogID INT IDENTITY(1,1) PRIMARY KEY,
	EventVal XML NOT NULL,
	EventDate DATETIME NOT NULL,
	ChangedBy SYSNAME NOT NULL );


	CREATE TRIGGER trgTablechanges
	ON DATABASE
	after CREATE_TABLE, ALTER_TABLE, DROP_TABLE
	AS
	BEGIN
	INSERT INTO TableLog ( EventVal, EventDate, ChangedBy )
	VALUES ( EVENTDATA(), GETDATE(), USER ); 
	END;


	CREATE TRIGGER trgTablechanges
	ON DATABASE
	after CREATE_TABLE, ALTER_TABLE, DROP_TABLE
	AS
	BEGIN
	INSERT INTO TableLog ( EventVal, EventDate, ChangedBy )
	VALUES ( EVENTDATA(), GETDATE(), USER ); 
	END;

	SET IDENTITY_INSERT invoicelog ON
	CREATE TABLE invoicelog (
	CusID INT IDENTITY(1,1) NOT NULL,
	Operation VARCHAR(10) NOT NULL,
	InsertDate DATETIME NOT NULL );

	CREATE TRIGGER trgEmployeeInsert
	ON invoice
	after INSERT
	AS
	BEGIN
	INSERT INTO invoicelog(CusID, Operation, InsertDate)
	SELECT CustomerID,'INSERT', GETDATE()
	FROM INSERTED
	END

	CREATE TRIGGER trgEmployeeUpdate
	ON invoice
	after update
	AS
	BEGIN
	INSERT INTO invoicelog(CusID, Operation, InsertDate)
	SELECT CustomerID,'Update', GETDATE()
	FROM INSERTED
	END

	CREATE TRIGGER trgEmployeeDelete
	ON invoice
	after Delete
	AS
	BEGIN
	INSERT INTO invoicelog(CusID, Operation, InsertDate)
	SELECT CustomerID,'Delete', GETDATE()
	FROM INSERTED
	END

/* END TRIGGER */

/* INDEX */

	CREATE INDEX CIX_Product_CUSId
	ON Product(Productid ASC, Price DESC)

	CREATE INDEX NCI_InvoiceProducts_ProductId
	ON InvoiceProducts(ProductId);

/* END INDEX */

/* TEMP TALBLE */
	CREATE TABLE #topCompany(
	CompanyId  int IDENTITY(1,1) PRIMARY KEY,
	ProductSold int not null);
/* END TEMP TALBLE */

/* USER */
	CREATE LOGIN abdulalim
	WITH PASSWORD = '1234'

	CREATE USER elmuzoghi FROM LOGIN abdulalim

	grant delete on [dbo].[Invoice] to elmuzoghi WITH GRANT OPTION ;
	grant delete on [dbo].[PackageProducts] to elmuzoghi WITH GRANT OPTION ;

/* END USER */
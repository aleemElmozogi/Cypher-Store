create database Syper;

create table Customer(
CustomerID int IDENTITY(1,1) PRIMARY KEY,
FirstName varchar(20)  not null,
LastName varchar(20)  not null,
City varchar(15) default null,
Address varchar(255) default null,
Role varchar(15)  not null,
State  varchar(15)  not null,
Email varchar(70)  not null,
Password varchar(35) not null,
ProfileImg image
); 


create table Cart (
CartID int IDENTITY(1,1) PRIMARY KEY,
CustomerID int not null ,
ProductCount tinyint default 0,
TotalPrice smallmoney default 0,
Discount smallmoney default 0
);
ALTER TABLE Cart
ADD CONSTRAINT FK_CartCustomerID
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) on delete cascade;
ALTER TABLE Cart ADD CONSTRAINT Uniqe_CustomerID UNIQUE(CustomerID)


create table Invoice (
InvoiceID int IDENTITY(1,1) PRIMARY KEY,
CustomerID int ,
IssuedDate DATETIME default GETDATE(),
Issuer VARCHAR(25) Default null,
Receiver VARCHAR(25) Default null,
Title VARCHAR(25) Default null,
Discription VARCHAR(200) Default null,
ProductCount tinyint default 0,
Price smallmoney default 0,
Discount smallmoney default 0,
FinalPrice smallmoney default 0
);

ALTER TABLE Invoice
ADD CONSTRAINT FK_InvoiceCustomerID
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
 on delete set null;

 
create table Company(
CompanyId  int IDENTITY(1,1) PRIMARY KEY,
CompanyName  varchar(50)  not null,
Discription  VARCHAR(200) not null,
CompanyLogo Image  default null
);


create table Catagory(
CatagoryID int IDENTITY(1,1) PRIMARY KEY,
CatagoryName varchar(10) not null,
CatagoryIcon Image  default null
);


create table Product(
ProductId  int IDENTITY(1,1) PRIMARY KEY,
ProductName varchar(50) not null,
CompanyId int ,
CatagoryID int,
Discription  VARCHAR(500) not null,
Price smallmoney default 0,
Discount smallmoney default 0,
ProductionYear  varchar(6) default null
);

ALTER TABLE Product
add CONSTRAINT FK_ProductCompanyId
FOREIGN KEY (CompanyId) REFERENCES Company(CompanyId) on delete Set Null;

ALTER TABLE Product
add CONSTRAINT FK_ProductCatagory
FOREIGN KEY (CatagoryID) REFERENCES Catagory(CatagoryID) on delete Set Null;

create table Package(
PackagetId  int IDENTITY(1,1) PRIMARY KEY,
PackageName varchar(50) not null,
Discription  VARCHAR(200) not null,
Price smallmoney default 0,
Discount smallmoney default 0,
);


create table PackageProducts(
PackageProductstId  int IDENTITY(1,1) PRIMARY KEY,
PackagetId int not null,
ProductId int not null
);

alter table PackageProducts add CONSTRAINT Packaget_fk
FOREIGN KEY (PackagetId) REFERENCES Package(PackagetId) on delete cascade ,
FOREIGN KEY (ProductId) REFERENCES Product(ProductId) on delete cascade


create table CartProducts(
CartProductstId  int IDENTITY(1,1) PRIMARY KEY,
CartId int not null,
ProductId int not null
);
alter table CartProducts add CONSTRAINT CartProducts_fk
FOREIGN KEY (CartId) REFERENCES Cart(CartID) on delete cascade,
FOREIGN KEY (ProductId) REFERENCES Product(ProductId) on delete cascade



create table InvoiceProducts(
InvoiceProducts  int IDENTITY(1,1) PRIMARY KEY,
InvoiceId int not null,
ProductId int not null,
);
alter table InvoiceProducts add CONSTRAINT InvoiceProducts_fk
FOREIGN KEY (InvoiceId) REFERENCES Invoice(InvoiceID) on delete cascade,
FOREIGN KEY (ProductId) REFERENCES Product(ProductId) on delete cascade


create table CustomerPhoneNumber(
CustomerId int not null,
PhoneNumber varchar(15) not null,
PRIMARY KEY (CustomerId,PhoneNumber),
);
alter table CustomerPhoneNumber add CONSTRAINT CustomerPhoneNumber_fk
FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) on delete cascade








create table ProductImage(
ID int,
ProductId int,
ProductImage Image  not null,
PRIMARY KEY (ID,ProductId),
);
alter table ProductImage add CONSTRAINT ProductImage_fk
FOREIGN KEY (ProductId) REFERENCES Product(ProductId) on delete cascade


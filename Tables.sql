create database FactoryManagement

---------- WORKERS Sections -------
-------------------------------------

CREATE TABLE WORKER
(
	WID INT IDENTITY(1,1),
	WorkerID AS 'WID' + RIGHT('00000000' + CAST(WID AS VARCHAR(8)), 8) PERSISTED,
	WorkerName varchar(50) Not Null,
	Balance int default 0 not Null,
	PhoneNo varChar(20) Null,
	cnic int not null,
	--ShiftPeriod varChar(20) DEFAULT NULL,
	Adress varchar(50) Default Null,
	Status bit default 1,
	createdTime varchar(30) default CONVERT(varchar(15),  CAST(GETDATE() AS TIME), 100),
	createdDate date default convert(date, getDate()),
	Constraint WORKER_pk PRIMARY KEY (WID),
	CONSTRAINT CHK_Balance CHECK (Balance>=0)
)

---------------------------------------------------------------
---------------------- WORK_DONE SECTION ----------------------


CREATE TABLE WORK_DONE
(
	WID INT,
	createdDate date default convert(date, getDate()),
	Daily_Payment int not Null,
	detail varChar(100) Null,
	createdTime varchar(30) default CONVERT(varchar(15),  CAST(GETDATE() AS TIME), 100),
	createdAt date default getDate(),
	Constraint WORK_DONE_pk PRIMARY KEY (createdDate,WID),
	Constraint WORK_DONE_fk foreign key (WID) references WORKER(WID) on update cascade on delete cascade
) 

-----------------------------------------------------------------
---------------------- WORKER BALANCE WITHDRAW SECTION ----------------------
-----------------------------------------------------------------------
CREATE TABLE BALANCE_WITHDRAW
(
	WID INT,
	createdDate date default convert(date, getDate()),
	amount int default 0,
	createdTime varchar(30) default CONVERT(varchar(15),  CAST(GETDATE() AS TIME), 100),
	createdAt date default getDate(),
	Constraint BALANCE_WITHDRAW_pk PRIMARY KEY (createdDate,WID),
	Constraint BALANCE_WITHDRAW_fk foreign key (WID) references WORKER(WID) on update cascade on delete cascade
) 

---------------------------------------------------------------
---------------------STOCK SECTION -------------------------


create table STOCK
(
	itemId int identity(1,1),
	itemName varchar(30) ,
	qty float ,
	unit varchar(10),
	pricePerUnit FLOAT,
	active bit default 1,
	Constraint STOCK_pk Primary key (itemId),
	--Constraint STOCK_ChkQty Check(qty >0),
	Constraint STOCK_ChkPrice Check(pricePerUnit > 0)
)

---------------------------------------------
-------------PURCHASE TABLE---------------------------------
---------------------------------------------

create table  PURCHASE_STOCK
(
	itemId int,
	createdTime time default convert(time, getDate()),
	createdDate date default convert(date, getDate()),
	qty float,
	pricePerUnit FLOAT ,
	purchaseFrom varchar(30) default 'Not Provided',
	pType varchar(30) , --add or utilized
	--pAddress varchar(50) default 'Not Provided',
	--phoneNo varchar(30) default 'Not Provided',
	--comment varchar(100) default '',
	Constraint PURCHASE_STOCK_pk Primary key (itemId,createdTime,createdDate) ,
	Constraint STOCK_fk foreign key (itemId) references STOCK(itemId) on update cascade ,
	--Constraint PURCHASE_STOCK_ChkQty Check(qty >0),
	Constraint PURCHASE_STOCK_ChkPrice Check(pricePerUnit > 0),
)

------------------------------------------------------
---------------------------SETTING TABLE------------------

create table setting 
(
	id int,
	mode varChar(30),
	password varBinary(1000) Not Null,
	status bit default 1,
	constraint setting_pk primary key (id)
)


----------------------INSERT SETTING PROC-------------------------

create procedure insertSystemUser @id int,@mode varchar(30),@pw varchar(30)
as
insert into setting (id,mode,password)
values (@id,@mode,CONVERT(varbinary,@pw))


----------------------REMOVE SETTING ORIC------------------------

create procedure removeSystemUser @id int
as
update setting
set status=0
where id = @id

----------------------------------------------------------------
--------------------------AUTHENTICATION POROC----------------------------

create procedure checkAuthUser @id int,@pw varchar(30)
as
select id
from setting 
where id=@id and password = CONVERT(varbinary,@pw) and status=1 and mode='user'




													exec insertSystemUser 777,'admin','ntu'
													exec insertSystemUser 111,'user','haris'

													exec checkAuthUser 111,'haris'

---------------------------------------------------------------------------
-------------------------------Sales Table--------------------------------------
CREATE TABLE SALES
(
	saleId int identity(1,1),
	saleTime time default convert(time, getDate()),
	saleDate date default convert(date, getDate()),
	itemName VARCHAR(60) NOT  NULL,
	quantity INT NOT NULL,
	buyerName VARCHAR(60) NOT NULL,
	price INT NOT NULL,
	delivered INT,
	remaining INT,
	constraint sale_pk primary key (saleId)
)

CREATE PROCEDURE addSales @name varchar(60), @quantity int, @buyer varchar(60), @price int
AS
INSERT INTO SALES (itemName, quantity, buyerName, price)
VALUES (@name,@quantity,@buyer, @price)

																												--exec addSales 'haris',12,'ak mill',12000

---------------------------------------
-------------SHOW WORKER VIEW-------------

Create view WORKERS_VIEW
AS select *
FROM WORKER


-------------ADD WORKER PROCEDURE -------------

CREATE PROCEDURE addWorker @name  varChar(50), @phone varchar(20),@cnic int, @address  varChar(50)
AS
INSERT INTO WORKER (WorkerName,PhoneNo,cnic,Adress)
VALUES (@name,@phone,@cnic,@address) 

--																		EXEC addWorker 'Farhan','111111',33100,'FSD'

-----------------UPDATE WORKER (DETAILS) PROCEDURE -------------


CREATE PROCEDURE updateWorker @id int, @name  varchar(50),@PhoneNo varChar(20),@Address varchar(50)
AS
update WORKER
set WorkerName= @name,PhoneNo= @PhoneNo,Adress=@Address
where WID= @id

--																		EXEC updateWorker 29,'Mesum Rizvi','66666','Lahore'


--------------------------------------------------
---------UPDATE WORKER (BALANCE) PROCEDURE-----------

CREATE PROCEDURE updateWorkBalance  @wID  int,@payment int
AS
update WORKER
set Balance= Balance+@payment
where WID= @wID

--																		EXEC updateWorkBalance 30,30

--------------------------------------------------------------------------
------------REMOVE WORKER PROCEDURE (ONLY CHANGE STATUS TRUE/FALSE)-------------
CREATE PROCEDURE changeStatusWorker @id int, @value  bit
AS
update WORKER
set Status= @value
where WID= @id

																		--EXEC changeStatusWorker 29,0
----------------ADD WORK_DONE PROCEDURE---------------

CREATE PROCEDURE addWorkDone @wID  int, @payment int, @detail  varChar(50)
AS
INSERT INTO WORK_DONE (WID,Daily_Payment,detail)
VALUES (@wID,@payment,@detail) ;

------------------------------------------------------


----------------ADD BALANCE_WITHDRAW PROCEDURE---------------

CREATE PROCEDURE newWithdraw @wID  int, @amount int
AS
declare @checkBalance int;
select @checkBalance = Balance
from WORKER where WID = @wID
IF (@amount <= @checkBalance)
BEGIN
	INSERT INTO BALANCE_WITHDRAW (WID,amount)
	VALUES (@wID,@amount) 
	update WORKER
	set Balance= Balance-@amount
	where WID= @wID
END


/*
CREATEdrop PROCEDURE newWithdraw @wID  int, @amount int
AS
INSERT INTO BALANCE_WITHDRAW (WID,amount)
VALUES (@wID,@amount) */
------------------------------------------------------



------------- get list of daily wages(work done)----------
Create view DAILY_WAGES_VIEW
AS
select W.WID,W.WorkerID,W.WorkerName,WD.Detail,WD.Daily_Payment,BW.amount,WD.createdDate,W.Balance
from WORKER W FULL OUTER JOIN WORK_DONE WD ON W.WID = WD.WID FULL OUTER JOIN BALANCE_WITHDRAW BW ON BW.WID= WD.WID 
WHERE W.Status = 1		

select WID,WorkerName,Detail,Daily_Payment,createdDate,Balance from DAILY_WAGES_VIEW where createdDate like '2019-11-%'


---------------------------- STOCK SECTION ------------------------
-------------- NEW STOCK ENTERED ----------

---- THIS IS FOR WHEN RECORD IS NOT CREATED BEFORE -----

CREATE PROCEDURE newStock @NAME VARCHAR(30),@QTY FLOAT, @UNIT VARCHAR(10),@PRICE FLOAT , @buyfrom Varchar(30)
as
INSERT INTO STOCK (itemName,qty,unit,pricePerUnit)
values (@NAME,@QTY,@UNIT,@PRICE)
declare @idOrig int;
select @idOrig=  IDENT_CURRENT( 'STOCK' );
insert into PURCHASE_STOCK (itemId,qty,pricePerUnit, pType , purchaseFrom)
values (@idOrig,@QTY,@PRICE,'add' , @buyfrom)


Create view stockPURCHASE_VIEW
AS
select PS.itemId, S.itemName,PS.qty ,PS.purchaseFrom,PS.pricePerUnit,pType,PS.createdDate
from PURCHASE_STOCK PS INNER JOIN STOCK S ON PS.itemId = S.itemId
WHERE active = 1

select  * from stockPURCHASE_VIEW where pType = 'add'


-----------------------------------------------
---- THIS IS FOR WHEN RECORD IS ALREADY CREATED BEFORE -----

create procedure newStockWithUpdate @id int,@QTY FLOAT, @UNIT VARCHAR(10),@PRICE FLOAT,
				@buyfrom varchar(30)
as
update STOCK
set qty+=@QTY,pricePerUnit=@PRICE
where itemId= @id

insert into PURCHASE_STOCK (itemId,qty,pricePerUnit,purchaseFrom,pType)
values (@id,@QTY,@PRICE,@buyfrom,'add')

exec newStockWithUpdate 1,10,'kg',1011,'intense'


-----------------------------------------------------------

create procedure checkBeforeUtilized @id int,@QTY FLOAT
as
select * 
from STOCK
where itemId= @id and @QTY <=qty
 
-----Utilized Stock item procedure-----
create procedure stockUtilized @id int,@QTY FLOAT
as
update STOCK
set qty= qty-@QTY
where itemId= @id
insert into PURCHASE_STOCK (itemId,qty,pType)
values (@id,@QTY,'utilized')

-------------------- TESTING QUERY --------------


----------------------------
---- DELETE THE STOCK -----

create procedure removeStock @id int 
as
update STOCK
set active= 0
where itemId= @id

---- update NAME OF STOCK ITEM-----

create procedure updateStockItemName @id int,@name varchar(30)
as
update STOCK
set itemName= @name
where itemId= @id


Create view STOCK_REPORT_VIEW
AS
select itemId,itemName,qty,pricePerUnit 
from STOCK
where active = 1


Create view PURCHASE_REPORT_VIEW
AS
select PS.itemId, S.itemName,PS.qty ,PS.purchaseFrom,createdDate,pType
from PURCHASE_STOCK PS INNER JOIN STOCK S ON PS.itemId = S.itemId
WHERE active = 1 

select * from PURCHASE_REPORT_VIEW where createdDate like '2019-10-%' or pType = 'add'

create view SALE_REPORT
as
select saleId,itemName,quantity,price,buyerName,saleDate
from SALES


select * from SALE_REPORT where saleDate like '2019-10-%'
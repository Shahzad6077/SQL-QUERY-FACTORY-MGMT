--create database FactoryManagement

---------- WORKERS Sections -------


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
Select * from WORKER

--- QUERY FOR ALTER TABLE AFTER CREATATION --------
/*
ALTER TABLE WORKER
ADD Balance int default 0 not null;
--QUERY FOR REMOVE ROWS FROM A TABLE (USE WHERE TO REMOVE SPECIFIC ROWS) ------------
DELETE FROM WORKER
*/

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


---------------------- WORKER BALANCE WITHDRAW SECTION ----------------------

CREATE TABLE BALANCE_WITHDRAW
(
	WID INT,
	createdDate date default convert(date, getDate()),
	amount int not Null,
	createdTime varchar(30) default CONVERT(varchar(15),  CAST(GETDATE() AS TIME), 100),
	createdAt date default getDate(),
	Constraint BALANCE_WITHDRAW_pk PRIMARY KEY (createdDate,WID),
	Constraint BALANCE_WITHDRAW_fk foreign key (WID) references WORKER(WID) on update cascade on delete cascade
) 


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
	Constraint STOCK_ChkQty Check(qty >0),
	Constraint STOCK_ChkPrice Check(pricePerUnit > 0)
)

	

create table PURCHASE_STOCK
(
	itemId int,
	createdTime time default convert(time, getDate()),
	createdDate date default convert(date, getDate()),
	qty float,
	pricePerUnit FLOAT ,
	purchaseFrom varchar(30) default 'Not Provided',
	pAddress varchar(50) default 'Not Provided',
	phoneNo varchar(30) default 'Not Provided',
	comment varchar(100) default '',
	Constraint PURCHASE_STOCK_pk Primary key (itemId,createdTime,createdDate) ,
	Constraint STOCK_fk foreign key (itemId) references STOCK(itemId) on update cascade ,
	Constraint PURCHASE_STOCK_ChkQty Check(qty >0),
	Constraint PURCHASE_STOCK_ChkPrice Check(pricePerUnit > 0),
)



create table setting 
(
	id int,
	mode varChar(30),
	password varBinary(1000) Not Null,
	status bit default 1,
	constraint setting_pk primary key (id)
)




create procedure insertSystemUser @id int,@mode varchar(30),@pw varchar(30)
as
insert into setting (id,mode,password)
values (@id,@mode,CONVERT(varbinary,@pw))

create procedure removeSystemUser @id int
as
update setting
set status=0
where id = @id


create procedure checkAuthUser @id int,@pw varchar(30)
as
select id
from setting 
where id=@id and password = CONVERT(varbinary,@pw) and status=1 and mode='user'

exec insertSystemUser 777,'admin','ntu'
exec insertSystemUser 111,'user','haris'

exec checkAuthUser 111,'haris'


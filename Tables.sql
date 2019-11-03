--create database FactoryManagement

---------- WORKERS Sections -------


CREATE TABLE WORKER
(
	WID INT IDENTITY(1,1),
	WorkerID AS 'WID' + RIGHT('00000000' + CAST(WID AS VARCHAR(8)), 8) PERSISTED,
	WorkerName varchar(50) Not Null,
	Balance int default 0 not Null,
	PhoneNo varChar(20) Null,
	--ShiftPeriod varChar(20) DEFAULT NULL,
	Address varchar(50) Default Null,
	Status bit default 1,
	createdTime varchar(30) default CONVERT(varchar(15),  CAST(GETDATE() AS TIME), 100),
	createdDate date default convert(date, getDate()),
	Constraint WORKER_pk PRIMARY KEY (WID),
	CONSTRAINT CHK_Balance CHECK (Balance>=0)
)


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


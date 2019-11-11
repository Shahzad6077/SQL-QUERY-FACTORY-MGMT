-------------SHOW WORKER VIEW-------------

Create view WORKERS_VIEW
AS select *
FROM WORKER

Select *
From WORKERS_VIEW

-------------ADD WORKER PROCEDURE -------------

CREATE PROCEDURE addWorker @name  varChar(50), @phone varchar(20),@cnic int, @address  varChar(50)
AS
INSERT INTO WORKER (WorkerName,PhoneNo,cnic,Adress)
VALUES (@name,@phone,@cnic,@address) 

EXEC addWorker 'Farhan','111111',33100,'FSD'
------------------------------------------------------

-----------------UPDATE WORKER (DETAILS) PROCEDURE -------------





CREATE PROCEDURE updateWorker @id int, @name  varchar(50),@PhoneNo varChar(20),@Address varchar(50)
AS
update WORKER
set WorkerName= @name,PhoneNo= @PhoneNo,Adress=@Address
where WID= @id

EXEC updateWorker 29,'Mesum Rizvi','66666','Lahore'


---------UPDATE WORKER (BALANCE) PROCEDURE-----------
CREATE PROCEDURE updateWorkBalance  @wID  int,@payment int
AS
update WORKER
set Balance= Balance+@payment
where WID= @wID

EXEC updateWorkBalance 30,30
------------------------------------------------------
-------------REMOVE WORKER PROCEDURE (ONLY CHANGE STATUS TRUE/FALSE)-------------
CREATE PROCEDURE changeStatusWorker @id int, @value  bit
AS
update WORKER
set Status= @value
where WID= @id

EXEC changeStatusWorker 29,0
------------------------------------------------------


----------------ADD WORK_DONE PROCEDURE---------------

CREATE PROCEDURE addWorkDone @wID  int, @payment int, @detail  varChar(50)
AS
INSERT INTO WORK_DONE (WID,Daily_Payment,detail)
VALUES (@wID,@payment,@detail) ;
------------------------------------------------------


----------------ADD BALANCE_WITHDRAW PROCEDURE---------------



CREATE PROCEDURE newWithdraw @wID  int, @amount int
AS
INSERT INTO BALANCE_WITHDRAW (WID,amount)
VALUES (@wID,@amount) 
------------------------------------------------------
------------- get list of daily wages(work done)----------
Create view DAILY_WAGES_VIEW
AS
select W.WID,W.WorkerID,W.WorkerName,WD.Detail,WD.Daily_Payment,WD.createdDate
from WORKER W inner join WORK_DONE WD on W.WID = WD.WID
where W.Status = 1

select * from DAILY_WAGES_VIEW

/*
Exec insertWorkDone 27,30,'p123 LHR'
EXEC WorkBalance 27,30

select * 
from WORKER

select * 
from WORK_DONE


select W.WID,W.WorkerID,W.WorkerName,WD.Detail,WD.Daily_Payment,WD.createdDate
from WORKER W inner join WORK_DONE WD on W.WID = WD.WID
where W.Status = 1


*/



---------------------------- STOCK SECTION ------------------------
-------------- NEW STOCK ENTERED ----------

---- THIS IS FOR WHEN RECORD IS NOT CREATED BEFORE -----
/*
	ye procedure Purchase waly panel par chaly ga jb hum ny new Stock buy kia or add krna hoga 
	this will automatically create a purchasing record or add the record in STOCK table 

*/
CREATE PROCEDURE newStock @NAME VARCHAR(30),@QTY FLOAT, @UNIT VARCHAR(10),@PRICE FLOAT,
				@buyfrom varchar(30),@adress varchar(50),@phone varchar(30),@comment varchar(100)
as
INSERT INTO STOCK (itemName,qty,unit,pricePerUnit)
values (@NAME,@QTY,@UNIT,@PRICE)
declare @idOrig int;
select @idOrig=  IDENT_CURRENT( 'STOCK' );
insert into PURCHASE_STOCK (itemId,qty,pricePerUnit,purchaseFrom,pAddress,phoneNo,comment)
values (@idOrig,@QTY,@PRICE,@buyfrom,@adress,@phone,@comment)

-----------------------------------------------
---- THIS IS FOR WHEN RECORD IS ALREADY CREATED BEFORE -----
/*
	ye procedure Stock waly panel par chaly ga 
	jb hum ny koi existing stock Item ko select kia or hum ny us ki qty update ki 
	yaha par 2 case ho sakty hain k ab wohi item kici or company sy buy ki ho ic liye jb b kici b 
	stock ki item ko update kry gy to company ki details must hai 
	ye Stock ki qty ko update b kr dy ga or purchase wly table mai jaa kr humry pas record b rah jay ga 

*/
create procedure newStockWithUpdate @id int,@NAME VARCHAR(30),@QTY FLOAT, @UNIT VARCHAR(10),@PRICE FLOAT,
				@buyfrom varchar(30),@adress varchar(50),@phone varchar(30),@comment varchar(100)
as
update STOCK
set qty= qty+@QTY,pricePerUnit=@PRICE
where itemId= @id

insert into PURCHASE_STOCK (itemId,qty,pricePerUnit,purchaseFrom,pAddress,phoneNo,comment)
values (@id,@QTY,@PRICE,@buyfrom,@adress,@phone,@comment)

-----------------------------------------------------

---- DELETE THE STOCK -----
/*
	YAHA PAr active ki value ko 0 kr dain gy kyun k humy still previous record chaye hai 
	stock items ka in-case koi stock item remove krni pari to uski wja sy jo previous record tha purchase table mai
	wo b del hojay ga so hum ny kia k acitve ko 0 kr dia 
*/
create procedure removeStock @id int 
as
update STOCK
set active= 0
where itemId= @id

---- update NAME OF STOCK ITEM-----
/*
*/
create procedure updateStockItemName @id int,@name varchar(30)
as
update STOCK
set itemName= @name
where itemId= @id

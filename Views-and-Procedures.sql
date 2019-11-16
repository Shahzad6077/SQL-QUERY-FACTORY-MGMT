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

-------------REMOVE WORKER PROCEDURE (ONLY CHANGE STATUS TRUE/FALSE)-------------
CREATE PROCEDURE changeStatusWorker @id int, @value  bit
AS
update WORKER
set Status= @value
where WID= @id

																		EXEC changeStatusWorker 29,0
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
CREATE PROCEDURE newStock @NAME VARCHAR(30),@QTY FLOAT, @UNIT VARCHAR(10),@PRICE FLOAT , @buyfrom Varchar(30)
as
INSERT INTO STOCK (itemName,qty,unit,pricePerUnit)
values (@NAME,@QTY,@UNIT,@PRICE)
declare @idOrig int;
select @idOrig=  IDENT_CURRENT( 'STOCK' );
insert into PURCHASE_STOCK (itemId,qty,pricePerUnit, pType , purchaseFrom)
values (@idOrig,@QTY,@PRICE,'add' , @buyfrom)

CREATE VIEW stockPurchase
AS
SELECT P.createdDate, S.itemId ,S.itemName,S.qty,S.unit , S.pricePerUnit , P.purchaseFrom
FROM STOCK S, PURCHASE_STOCK P

SELECT * FROM stockPurchase
-----------------------------------------------
---- THIS IS FOR WHEN RECORD IS ALREADY CREATED BEFORE -----
/*
	ye procedure Stock waly panel par chaly ga 
	jb hum ny koi existing stock Item ko select kia or hum ny us ki qty update ki 
	yaha par 2 case ho sakty hain k ab wohi item kici or company sy buy ki ho ic liye jb b kici b 
	stock ki item ko update kry gy to company ki details must hai 
	ye Stock ki qty ko update b kr dy ga or purchase wly table mai jaa kr humry pas record b rah jay ga 

*/
create procedure newStockWithUpdate @id int,@QTY FLOAT, @UNIT VARCHAR(10),@PRICE FLOAT,
				@buyfrom varchar(30)
as
update STOCK
set qty+=@QTY,pricePerUnit=@PRICE
where itemId= @id

insert into PURCHASE_STOCK (itemId,qty,pricePerUnit,purchaseFrom,pType)
values (@id,@QTY,@PRICE,@buyfrom,'add')

exec newStockWithUpdate 1,10,'kg',1011,'intense'
-----------------------------------------------------


/*
	ye procedure utilized sy phly run krk result check krna age row greater than 0 ai hain to thek hai utilize wla proc chalana other wise
	jitni qty pari us sy zyada utlize ka error show krwa dna
*/
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


exec newStock 'Sugar',20,'kg',400,'AK mill'

exec newStockWithUpdate 1,5,'kg',200,'Zone mill'

exec checkBeforeUtilized 1,1
exec stockUtilized 1,1


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


Create view STOCK_REPORT_VIEW
AS
select itemId,itemName,qty,pricePerUnit 
from STOCK
where active = 1


select * from STOCK_REPORT_VIEW

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
-------------SHOW WORKER VIEW-------------

Create view WORKERS_VIEW
AS select *
FROM WORKER

Select *
From WORKERS_VIEW

-------------ADD WORKER PROCEDURE -------------

CREATE PROCEDURE addWorker @name  varChar(50), @phone varchar(20) , @address  varChar(50)
AS
INSERT INTO WORKER (WorkerName,PhoneNo,Address)
VALUES (@name,@phone,@address) 

Exec addWorker 'Mesum Ali','09123','p123 LHR'
------------------------------------------------------

-----------------UPDATE WORKER (DETAILS) PROCEDURE -------------
CREATE PROCEDURE updateWorker @id int, @name  varchar(50),@PhoneNo varChar(20),@Address varchar(50)
AS
update WORKER
set WorkerName= @name,PhoneNo= @PhoneNo,Address=@Address
where WID= @id

EXEC updateWorker 29,'Mesum Rizvi','66666','Lahore'


---------UPDATE WORKER (BALANCE) PROCEDURE-----------
CREATE PROCEDURE updateWorkBalance  @wID  int,@payment int
AS
update WORKER
set Balance= Balance+@payment
where WID= @wID

EXEC updateWorkBalance 29,30
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
VALUES (@wID,@payment,@detail) 
------------------------------------------------------


----------------ADD BALANCE_WITHDRAW PROCEDURE---------------

CREATE PROCEDURE newWithdraw @wID  int, @amount int
AS
INSERT INTO BALANCE_WITHDRAW (WID,amount)
VALUES (@wID,@amount) 
------------------------------------------------------


/*
Exec insertWorkDone 27,30,'p123 LHR'
EXEC WorkBalance 27,30

select * 
from WORKER

select * 
from WORK_DONE


select W.WID,W.WorkerID,W.WorkerName,WD.Detail,WD.Daily_Payment,WD.createdDate
from WORKER W inner join WORK_DONE WD on W.WID = WD.WID
where W.Status = 'Active'


*/

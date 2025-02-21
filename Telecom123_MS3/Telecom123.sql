create database Telecom123
drop database Telecom123
use  Telecom123
go
-------------------------------------------------------------------------------------
------------------------create tables Procedure--------------------------------------------

CREATE PROCEDURE [createAllTables]

AS

create table customer_profile(
nationalID int primary key,
first_name varchar(50) not null, 
last_name varchar(50) not null,
email varchar(50),
address varchar(70) not null, 
date_of_birth date
)


create table customer_account(
mobileNo char(11) primary key,
pass varchar(50),
balance decimal(10,1),
account_type varchar(50) check(account_type = 'postpaid' or account_type = 'prepaid' or account_type = 'pay-as-you-go' ),
start_date date not null,
status varchar(50) check(status = 'active' or status = 'onhold'),
points int default 0,
nationalID int,
FOREIGN KEY (nationalID) REFERENCES customer_profile (nationalID)
)

create table Service_plan(
planID int identity primary key,
name varchar(50) not null,
price int not null,
SMS_offered int not null,
minutes_offered int not null,
data_offered int not null,
description varchar(50)
)

create table Subscription(
mobileNo Char(11),
planID int,
subscription_date date,
status varchar(50) check(status='active' or status='onhold'),
constraint pk_subscription primary key (mobileNo,planID),
FOREIGN KEY (mobileNo) REFERENCES customer_account (mobileNo),
FOREIGN KEY (planID) REFERENCES Service_plan (planID)
)

create table Plan_Usage(
usageID int identity primary key,
start_date date not null,
end_date date not null,
data_consumption int,
minutes_used int ,
SMS_sent int  , 
mobileNo Char(11) , 
planID int,
FOREIGN KEY (mobileNo) REFERENCES customer_account (mobileNo),
FOREIGN KEY (planID) REFERENCES Service_plan (planID)
)


create table Payment(
paymentID int identity primary key,
amount decimal(10,1) not null,
date_of_payment date not null,
payment_method varchar(50) check(payment_method ='cash' or payment_method ='credit'),
status varchar(50) check(status ='successful' or status='rejected' or status='pending'),
mobileNo Char(11),
FOREIGN KEY (mobileNo) REFERENCES customer_account (mobileNo)
)




create table process_payment(
paymentID int,
planID int,
FOREIGN KEY (paymentID) REFERENCES Payment (paymentID),
FOREIGN KEY (planID) REFERENCES Service_plan (planID),

remaining_amount as(dbo.function_remaining_amount(paymentID, planID)),
extra_amount as (dbo.function_extra_amount(paymentID, planID)),

constraint pk_process_payment primary key (paymentID) 
)

create table Wallet
(
walletID int identity primary key,
current_balance decimal(10,2) default 0,
currency varchar(50) default 'egp',
last_modified_date date ,
nationalID int,
mobileNo char(11),
FOREIGN KEY (nationalID) REFERENCES customer_profile (nationalID)
)

create table transfer_money(
walletID1 int, 
walletID2 int, 
transfer_id int identity,
amount decimal (10,2),
transfer_date date, 
constraint pk_transfer_money primary key (walletID1,walletID2,transfer_id),
FOREIGN KEY (walletID1) REFERENCES Wallet(walletID),
FOREIGN KEY (walletID2) REFERENCES Wallet (walletID)
)

create table Benefits (
benefitID int primary key identity, 
description varchar(50),
validity_date date, 
status varchar (50) check(status='active' or status ='expired'),
mobileNo char(11), 
FOREIGN KEY (mobileNo) REFERENCES customer_account(mobileNo)
)

create table Points_group(
pointId int identity,
benefitID int, 
pointsAmount int,
paymentId int,
FOREIGN KEY (paymentId) REFERENCES Payment(paymentID),
FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID),
constraint pk_Points_group primary key (pointId,benefitId)
)

create table Exclusive_offer (
offerID int identity, 
benefitID int, 
internet_offered int ,
SMS_offered int,
minutes_offered int,
FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID),
constraint pk_Exclusive_offer primary key (offerID,benefitId)

)

create table Cashback(
cashbackID int identity, 
benefitID int, 
walletID int, 
amount int,
credit_date date,FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID),
FOREIGN KEY (walletid) REFERENCES Wallet(walletid),
constraint pk_Cashback primary key (cashbackID,benefitId)
)

create table plan_provides_benefits(
benefitid int, 
planID int, 
FOREIGN KEY (benefitID) REFERENCES Benefits(benefitID),
FOREIGN KEY (planID) REFERENCES service_plan(planID),
constraint pk_plan_provides_benefits primary key (planID,benefitId)
)

create table shop (
shopID int identity primary key,
name varchar(50),
Category varchar(50)
)
create table Physical_shop (
shopID int primary key, 
address varchar(50),
working_hours varchar(50),
FOREIGN KEY (shopID) REFERENCES shop(shopID),
)

create table E_shop (
shopID int primary key , 
URL varchar(50) not null,
rating int,
FOREIGN KEY (shopID) REFERENCES shop(shopID),
)

create table Voucher (
voucherID int identity primary key,
value int,
expiry_date date,
points int, 
mobileNo char(11),
redeem_date date,
shopid int, 
FOREIGN KEY (shopID) REFERENCES shop(shopID),
FOREIGN KEY (mobileNo) REFERENCES customer_account(mobileNo)
)



create table Technical_support_ticket (
ticketID int identity,
mobileNo char(11), 
issue_description varchar(50),
priority_level int,
status varchar(50) check (status in ('Open','In progress','Resolved'))
FOREIGN KEY (mobileNo) REFERENCES customer_account(mobileNo),
constraint pk_Technical_support_ticket primary key (ticketID,mobileNo)
)
EXEC createAllTables
GO
exec [createAllTables]

go
CREATE PROCEDURE DropTables
AS
BEGIN
DROP TABLE IF EXISTS Technical_Support_Ticket;
DROP TABLE IF EXISTS Voucher;
DROP TABLE IF EXISTS E_shop;
DROP TABLE IF EXISTS Physical_Shop;
DROP TABLE IF EXISTS Shop;
DROP TABLE IF EXISTS Plan_Provides_Benefits;
DROP TABLE IF EXISTS Cashback;
DROP TABLE IF EXISTS Exclusive_Offer;
DROP TABLE IF EXISTS Points_Group;
DROP TABLE IF EXISTS Benefits;
DROP TABLE IF EXISTS Transfer_money;
DROP TABLE IF EXISTS Wallet;
DROP TABLE IF EXISTS Process_Payment;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Plan_Usage;
DROP TABLE IF EXISTS Subscription;
DROP TABLE IF EXISTS Service_Plan;
DROP TABLE IF EXISTS Customer_Account;
DROP TABLE IF EXISTS Customer_profile;
END 

EXEC DropTables                -------error

-------------------------------------------------------------------------------------
------------------------remaining function--------------------------------------------
go
CREATE FUNCTION [function_remaining_amount]
(@paymentId int, @planId int) --Define Function Inputs
RETURNS int -- Define Function Output
AS

Begin

declare @amount int

If (SELECT payment.amount FROM payment WHERE payment.paymentid=@paymentId)  < (SELECT Service_plan.price FROM Service_plan
WHERE Service_plan.planid=@planid)

Set @amount =  (SELECT Service_plan.price FROM Service_plan WHERE Service_plan.planid=@planid) - (SELECT payment.amount FROM payment
WHERE payment.paymentid=@paymentId)

Else
Set @amount = 0

Return @amount

END
go

-------------------------------------------------------------------------------------------
---------------------------------extra function--------------------------------------------
go
CREATE FUNCTION [function_extra_amount]
(@paymentId int, @planId int) --Define Function Inputs
RETURNS int -- Define Function Output
AS

Begin

declare @amount int

If (SELECT payment.amount FROM payment WHERE payment.paymentid=@paymentId)  > (SELECT Service_plan.price FROM Service_plan
WHERE Service_plan.planid=@planid)

Set @amount = (SELECT payment.amount FROM payment WHERE payment.paymentid=@paymentId) - (SELECT Service_plan.price FROM Service_plan WHERE Service_plan.planid=@planid)

Else
Set @amount = 0

Return @amount

END

go
-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Exec createAllTables

-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------Views------------------------------------------------------------------------------------------
-----------------------------------Basic Data Retrieval------------------------------------------------------------------------------------------


-----------------------------------allCustomerAccounts------------------------------------------------------------------------------------------
-------------------Fetch details for all customer profiles along with their active accounts---------------------
GO
CREATE VIEW [allCustomerAccounts] AS
SELECT p.*,a.mobileNo,a.account_type,a.status,a.start_date,a.balance,a.points from customer_profile p
inner join customer_account a 
on p.nationalID = a.nationalID
where a.status = 'active'

GO
select * from customer_account
-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------allServicePlans------------------------------------------------------------------------------------------
-------------------Fetch details for all offered Service Plans---------------------

GO
CREATE VIEW [allServicePlans] AS
select * from Service_plan
GO
select * from [allServicePlans]
SELECT * FROM Consumption
-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------allBenefits------------------------------------------------------------------------------------------
-------------------Fetch details for all active Benefits---------------------
GO
CREATE VIEW [allBenefits] AS
select * from Benefits
where status = 'active'
GO


-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------AccountPayments------------------------------------------------------------------------------------------
-----------Fetch details for all payments along with their corresponding Accounts---------------------

GO
CREATE VIEW [AccountPayments] AS
select * from Payment p

GO

-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------allShops------------------------------------------------------------------------------------------
-----------Fetch details for all shops.---------------------
GO
CREATE VIEW [allShops] AS
select * from shop 
GO

-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------allResolvedTickets------------------------------------------------------------------------------------------
-----------Fetch details for all resolved tickets---------------------
GO
CREATE VIEW [allResolvedTickets] AS
select * from Technical_support_ticket
where status = 'Resolved'
GO

-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------CustomerWallet------------------------------------------------------------------------------------------
-----------Fetch details of all wallets along with their customer names---------------------
GO
CREATE VIEW [CustomerWallet] AS
select w.*,p.first_name,p.last_name from Wallet w
inner join customer_profile p
on w.nationalID = p.nationalID

GO

-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------E_shopVouchers------------------------------------------------------------------------------------------
-----------Fetch the list of all E-shops along with their redeemed vouchers’s ids and values---------------------
GO
CREATE VIEW [E_shopVouchers] AS
select e.*, v.voucherID,v.value from E_shop e
inner join Voucher v
on e.shopID = v.shopid

GO
-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------PhysicalStoreVouchers------------------------------------------------------------------------------------------
-----------Fetch the list of all physical stores along with their redeemed vouchers’s ids and values.---------------------
GO
CREATE VIEW [PhysicalStoreVouchers] AS
select p.*, v.voucherID,v.value from Physical_shop p
inner join Voucher v
on p.shopID = v.shopid

GO
-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-----------------------------------Num_of_cashback------------------------------------------------------------------------------------------
-----------Fetch number of cashback transactions per each wallet---------------------
GO
CREATE VIEW [Num_of_cashback] AS
select walletID,count(*)as 'count of transactions' from Cashback
group by walletID

GO


-----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------Account_Plan Procedure------------------------------------------------------------
-- List all accounts along with the service plans they are subscribed to ----------------------------------------------------
go
create Procedure [Account_Plan]
AS
Select customer_account.*, Service_plan.* from customer_account inner join Subscription
on customer_account.mobileNo = Subscription.mobileNo inner join Service_plan on Subscription.planID = Service_plan.planID
GO
exec Accou

-----------------------------------------------------------------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


------------------------------------Account_Plan_date Table Valued Function---------------------------------------------------------
-----Retrieve the list of accounts subscribed to the input plan on a certain date--------------------------------
drop function [Account_Plan_date]
go
CREATE FUNCTION [Account_Plan_date]
(@sub_date date, @plan_id int) --Define Function Inputs
RETURNS Table -- Define Function Output
AS
Return 
(Select customer_account.mobileNo, Service_plan.planID, Service_plan.name from customer_account inner join Subscription
on customer_account.mobileNo = Subscription.mobileNo inner join Service_plan on Subscription.planID = Service_plan.planID
WHERE Subscription.subscription_date = @sub_date AND Service_plan.planID = @plan_id)
go
--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------

-----------------------------Account_Usage_Plan table valued function-------------------------------------------------------
--Retrieve the total usage of the input account on each subscribed plan from a given input date.
go
create FUNCTION [Account_Usage_Plan]
(@mobile_num char(11), @start_date date) --Define Function Inputs
RETURNS Table -- Define Function Output
AS
Return (Select Plan_Usage.planID, sum(Plan_Usage.data_consumption) as 'total data' ,sum(Plan_Usage.minutes_used) as 'total mins',sum(Plan_Usage.SMS_sent) as 'total SMS'
from Plan_Usage
where  Plan_Usage.mobileNo = @mobile_num and Plan_Usage.start_date >= @start_date
group by Plan_Usage.planID)
go
--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------

---------------------------------Benefits_Account  -------------------------------------------------------------------------
---------Delete all benefits offered to the input account for a certain plan-------------------
go
CREATE PROCEDURE [Benefits_Account]
@mobile_num char(11), @plan_id int

AS
update Benefits
set mobileNo = null
from  Benefits B inner join plan_provides_benefits pb
on B.benefitID = pb.benefitid 
where B.mobileNo = @mobile_num and pb.planID = @plan_id
go
/*
delete B from Benefits B inner join plan_provides_benefits pb
on B.benefitID = pb.benefitid 
where B.mobileNo = 01234567890 and pb.planID = 1
*/

---must also delete any of the subclasses that have this benefit_id if using delete 
--delete from benefit or update mobile number to Null !!!!!!!



--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
---------------------------------Account_SMS_Offers  -------------------------------------------------------------------------
---------Retrieve the list of gained offers of type ‘SMS’ for the input account-------------------
go
CREATE FUNCTION [Account_SMS_Offers]
(@mobile_num char(11)) --Define Function Inputs
RETURNS Table -- Define Function Output
AS
Return(Select o.* from Exclusive_offer o inner join Benefits b 
on o.benefitID = b.benefitID 
where b.mobileNo = @mobile_num and o.SMS_offered >0 )
go 

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
---------------------------------Account_Payment  -------------------------------------------------------------------------
---------Get the number of accepted  payment transactions initiated by the input account during the last year--------------------
go
CREATE PROCEDURE [Account_Payment_Points]
@mobile_num char(11)

AS
select count(p.paymentID), sum(pb.pointsAmount) from Payment P
inner join Points_group pb 
on p.paymentID = pb.paymentId
where P.mobileNo = @mobile_num and (year(current_timestamp) - year(p.date_of_payment)=1 ) 
and P.status = 'successful'
go
EXEC [Account_Payment_Points] '01234567890'

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
---------------------------------Wallet_Cashback_Amount-------------------------------------------------------------------------
---------Retrieve the amount of cashback returned on the input wallet--------------------

go
CREATE FUNCTION [Wallet_Cashback_Amount]
(@walletID int, @planID int) --Define Function Inputs
RETURNS int -- Define Function Output
AS
Begin
declare @amount int

set @amount = (Select sum(c.amount) from Cashback c 
inner join plan_provides_benefits pb 
on c.benefitID = pb.benefitid
where c.walletID = @walletID and pb.planID = @planID)

return @amount
END
go
SELECT dbo.Wallet_Cashback_Amount(2, 3)


--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
---------------------------------Wallet_Transfer_Amount-------------------------------------------------------------------------
---------Retrieve the average of the sent transaction amounts from the input wallet within a certain duration.--------------------
go
CREATE FUNCTION [Wallet_Transfer_Amount]
(@walletID int, @start_date date, @end_date date) --Define Function Inputs
RETURNS int -- Define Function Output
AS
Begin
declare @avg int

set @avg = (Select avg(t.amount) from transfer_money t
where t.walletID1 = @walletID and t.transfer_date between @start_date and @end_date)

return @avg
END
go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
---------------------------------Wallet_MobileNo-------------------------------------------------------------------------
-----------------------------Take mobileNo as an input, return true if this number is linked to a wallet, otherwise return false.
go
CREATE FUNCTION [Wallet_MobileNo]
(@mobile_num char(11)) --Define Function Inputs
RETURNS bit -- Define Function Output
AS
Begin
declare @output bit
IF exists((Select w.walletID from Wallet w
where w.mobileNo = @mobile_num ))
set @output = 1
else 
set @output = 0

return @output
END
go
select * from customer_account

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Total_Points_Account-----------------------
------------------------- Update the total number of points that the input account should have--------------------------

go
CREATE PROCEDURE [Total_Points_Account]
@mobile_num char(11)  

AS
declare @sum int
select @sum =  sum(pg.pointsAmount) from Points_group pg
inner join Payment p
on pg.paymentId = p.paymentID
where p.mobileNo = @mobile_num

update customer_account  
set points = @sum
where mobileNo = @mobile_num

delete from Points_group
where pointId in  (select pg.pointId from Points_group pg
inner join Payment p on pg.paymentId = p.paymentID
where p.mobileNo = @mobile_num)
go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
-------------------------2.4.As a customer I should be able to------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------AccountLoginValidation-----------------------
-------------------------login using my mobileNo and password--------------------------
go
CREATE FUNCTION [AccountLoginValidation]
(@mobile_num char(11), @pass varchar(50)) --Define Function Inputs
RETURNS bit -- Define Function Output
AS
Begin
declare @output bit
IF exists((Select a.mobileNo from customer_account a
where a.mobileNo = @mobile_num and a.pass = @pass ))
set @output = 1
else 
set @output = 0

return @output
END
go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Consumption-----------------------
-------------------------Retrieve the total SMS, Mins and Internet consumption for an input plan within a certain duration--------------------------

go
CREATE FUNCTION [Consumption]
(@Plan_name varchar(50), @start_date date, @end_date date) --Define Function Inputs
RETURNS Table -- Define Function Output
AS
Return(Select p.data_consumption,p.minutes_used,p.SMS_sent from Plan_Usage p 
inner join Service_plan s on s.planID = p.planID
where s.name = @Plan_name and p.start_date >= @start_date and p.end_date <= @end_date)
go 
--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Unsubscribed_Plans-----------------------
-------------------------Retrieve all offered plans that the input customer is not subscribed to--------------------------
go
CREATE PROCEDURE [Unsubscribed_Plans]
@mobile_num char(11)

AS
select  sp.* from  Service_plan sp 
where sp.planID not in (
select s.planID  from Subscription s
where s.mobileNo = @mobile_num)
go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Usage_Plan_CurrentMonth-----------------------
-------------------------Retrieve the usage of all active plans for the input account in the current month--------------------------

go
CREATE FUNCTION [Usage_Plan_CurrentMonth]
(@mobile_num char(11)) --Define Function Inputs
RETURNS Table -- Define Function Output
AS
Return(select p.data_consumption, p.minutes_used, p.SMS_sent from Plan_Usage p
inner join Subscription s 
on p.planID = s.planID and p.mobileNo = s.mobileNo
where p.mobileNo = @mobile_num and s.status = 'active' 
and month(p.start_date)= month(current_timestamp) or month(p.end_date)= month(current_timestamp) and year(p.start_date)= year(current_timestamp) or year(p.end_date)= year(current_timestamp))
go 

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Cashback_Wallet_Customer-----------------------
------------------------- Retrieve all cashback transactions related to the wallet of the input customer--------------------------

go
CREATE FUNCTION [Cashback_Wallet_Customer]
(@NID int) --Define Function Inputs
RETURNS Table -- Define Function Output
AS
Return(select c.* from Cashback c 
inner join Wallet w 
on c.walletID = w.walletID 
where w.nationalID = @NID)
go 




--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Ticket_Account_Customer-----------------------
------------------------- Retrieve the number of technical support tickets that are NOT ‘Resolved’ for each account of the input customer--------------------------

go
CREATE PROCEDURE [Ticket_Account_Customer]
@NID int 

AS
select count(t.ticketID) from Technical_support_ticket t
inner join customer_account a 
on t.mobileNo = a.mobileNo
where t.status <> 'resolved' and a.nationalID = @NID
go


--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Account_Highest_Voucher-----------------------
------------------------- Return the voucher with the highest value for the input account.--------------------------

go
CREATE PROCEDURE [Account_Highest_Voucher]
@mobile_num char(11)  

AS
declare @max int
select @max =  max(v.value) from Voucher v 
where v.mobileNo = @mobile_num 

select v.voucherID from voucher v
where v.mobileNo = @mobile_num and v.value = @max

go


--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Remaining_plan_amount-----------------------
------------------------- Get the remaining amount for a certain plan based on the payment initiated by the input account--------------------------
go
CREATE FUNCTION [Remaining_plan_amount]
(@mobile_num char(11), @plan_name varchar(50)) --Define Function Inputs
RETURNS int -- Define Function Output
AS
Begin
declare @output int, @plan_id int, @payment_id int
Select @plan_id = s.planID, @payment_id= p.paymentID from Service_plan s inner join process_payment pp
on s.planID = pp.planID inner join payment p 
on pp.paymentID = p.paymentID
where s.name = @plan_name and p.mobileNo = @mobile_num and p.status='successful'

set @output = dbo.function_remaining_amount(@payment_id,@plan_id)
return @output
END
go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Extra_plan_amount-----------------------
-------------------------Get the extra amount from a payment initiated by the input account for a certain plan--------------------------
go
CREATE FUNCTION [Extra_plan_amount]
(@mobile_num char(11), @plan_name varchar(50)) --Define Function Inputs
RETURNS int -- Define Function Output
AS
Begin
declare @output int, @plan_id int, @payment_id int
Select @plan_id = s.planID, @payment_id= p.paymentID from Service_plan s inner join process_payment pp
on s.planID = pp.planID inner join payment p 
on pp.paymentID = p.paymentID
where s.name = @plan_name and p.mobileNo = @mobile_num and p.status='successful'

set @output = dbo.function_extra_amount(@payment_id,@plan_id)
return @output
END
go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Top_Successful_Payments-----------------------
-------------------------Retrieve the top 10 successful payments with highest value for the input account--------------------------
go
CREATE PROCEDURE [Top_Successful_Payments]
@mobile_num char(11)  

AS
select top 10 p.* from Payment p 
where p.mobileNo = @mobile_num
and p.status = 'successful'
order by p.amount desc
go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Subscribed_plans_5_Months-----------------------
-------------------------Retrieve all service plans the input account subscribed to in the past 5 months--------------------------

go
CREATE FUNCTION [Subscribed_plans_5_Months]
(@MobileNo char(11)) --Define Function Inputs
RETURNS Table -- Define Function Output
AS
Return(Select sp.* from Service_plan sp 
inner join Subscription s 
on sp.planID = s.planID
where s.mobileNo = @MobileNo and 
s.subscription_date >= DATEADD(month,-5,CURRENT_TIMESTAMP))
go 

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Initiate_plan_payment-----------------------
-------------------------Initiate an accepted payment for the input account for plan renewal and update the status of the subscription accordingly.--------------------------

go
CREATE PROCEDURE [Initiate_plan_payment]
@mobile_num char(11), @amount decimal(10,1), @payment_method varchar(50),
@plan_id int 

AS
declare @payment_id int
Insert into Payment (amount,date_of_payment,payment_method,status,mobileNo)
values(@amount,CURRENT_TIMESTAMP,@payment_method,'successful',@mobile_num)
SELECT @payment_id = p.paymentID from Payment p    
where p.mobileNo = @mobile_num and p.amount = @amount and p.date_of_payment = CAST(CURRENT_TIMESTAMP AS DATE)
and p.payment_method = @payment_method and p.status = 'successful'
Insert into process_payment(paymentID, planID) values(@payment_id, @plan_id)
if(select remaining_amount from process_payment where planID = @plan_id and paymentID = @payment_id) = 0 
update Subscription
set status = 'active'
where planID = @plan_id and mobileNo = @mobile_num
else
update Subscription
set status = 'onhold'
where planID = @plan_id and mobileNo = @mobile_num

go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Payment_wallet_cashback-----------------------
-------------------------Calculate the amount of cashback that will be returned on the wallet of the customer of the input account from a certain payment--------------------------

go
CREATE PROCEDURE [Payment_wallet_cashback]
@mobile_num char(11), @payment_id int, @benefit_id int 

AS
declare @amount int, @cash_amount int, @wallet_id int 
select @amount = p.amount  from Payment p
where p.paymentID = @payment_id and p.status = 'successful'
set @cash_amount = 0.1 * @amount
select @wallet_id = w.walletID from Wallet w
inner join customer_account a on
w.nationalID = a.nationalID 
where a.mobileNo = @mobile_num

Insert into Cashback(benefitID,walletID,amount,credit_date)
values(@benefit_id,@wallet_id,@cash_amount,current_timestamp)

update Wallet
set current_balance = current_balance + @cash_amount,
last_modified_date = current_timestamp
where walletID = @wallet_id

go


--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Initiate_balance_payment-----------------------
-------------------------Initiate an accepted payment for the input account for balance recharge--------------------------
go
CREATE PROCEDURE [Initiate_balance_payment]
@mobile_num char(11), @amount decimal(10,1), @payment_method varchar(50)

as
Insert into Payment (amount,date_of_payment,payment_method,status,mobileNo)
values(@amount,CURRENT_TIMESTAMP,@payment_method,'successful',@mobile_num)

update customer_account
set balance = balance + @amount
where mobileNo = @mobile_num

go

--//////////////////////////////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------------------------------------
----------------------------------------Redeem_voucher_points-----------------------
------------------------- Redeem a voucher for the input account and update the total points of the account accordingly--------------------------
go
CREATE PROCEDURE [Redeem_voucher_points]
@mobile_num char(11), @voucher_id int 

AS
If (Select v.points from Voucher v 
where v.voucherID = @voucher_id and v.expiry_date >CURRENT_TIMESTAMP ) <= (Select a.points from customer_account a 
where a.mobileNo = @mobile_num) 
begin 
declare @voucher_points int 
select @voucher_points = points from Voucher
where voucherID = @voucher_id
update Voucher
set mobileNo = @mobile_num , redeem_date = current_timestamp 
where voucherID = @voucher_id 

update customer_account
set points = points - @voucher_points
where mobileNo = @mobile_num
end 
else 
print 'no enough points to redeem voucher'

go 










--///////////////////////////////////////////////////////////////////////////////////////////////////
----------------------------------- Executions ------------------------------------------------------
----------------------------------- Views ------------------------------------------------------
----------------------------------- allCustomerAccounts ------------------------------------------------------

Select * from allCustomerAccounts 
----------------------------------- allServicePlans ------------------------------------------------------

Select * from allServicePlans
----------------------------------- allBenefits ------------------------------------------------------

Select * from allBenefits
----------------------------------- AccountPayments ------------------------------------------------------

Select * from AccountPayments
-----------------------------------allShops------------------------------------------------------

Select * from allShops
-----------------------------------allResolvedTickets------------------------------------------------------

Select * from allResolvedTickets
-----------------------------------CustomerWallet------------------------------------------------------

Select * from CustomerWallet
-----------------------------------E_shopVouchers------------------------------------------------------

Select * from E_shopVouchers
-----------------------------------PhysicalStoreVouchers------------------------------------------------------

Select * from PhysicalStoreVouchers
-----------------------------------Num_of_cashback------------------------------------------------------

Select * from Num_of_cashback

--------------------Admin Executions--------------------------------------------
-----------------------Account_Plan Procedure----------------------------------
Exec Account_Plan

-----------------Account_Plan_date Table Valued Function--------------
select * from Plan_Usage
select * from dbo.Account_Plan_date ('2023-02-01',2)

-----------------Account_Usage_Plan function execution-------------------------------------------
select * from Plan_Usage

select * from dbo.Account_Usage_Plan ('05678901234', '2023-05-01')

-------------------Benefits_Account procedure execution---------------------------------------------------------------------------------
select * from allBenefits
Exec Benefits_Account @mobile_num ='03456789012', @plan_id = 1 
-------------------Account_SMS_Offers function execution---------------------------------------------------------------------------------
select * from Benefits
select * from dbo.Account_SMS_Offers ('02345678901')

-----------------------Account_Payment_Points Procedure execution----------------------------------
Exec Account_Payment_Points @mobile_num ='01234567891'

-------------------[Wallet_Cashback_Amount] function execution---------------------------------------------------------------------------------

declare @result int
set @result = dbo.Wallet_Cashback_Amount(2,3)
print @result

-------------------[Wallet_Transfer_Amount] function execution---------------------------------------------------------------------------------

declare @result int
set @result = dbo.Wallet_Transfer_Amount(1,'01-01-2023','05-01-2023')
print @result

-------------------[Wallet_MobileNo] function execution---------------------------------------------------------------------------------

declare @result bit
set @result = dbo.Wallet_MobileNo('03456789012')
print @result
select * from Wallet
-----------------------Total_Points_Account Procedure execution----------------------------------
Exec Total_Points_Account @mobile_num ='01234567890'



----------------------------Customer Executions------------------------------------
-------------------[AccountLoginValidation] function execution---------------------------------------------------------------------------------
select * from customer_account
declare @result bit
set @result = dbo.AccountLoginValidation('01234567890','password123')
print @result

-------------------Consumption function execution---------------------------------------------------------------------------------

select * from dbo.Consumption (1, '2023-01-01','2023-01-31')

-----------------------Unsubscribed_Plans Procedure execution----------------------------------

Exec Unsubscribed_Plans @mobile_num = '01234567890'

-------------------Usage_Plan_CurrentMonth function execution---------------------------------------------------------------------------------

select * from dbo.Usage_Plan_CurrentMonth ('01234567890')
select * from dbo.Usage_Plan_CurrentMonth ('05678901234')
select * from Plan_Usage
-------------------Cashback_Wallet_Customer function execution---------------------------------------------------------------------------------

select * from dbo.Cashback_Wallet_Customer(1)
select * from customer_profile
select * from Benefits
select* from Wallet
select* from customer_account
-----------------------Ticket_Account_Customer Procedure execution----------------------------------

Exec Ticket_Account_Customer @NID = 1

-----------------------Account_Highest_Voucher Procedure execution----------------------------------

Exec Account_Highest_Voucher @mobile_num = '01234567890'

-------------------Remaining_plan_amount function execution---------------------------------------------------------------------------------

declare @result bit
set @result = dbo.Remaining_plan_amount('Basic Plan','01234567890')
print @result

-------------------Extra_plan_amount function execution---------------------------------------------------------------------------------

declare @result bit
set @result = dbo.Extra_plan_amount('Basic Plan','01234567890')
print @result

-----------------------Top_Successful_Payments Procedure execution----------------------------------

Exec Top_Successful_Payments @mobile_num = '01234567890'

-------------------Subscribed_plans_5_Months function execution---------------------------------------------------------------------------------

select * from dbo.Subscribed_plans_5_Months ('01234567890')

-----------------------Initiate_plan_payment Procedure execution----------------------------------

Exec Initiate_plan_payment @mobile_num = '01234567890', @amount =100, @payment_method = 'cash',
@plan_id = 3
-----------------------Payment_wallet_cashback Procedure execution----------------------------------

Exec Payment_wallet_cashback @mobile_num = '01234567892',@payment_id = 8, @benefit_id = 3

-----------------------Initiate_balance_payment Procedure execution----------------------------------

Exec Initiate_balance_payment @mobile_num = '01234567890', @amount =100, @payment_method = 'cash'

-----------------------Redeem_voucher_points Procedure execution----------------------------------

Exec Redeem_voucher_points @mobile_num = '01234567890', @voucher_id = 3 






------------------------------------------------------------------test--------------------------------------------
-- Insert data into Customer_Profile
INSERT INTO Customer_Profile (nationalID, first_name, last_name, email, address, date_of_birth)
VALUES 
(1, 'John', 'Doe', 'john.doe@example.com', '123 Elm Street', '1980-05-15'),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '456 Oak Street', '1990-08-21'),
(3, 'Michael', 'Brown', 'michael.brown@example.com', '789 Pine Street', '1975-02-11');

SELECT* FROM Customer_Profile

-- Insert data into Customer_Account
select * from customer_account                           --se-(account_type = 'postpaid' or account_type = 'prepaid' or account_type = 'pay-as-you-go' ),

INSERT INTO customer_account (mobileNo, pass ,balance, account_type, start_date, status, points , nationalID)
VALUES 
-- Accounts for John Doe
('01234567890', 'password123',100.0, 'prepaid', '2023-01-01', 'active', 0, 1),
('02345678901', 'password456',50.0, 'postpaid', '2023-02-01', 'onhold', 20, 1),
-- Accounts for Jane Smith   ),---
('03456789012', 'password789', 200.0, 'pay-as-you-go', '2023-03-01', 'active', 15, 2),
('04567890123', 'password012', 150.0, 'prepaid', '2023-04-01', 'onhold', 5, 2),
                             --
-- Accounts for Michael Brown),---
('05678901234', 'password345', 75.0, 'postpaid', '2023-05-01', 'active', 10, 3),
('06789012345', 'password678', 90.0, 'pay-as-you-go', '2023-06-01', 'onhold', 25, 3);
                             ---
SELECT* FROM Customer_Account

-- Insert data into Service_Plan
INSERT INTO Service_Plan (SMS_offered, minutes_offered, data_offered, name, price, description)
VALUES 
(100, 500, 5, 'Plan A', 30, 'Basic Plan'),
(200, 1000, 10, 'Plan B', 50, 'Standard Plan'),
(300, 1500, 15, 'Plan C', 70, 'Premium Plan');

SELECT*FROM Service_Plan

-- Insert data into Subscription
INSERT INTO Subscription (mobileNo, planID, subscription_date, status)
VALUES 
('01234567890', 1, '2023-01-15', 'active'),
('02345678901', 2, '2023-02-15', 'onhold'),
('03456789012', 3, '2023-03-15', 'active'),
('04567890123', 1, '2023-04-15', 'onhold'),
('05678901234', 2, '2023-05-15', 'active'),
('06789012345', 3, '2023-06-15', 'onhold');

SELECT* FROm Subscription


-- Insert data into Plan_Usage
INSERT INTO Plan_Usage (start_date, end_date, data_consumption, minutes_used, SMS_sent, mobileNo, planID)
VALUES 
('2023-01-01', '2023-01-31', 2, 100, 10, '01234567890', 1),
('2023-02-01', '2023-02-28', 4, 200, 20, '02345678901', 2),
('2023-03-01', '2023-03-31', 6, 300, 30, '03456789012', 3),
('2023-04-01', '2023-04-30', 8, 400, 40, '04567890123', 1),
('2023-05-01', '2023-05-31', 10, 500, 50, '05678901234', 2),
('2023-06-01', '2023-06-30', 12, 600, 60, '06789012345', 3);

SELECT * FROM Plan_Usage

-- Insert data into Payment
INSERT INTO Payment (amount, date_of_payment, payment_method, status, mobileNo)
VALUES 
(30.0, '2023-01-10', 'cash', 'successful', '01234567890'),
(50.0, '2023-02-10', 'credit', 'pending', '02345678901'),
(70.0, '2023-03-10', 'cash', 'rejected', '03456789012'),
(90.0, '2023-04-10', 'credit', 'successful', '04567890123'),
(110.0, '2023-05-10', 'cash', 'pending', '05678901234'),
(130.0, '2023-06-10', 'credit', 'successful', '06789012345');

SELECT* FROM Payment

-- Insert data into Process_Payment
INSERT INTO Process_Payment (paymentID, planID)
VALUES 
(1, 1),
(2, 2),
(3, 3);

SELECT* FROM Process_Payment


-- Insert data into Wallet
INSERT INTO Wallet (current_balance, currency, last_modified_date, nationalID, mobileNo)
VALUES 
(100.0, 'USD', '2023-01-05', 1, '01234567890'),
(200.0, 'USD', '2023-02-05', 2, '03456789012'),
(150.0, 'USD', '2023-03-05', 3, '05678901234');


SELECT* FROM Wallet
DELETE FROM Wallet

-- Insert data into Transfer_money
INSERT INTO Transfer_money (walletID1, walletID2, amount, transfer_date)
VALUES 
(1, 2, 50.0, '2023-01-20'),
(2, 3, 70.0, '2023-02-20'),
(1, 3, 100.0, '2023-03-20'),
(2, 1, 120.0, '2023-04-20'),
(3, 2, 80.0, '2023-05-20'),
(3, 1, 90.0, '2023-06-20');
SELECT* FROM Transfer_money


-- Insert data into Benefits
INSERT INTO Benefits (description, validity_date, status, mobileNo)
VALUES 
('10% Discount', '2023-12-31', 'active', '01234567890'),
('Free SMS', '2023-11-30', 'expired', '02345678901'),
('Double Data', '2023-10-31', 'active', '03456789012'),
('Extra Minutes', '2023-09-30', 'expired', '04567890123'),
('Cashback', '2023-08-31', 'active', '05678901234'),
('Special Plan', '2023-07-31', 'expired', '06789012345');

SELECT* FROM Benefits


-- Insert data into Points_Group
INSERT INTO Points_Group (benefitID, pointsAmount, PaymentID)
VALUES 
(1, 50, 1),
(2, 30, 2),
(3, 70, 3),
(4, 20, 4),
(5, 90, 5),
(6, 60, 6);

SELECT* FROM Points_Group


-- Insert data into Exclusive_Offer
INSERT INTO Exclusive_Offer (benefitID, internet_offered, SMS_offered, minutes_offered)
VALUES 
(1, 1, 10, 50),
(2, 2, 20, 100),
(3, 3, 30, 150),
(4, 4, 40, 200),
(5, 5, 50, 250),
(6, 6, 60, 300);

SELECT* FROM Exclusive_Offer
DELETE FROM Exclusive_Offer


-- Insert data into CashBack
INSERT INTO CashBack (benefitID, walletID, amount, credit_date)
VALUES 
(1, 1, 3.0, '2023-01-11'),
(3, 2, 7.0, '2023-02-11'),
(5, 3, 11.0, '2023-03-11');


SELECT* FROM CashBack
DELETE FROM CashBack
TRUNCATE TABLE Cashback


-- Insert data into Plan_Provides_Benefits
INSERT INTO Plan_Provides_Benefits (benefitID, planID)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 1),
(5, 2),
(6, 3);

SELECT* FROM Plan_Provides_Benefits

-- Insert data into Shop
INSERT INTO Shop (name, category)
VALUES 
('Tech World', 'Electronics'),
('Fashion Hub', 'Clothing'),
('Gadget Store', 'Electronics'),
('Home Essentials', 'Furniture'),
('Books & More', 'Books'),
('Game Corner', 'Gaming');


SELECT* FROM Shop
DELETE FROM Shop


-- Insert data into Physical_Shop
INSERT INTO Physical_Shop (shopID, address, working_hours)
VALUES 
(1, 'Tech Lane 123', '9 AM - 9 PM'),
(2, 'Fashion Street 456', '10 AM - 8 PM'),
(3, 'Gadget Ave 789', '9 AM - 10 PM'),
(4, 'Home St 321', '8 AM - 6 PM'),
(5, 'Book Blvd 654', '9 AM - 7 PM'),
(6, 'Game Road 987', '10 AM - 9 PM');

SELECT* FROM Physical_Shop



-- Insert data into E_shop
INSERT INTO E_shop (shopID, URL, rating)
VALUES 
(1, 'https://www.techworld.com', 5),
(2, 'https://www.fashionhub.com', 4),
(3, 'https://www.gadgetstore.com', 3),
(4, 'https://www.homeessentials.com', 4),
(5, 'https://www.booksandmore.com', 5),
(6, 'https://www.gamecorner.com', 5);

SELECT* FROM E_shop


-- Insert data into Voucher
INSERT INTO Voucher (value, expiry_date, points, mobileNo, shopID, redeem_date)
VALUES 
(100, '2023-12-31', 20, NULL, 1, NULL),  -- Not redeemed
(50, '2023-11-30', 10, NULL, 2, NULL),   -- Not redeemed
(200, '2023-10-31', 30, '01234567890', 3, '2023-09-01'),
(150, '2023-09-30', 25, '03456789012', 4, '2023-08-01'),
(75, '2023-08-31', 15, '05678901234', 5, '2023-07-01'),
(125, '2023-07-31', 22, '04567890123', 6, '2023-06-01');


SELECT* FROM Voucher
DELETE FROM Voucher


-- Insert data into Technical_Support_Ticket
INSERT INTO Technical_Support_Ticket (mobileNo, Issue_description, priority_level, status)
VALUES 
('01234567890', 'Internet not working', 1, 'Open'),
('02345678901', 'Billing issue', 2, 'In Progress'),
('03456789012', 'Cannot make calls', 3, 'Resolved'),
('04567890123', 'Slow connection', 1, 'Open'),
('05678901234', 'Account locked', 2, 'In Progress'),
('06789012345', 'Plan activation failed', 3, 'Resolved');


SELECT* FROM Technical_Support_Ticket
DELETE FROM Technical_Support_Ticket




--test allCustomerAccounts view
SELECT* FROM Customer_Profile;
SELECT* FROM Customer_Account
SELECT* FROM allCustomerAccounts;

--test allServicePlans view
SELECT* FROM Service_Plan;
SELECT* FROM allServicePlans;

--test allBenefits view
SELECT* FROM Benefits;
SELECT* FROM allBenefits;

--test AccountPayments view
SELECT* FROM Customer_Account;
SELECT* FROM Payment;
SELECT* FROM AccountPayments;

--test allShops view
SELECT* FROM Shop;
SELECT* FROM allShops;

--test allResolvedTickets view
SELECT* FROM Technical_Support_Ticket;
SELECT* FROM allResolvedTickets;

--test CustomerWallet view
SELECT* FROM Customer_Profile;
SELECT* FROM Wallet;
Select* FROM CustomerWallet;

--test E_shopVouchers view
SELECT* FROM E_shop;
SELECT * FROM Voucher;
SELECT* FROM E_shopVouchers;

--test PhysicalStoreVouchers view
SELECT* FROM Physical_Shop;
SELECT* FROM Voucher;
SELECT* FROM PhysicalStoreVouchers;

--test Num_of_cashback view
SELECT* FROM CashBack;
SELECT*FROM Wallet;
SELECT* FROM Num_of_cashback;

--test Account_Plan Procedure
SELECT* FROM Customer_Account;
SELECT* FROM Service_Plan;
SELECT* FROM Subscription;
EXEC Account_Plan;

--test Benefits_Account procedure
SELECT* FROM Benefits;
SELECT* FROM Plan_Provides_Benefits;
SELECT* FROM Subscription;
EXEC Benefits_Account @mobile_num = '01234567890',@plan_id= 1;

--test for Account_Plan_date
SELECT* FROM Customer_Account
SELECT* FROM Subscription
SELECT* FROM Service_Plan
SELECT* FROM Account_Plan_date('2023-01-15',1)

--test for Account_Usage_Plan
SELECT* FROM Customer_Account
SELECT* FROM Plan_Usage
SELECT* FROM Subscription
SELECT* FROM Account_Usage_Plan('01234567890','2023-01-01')

--test Benefits_Account procedure
SELECT* FROM Benefits;
SELECT* FROM Plan_Provides_Benefits;
SELECT* FROM Subscription;
EXEC Benefits_Account @mobile_num= '01234567890',@plan_id= 1;

--test for Account_SMS_Offers
SELECT* FROM Exclusive_Offer
SELECT* FROM Customer_Account
SELECT* FROM Benefits
SELECt* FROM Account_SMS_Offers('03456789012')

--test Account_Payment_Points procedure////////////////////////////////////////// ?????????
SELECT * FROM Payment WHERE status = 'successful';
SELECT* FROM Points_Group;
DECLARE @TotalTransactions INT,
        @TotalPoints INT;
EXEC Account_Payment_Points  '04567890123',  @TotalTransactions OUTPUT,   @TotalPoints OUTPUT;
SELECT @TotalTransactions AS TotalNumberOfTransactions, @TotalPoints AS TotalAmountOfPoints;

--test Wallet_Cashback_Amount
SELECT* FROM CashBack
SELECT* FROM Plan_Provides_Benefits 
DECLARE @CashbackAmount DECIMAL(10, 2);
    SELECT @CashbackAmount = dbo.Wallet_Cashback_Amount(1, 1);
    SELECT @CashbackAmount AS CashbackAmount;

--test Wallet_Transfer_Amount
SELECT* FROM Transfer_money

DECLARE @AverageAmount DECIMAL(10, 2);
    SELECT @AverageAmount = dbo.Wallet_Transfer_Amount(2, '2023-01-01', '2023-05-01');
    SELECT @AverageAmount AS AverageTransactionAmount;

--test for Wallet_MobileNo
SELECT* FROM Wallet
SELECT* FROM Customer_Account
SELECT dbo.Wallet_MobileNo('01234567890'); --return 1
SELECT dbo.Wallet_MobileNo('05678901234'); --return 1
SELECT dbo.Wallet_MobileNo('07890123456'); --return 0
SELECT dbo.Wallet_MobileNo('08901234567'); --return 0

--test Total_Points_Account
SELECT* FROM Points_Group
SELECT* FROM Customer_Account

DECLARE @TotalPoints1 INT;
EXEC Total_Points_Account @MobileNo = '01234567890', @TotalPoints = @TotalPoints1 OUTPUT;
SELECT @TotalPoints1 AS TotalPoints;  -- returns 50

DECLARE @TotalPoints INT;
EXEC Total_Points_Account @MobileNo = '02345678901', @TotalPoints = @TotalPoints OUTPUT;
SELECT @TotalPoints AS TotalPoints2;  --return 30////////////////////////////////////?????????????????????????

--test for AccountLoginValidation

SELECT * FROM customer_account
SELECT dbo.AccountLoginValidation('01234567890' , 'password123')

--test for Consumption
SELECT * FROM Plan_Usage WHERE planID = 1
SELECT * FROM Service_Plan
SELECT * FROM dbo.Consumption('Plan A', '2023-01-01' , '2023-04-10')

--test for Unsubscribed_Plans
SELECT * FROM Service_Plan
SELECT * FROM Subscription WHERE mobileNo = '01234567890'
EXEC Unsubscribed_Plans '01234567890'

--test for Usage_Plan_CurrentMonth
SELECT * FROM Plan_Usage
SELECT * FROM Subscription WHERE mobileNo = '01234567890'
SELECT * FROM dbo.Usage_Plan_CurrentMonth('01234567890')

--test for Cashback_Wallet_Customer
SELECT * FROM Customer_Account
SELECT * FROM Wallet
SELECT * FROM Cashback
SELECT * FROM dbo.Cashback_Wallet_Customer(1)

--test for Ticket_Account_Customer
SELECT * FROM Customer_Account
SELECT * FROM Technical_Support_Ticket
DECLARE @tck int = 0
EXEC Ticket_Account_Customer 1 , @tck output------------------??????????????????
PRINT @tck

--test for Account_Highest_Voucher
SELECt * FROM Customer_Account
SELECT * FROM Voucher
DECLARE @vouch int
EXEC Account_Highest_Voucher '01234567890', @vouch output -----------------------------------????????????????????????
PRINT @vouch

--test for Remaining_plan_amount
SELECT * FROM Service_Plan
SELECt * FROM Payment
SELECT * FROM Process_Payment
INSERT INTO Process_Payment VALUES (6,3) , (2,3)
SELECT dbo.Remaining_plan_amount('06789012345', 'Plan C')

--test for Extra_plan_amount
SELECT dbo.Extra_plan_amount('02345678901', 'Plan C')

--test for Top_Successful_Payments
SELECT * FROM Payment
INSERT INTO Payment VALUES(60, '2023-01-10' , 'cash' , 'successful' , '01234567890')

--test for Subscribed_plans_5_Months
SELECT * FROM Subscription
SELECT * FROM Service_Plan
INSERT INTO Subscription VALUES ('01234567890' , 2 , '2024-7-30' , 'active')
SELECT * FROM dbo.Subscribed_plans_5_Months('01234567890')

--test for Initiate_plan_payment
EXEC Initiate_plan_payment '02345678901' , 50.0 , 'cash' , 2
SELECT * FROM Payment
SELECT * FROM Service_Plan
SELECT * FROM Subscription

--test for Payment_wallet_cashback
--EXEC Payment_wallet_cashback 
SELECT * FROM Cashback
SELECT * FROM Payment
SELECT * FROM Benefits
SELECT * FROM Wallet


--test for Initiate_balance_payment
SELECT * FROM Payment
SELECt * FROM Customer_Account
EXEC Initiate_balance_payment '01234567890' , 110.0 , 'credit' 

--test for Redeem_voucher_points
INSERT INTO Voucher VALUES (100000 , DATEADD(YEAR, 1, GETDATE()) , 1000 , '01234567890' , 2 , Null)
EXEC Redeem_voucher_points '01234567890' , 7
SELECT * FROM Customer_Account
SELECT * FROM Voucher
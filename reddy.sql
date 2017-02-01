--1)

create proc customerkey_givendate (@customer_key int, @startdate date, @enddate date)
as 
begin
	select c.customer_name,b.branch_desc,b.branch_city,fb.pro_no,fb.billed_amount,fb.paid_amount,fb.entry_date
	from sqlnotes..freight_bill fb join SQLNotes ..branch b on fb.branch_key = b.branch_key
								   join SQLNotes ..customer c on b.customer_key = c.customer_key
	where b.customer_key=@customer_key and
		  fb.entry_date between @startdate and @enddate
end  

exec customerkey_givendate 5092,'01-01-2009','01-01-2010'

--2)

select carrier_key  from freight_bill

create proc freightbill_statuscode (@carrirerkey int,@customer_key int,@startdate date, @enddate date)
as
begin
	select c.customer_name,b.branch_desc,b.branch_city,fb.pro_no,fb.billed_amount,fb.freight_bill_status_code,fb.entry_date,fb.ship_date,ce.carrier_name
	from SQLNotes..freight_bill fb join SQLNotes..carrier ce on fb.carrier_key= ce.carrier_key
								   join SQLNotes..branch b on fb.branch_key = b.branch_key
								   join SQLNotes..customer c on c.customer_key= b.customer_key
	where ce.carrier_key=@carrirerkey and b.customer_key=@customer_key and fb.entry_date between @startdate and @enddate
end

 exec freightbill_statuscode 1627,5092,'01-01-2009','01-01-2010'

 --3)

 select country_code
 from consignee

 create proc shipperinformation (@shipper_country char(2),@consinee_country char(2))
 as
 begin
	  select fb.pro_no,fb.billed_amount,fb.cargo_type,fb.transportation_mode_type,o.shipper_name,o.shipper_city,o.shipper_state,ci.consignee_name,ci.consignee_city,ci.consignee_state
	  from SQLNotes..freight_bill fb join consignee ci on fb.consignee_key=ci.consignee_key
									 join origin o on fb.origin_key=o.origin_key
									 
	  where o.country_code=@shipper_country and ci.country_code=@consinee_country

 end

 exec shipperinformation 'us','us'

 --4)

  select * from [dbo].[freight_bill_status]


 create proc freightbillstatus (@freightbill char(5))
 as
 begin
	   select fb.pro_no,fb.billed_amount,fac.accounting_code_desc,fac.amount,fbs.freight_bill_status_code,fb.discount_amount
	   from SQLNotes..freight_bill fb join freight_bill_accounting_code fac on fb.freight_bill_key= fac.freight_bill_key
								      join freight_bill_status fbs on fbs.freight_bill_status_code = fb.freight_bill_status_code

	   where fbs.freight_bill_status_code= @freightbill
 end

 exec freightbillstatus 'a'

 --5)

select * from [dbo].[customer]


 create proc customerkey(@customer_key int)
 as
 begin
	  select customer_name,branch_desc,
	  count(freight_bill_key) as 'total no  bills',
	  sum(billed_amount) as tot_billed_amount,
	  sum(paid_amount) as tot_paid_amount,
	  avg(billed_amount) as averagebilledamount
				
	  from customer c join branch b on c.customer_key = b.customer_key
					  join freight_bill fb on fb.branch_key=b.branch_key
	  where c.customer_key=@customer_key
	  group by customer_name,branch_desc
end

exec customerkey 5092

--6) 


select  cargo_type from [dbo].[freight_bill]
select division_desc from [dbo].[division]

select * from 
[dbo].[freight_bill_accounting_code]

alter proc cargotypeinternaation (@cargotype char(20))
as
begin
	select customer_name,branch_desc,region_desc,division_desc,pro_no,billed_amount,accounting_code_desc,po_number,cargo_type
	from customer c join branch b on c.customer_key = b.customer_key
					join freight_bill f on f.branch_key=b.branch_key
					join freight_bill_accounting_code fb on fb.freight_bill_key = f.freight_bill_key
					join division d on d.division_key=b.division_key
					join region r on r.division_key = d.division_key
	where cargo_type=@cargotype 
end 

exec cargotypeinternaation 'sp'


--7)

create proc carrierkey (@carrierkey int)
as 
begin
   if @carrierkey=-1
      select carrier_key,carrier_name,carrier_city,country_code as carriercountry
	  from carrier
   else
      select carrier_key,carrier_name,carrier_city,country_code as carriercountry
	  from carrier
	where carrier_key=@carrierkey
end

exec carrierkey 1022
exec carrierkey -1


--8)
select * from [dbo].[carrier]

create proc customercarrier (@customerkey int,@startdate date,@enddate date ,@carrierkey int)
as
begin
	select
	   pro_no , billed_amount , paid_amount , 
	   Branch_desc, Branch_city ,
       r.region_desc as Regionname , d.division_desc as devisionname , Customer_name, 
       shipper_name,shipper_city , shipper_state ,o.country_code as shipper_country ,
       consignee_name,co.consignee_city , Consignee_state, co.country_code as consignee_country, 
       Carrier_name, carrier_CITY , ca.country_code as carrier_country,
       currency_type , accounting_code_desc, amount 
from branch b join freight_bill fb on b.branch_key=fb.branch_key
					  join customer cu on cu.customer_key=b.customer_key
					  join consignee co on co.customer_key=b.customer_key
					  join origin o on o.customer_key=b.customer_key
					  join carrier ca on ca.carrier_key=fb.carrier_key
					  join freight_bill_accounting_code fba on fba.freight_bill_key=fb.freight_bill_key
					  join division d on d.customer_key=cu.customer_key
					  join region r on r.division_key=d.division_key
where @customerkey=cu.customer_key and 
	  @startdate=entry_date  and 
	  @enddate=ship_date and 
	  @carrierkey=ca.carrier_key
end

--9)


create proc DBO.SP_proc9 (@StartDate date,@EndDate date) as
SELECT DATEDIFF(Day,@StartDate,@EndDate) AS DiffDate
begin

if 'DiffDate' between 0 and 10
         select customer_name,count(pro_no)
		 from customer,freight_bill
		 where @startdate=entry_date and @enddate=ship_date

end

--10) 

create  proc displayemp (@empno int )as
begin
select e3.employee,isnull(e3.manager,'0')as manager,e.job,e.hiredate,e.salary,
isnull(e.comm,0) as comm ,dname,location,grade
from (select e1.ename as employee,e2.ename as manager
from employee e1  left join employee e2 on e1.mgr=e2.empno)e3 
join employee e on e3.employee=e.ename
join department d on d.departmentNo=e.DeptNO
left join salarygrade s on e.salary between s.lowsal and s.highsal
where e.empno=@empno
end

exec displayemp 7369





									



create user shehreen identified by oliveoil1000;
grant all privileges to shehreen;

disc;

connect shehreen/oliveoil1000;


set linesize 200;
set serveroutput on size 100000;



create table inventory(
	id number primary key,
	name varchar2(20),
	amount number,
	price number
);

create table inventoryWarning(
	id number primary key,
	name varchar2(20),
	amount number,
	price number	
);
	

create table menu(
	id number primary key,
	name varchar2(20),
	price number,
	amount number
);


create table cart(
	id number primary key,
	name varchar2(20),
	price number,
	amount number
);

create sequence inventory_seq start with 1;

create or replace trigger id_increment
before insert on inventory
for each row

begin
	select inventory_seq.nextval
	into :new.id
	from dual;
end;
/

create sequence menu_seq start with 1;

create or replace trigger id_increment_menu
before insert on menu
for each row

begin
	select menu_seq.nextval
	into :new.id
	from dual;
end;
/

drop table customer;

create table customer(
	customer_id number primary key,
	name varchar2(20),
	phone_no number,
	id_generation_date date
);

create table temporary_customer(
	customer_id number
);

drop sequence customer_seq;
create sequence customer_seq start with 1;

create or replace trigger id_increment_customer
before insert on customer
for each row
begin
	select customer_seq.nextval
	into :new.customer_id
	from dual;
end;
/


drop trigger lowAmount;

create or replace trigger lowAmount
before update on inventory
for each row
when (new.amount<11)
declare
	item_id number;
	amount number;
	price number;
	name varchar2(20);
begin
	amount:= :new.amount;

	item_id:= :old.id;
	price:= :old.price;
	name:= :old.name;
	if :old.amount>10 and :new.amount<11 then
		insert into inventoryWarning values(item_id,name,amount,price);
	else
		update inventoryWarning
		set amount= :new.amount
		where name=name;
	end if;	
end;
/


drop procedure updateChefInventory;

create or replace procedure updateChefInventory(item_id in number, retrieve_amount in number,result out varchar) is
check_amount number;
final_amount number;

begin
	
	select amount into check_amount
	from inventory
	where id=item_id;

	if check_amount<retrieve_amount then
		result:='Low Amount';
	else
		final_amount:=check_amount-retrieve_amount;
		
		update inventory
		set amount= final_amount
		where id=item_id;

		result:='Successful';
	end if;
	dbms_output.put_line(result);
end;
/

drop procedure updateManagerInventory;

create or replace procedure updateManagerInventory(item_id in number, added_amount in number,result out varchar) is
available_amount number;
final_amount number;

begin
	select amount into available_amount
	from inventoryWarning
	where id=item_id;

	final_amount := available_amount + added_amount;
		
	update inventory
	set amount= final_amount
	where id=item_id;

	delete from inventoryWarning
	where id = item_id;

	result:='Successful';
	dbms_output.put_line(result);

	
end;
/

CREATE OR REPLACE PROCEDURE deleteInventory(x IN number)
AS
BEGIN
    DELETE FROM inventory WHERE id = x;

END;
/

CREATE OR REPLACE PROCEDURE deleteMenu(x IN number)
AS
BEGIN
    DELETE FROM menu WHERE id = x;

END;
/

create or replace procedure updateManagerMenu(item_id in number, new_price in number,result out varchar) is
curr_price number;
final_price number;

begin

	update menu
	set price= new_price
	where id=item_id;

	result:='Successful';
	dbms_output.put_line(result);

	
end;
/







-- ----------------------------------------------------------------------------------
-- Customer ID fetching and/or creating when loging in
-- Has exception
-- ----------------------------------------------------------------------------------

create or replace procedure getcustID(name in varchar2, pnum in number, cid out number)
as
tot number;
begin 
	select count(*) into tot from customer where phone_no = pnum;
	if (tot= 0) then
		insert into customer (name, phone_no, id_generation_date) values (name, pnum, sysdate);
		select customer_id into cid from customer where phone_no = pnum;
	else
		select customer_id into cid from customer where phone_no = pnum;
	end if;
	insert into temporary_customer values(cid);
end;
/
	 


show errors;






-- -------------------------------------------------------------------------------------------------------------------------------------
-- TOTAL SALES
-- Has Nested table, Array Collection -- could've been done in another arguably simpler way. But we like FANCY SHOW OFFS! (¬‿¬) :3 
-- -------------------------------------------------------------------------------------------------------------------------------------


-- creating CART-type data
-- you must put '/' afterwards. otherwise doesn't run. weird! ¯\_(ツ)_/¯ 
create or replace type aLaCarte_data_type as Object(
  -- does id need to be primary key here? like the cart table? 
	item_id number,
	name varchar2(20),
	price number,
	amount number
);
/

-- creating VARRAY(20) type which consists of aLaCarte_data_type. 
-- this is be used to handle list from Java and store them in a nested table.
-- you must put '/' afterwards. otherwise doesn't run. weird! ¯\_(ツ)_/¯ 
create or replace type aLaCarte_table_type as varray(20) of aLaCarte_data_type;
/



drop table total_sales;

-- nested table inside
-- total_payable is the price after discounts. 
-- had_disc is serving as boolean type (THERES NO BOOLEAN IN ORACLE! UGH!), 1 = customer had discount on this date and/or slip number. 0 = no  
create table total_sales(
    slip_no number primary key,
    order_date date,
    customer_id number,
    total_payable number(10, 2),
    had_disc number,
    items_ordered aLaCarte_table_type,
    foreign key (customer_id) references customer(customer_id)
);


-- ---------------------------------------------------------------------------------------------------------------------------
-- *** COUPLE OF HELPFUL LEARNING POINTS ***

-- 1. this is how we would have manually inserted data into TOTAL_SALES with NESTED TABLE:

-- insert into total_sales values( 1, sysdate, 101, 487.5, true, 
--  aLaCarte_table_type( aLaCarte_data_type(901,'burger', 400, 2),  aLaCarte_data_type(906, 'chips', 100, 10) ) 
--  );


-- 2. this is how we would/will  DE-NEST/UN-NEST the TOTAL_SALES table with NESTED TABLE:

-- select x.slip_no, x.order_date, x.customer_id, x.total_payable, x.had_disc, y.*
-- from total_sales x, table(x.items_ordered) y
-- where slip_no = 89;
-- ---------------------------------------------------------------------------------------------------------------------------



create sequence total_sales_seq start with 1;


-- total_sales FUNCTION; returns SLIP_NUMBER
-- m_had_disc serves as BOOLEAN, 1 = customer is getting discount, 0 = customer got no discount 
create or replace function insert_into_total_sales (
  m_customer_id in number, m_total_payable in number, m_had_disc in number, m_items_ordered in aLaCarte_table_type)
  return number
  as

  m_slip_no number;
  m_order_date date;

  begin

    select total_sales_seq.nextval into m_slip_no from dual;
    dbms_output.put_line('total_sales_seq: ' || m_slip_no);
    m_order_date := sysdate;

    insert into total_sales(slip_no, order_date, customer_id, total_payable, had_disc, items_ordered)
    values (m_slip_no, m_order_date, m_customer_id, m_total_payable, m_had_disc, m_items_ordered);

    return m_slip_no;

  end;
/

show errors;






-- -----------------------------------------------------------------------------------
-- DISCOUNT
-- Has cursor in the procedure
-- -----------------------------------------------------------------------------------

drop table discount;

create table discount(
    disc_type varchar2(20) primary key,
    eligibility number,
    disc_percent number(5, 2)
);

-- eligibility is the differentiating amount
-- for example, 0% is applicable from 0 to 1499
-- 1.5% is applicable from 1500 to 22499
-- 2.5% is applicable from 2500 to 3499
-- 3.5% is appliable from 3500 t0 4999
-- 5.0% is appliable from 5000 and above

insert into discount values('0.0', 0, 0.0);
insert into discount values('1.5', 1500, 1.5);
insert into discount values('2.5', 2500, 2.5);
insert into discount values('3.5', 3500, 3.5);
insert into discount values('5.0', 5000, 5.0);


-- select * from discount;


-- getLastDiscDate function; returns the last date of getting discounted; if nothing found returns id_generation_date from customer table

create or replace function getLastDiscDate(m_customer_id in number)
return date
as
m_lastDiscDate date;
begin

  select max(order_date) into m_lastDiscDate
  from total_sales
  where customer_id = m_customer_id and had_disc = 1;

  if m_lastDiscDate is null then
    dbms_output.put_line('no last discount date found. returning id_genration_date...');
    select id_generation_date into m_lastDiscDate
    from customer
    where customer_id = m_customer_id;
  end if;
  return m_lastDiscDate;

end;
/

show errors;




-- getDisc procedure. in the OUT PARAM, reutnrs the discounted percentage
create or replace procedure getDisc(m_customer_id in number, m_disc_percent out varchar2)
as

m_sum_total_payable number(10, 2);
m_lastDiscDate date;
-- cursor must be sorted on eligibility criteria in ascending/descending order CAREFULLY! 
cursor cursor_disc is select * from discount order by eligibility desc;

begin

  m_disc_percent := 0.0;

  m_lastDiscDate := getLastDiscDate(m_customer_id);

  -- TODO: check for 30 days time period. Still okay if check is not performed

  select sum(total_payable) into m_sum_total_payable 
  from total_sales
  where customer_id = m_customer_id and order_date > m_lastDiscDate;

  if m_sum_total_payable is null then
    m_sum_total_payable := 0.0;
  end if;

  -- cursor 
  for rec in cursor_disc loop
    if m_sum_total_payable >= rec.eligibility then
      m_disc_percent := rec.disc_percent;
      exit;
    end if;
  end loop;

-- no return because this is a procedure. discount percent is sent with the OUT PARAM. 

end;
/

show errors;


--------------------
show items of total_sales table
--------------------

select x.slip_no, x.order_date, x.customer_id, x.total_payable, x.had_disc, y.*
from total_sales x, table(x.items_ordered) y;

commit;









	
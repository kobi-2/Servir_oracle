
create user shehreen identified by oliveoil1000;
grant all privileges to shehreen;

disc;

connect shehreen/oliveoil1000;



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

create table customer(
	customer_id number primary key,
	name varchar2(20),
	phone_no number,
	id_generation_date date
);

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

create or replace function getCustomerID (m_name in varchar2, m_phone_no in number)
return number
as
c_id number;
begin

-- selecting customer id. If not found, should throw exception
  select customer_id into c_id from customer where phone_no = m_phone_no;
  return c_id;

  exception

    when no_data_found then
    -- throws exception for no entry found. so  creating one and returning that
      dbms_output.put_line('no customer id found. creating new one...');
      insert into customer(name, phone_no, id_generation_date) values(m_name, m_phone_no, sysdate);
      select customer_id into c_id from customer where phone_no = m_phone_no;
      return c_id;

    when others then
      dbms_output.put_line('Something Went Wrong!');
      return -1;
      -- -1 is serving as an error code

end;
/


show errors;











	
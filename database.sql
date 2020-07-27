
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

create sequence inventoryWarning_seq start with 1;

create or replace trigger id_increment_item_warning
before insert on inventoryWarning
for each row
begin
	select inventoryWarning_seq.nextval
	into :new.id
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
	
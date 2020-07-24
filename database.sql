
create user shehreen identified by oliveoil1000;
grant all privileges to shehreen;

disc;

connect shehreen/oliveoil1000;



create table inventory(
	id number primary key,
	name varchar2(20),
	amount number,
	supplier_id number unique
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
	
USE SAKILA;

select first_name, last_name, email from sakila.customer
where active = 1;

#avg for each customer
select c.customer_id, concat(c.first_name, c.last_name) as 'customer_name', avg(p.amount) as 'average_payment'
from sakila.customer as c
join sakila.payment as p on c.customer_id = p.customer_id
group by customer_id;


#Select the name and email address of all the customers who have rented the "Action" movies.
select c.email, concat(c.first_name, c.last_name) as 'customer_name', cat.name from sakila.customer as c 
left join sakila.rental as r on c.customer_id = r.customer_id
join sakila.inventory as i on r.inventory_id = i.inventory_id
join sakila.film_category as ca on ca.film_id = i.film_id
join sakila.category as cat on cat.category_id = ca.category_id
where cat.name='Action'
group by c.customer_id;



--               LAB DAY 3 

--              LAB 1 
use sakila;
-- 
select first_name, last_name, email
  from customer
  join rental on customer.customer_id = rental.customer_id
  join inventory on rental.inventory_id = inventory.inventory_id
  join film on film.film_id = inventory.film_id
  join film_category on film_category.film_id = film.film_id
  join category on category.category_id = film_category.category_id
  where category.name = "Action"
  group by first_name, last_name, email;
  
  
-- drop procedure if exists cat_rented_variable; 

drop procedure if exists name_email_category;
delimiter $$

Create Procedure name_email_category (in param1 varchar(100))
begin 
select first_name, last_name, email
     from sakila.customer 
     join sakila.rental on customer.customer_id = rental.customer_id
     join sakila.inventory on rental.inventory_id = inventory.inventory_id
     join sakila.film on film.film_id = inventory.film_id 
     join sakila.film_category on film_category.film_id = film.film_id
     join sakila.category on category.category_id = film_category.category_id
     where category.name collate utf8mb4_general_ci = param1
     group by first_name, last_name, email;
END
 $$
delimiter ; 

call name_email_category('Horror');

end;

-- greater than 60

delimiter $$
create procedure film_count_categories(in num tinyint) 
begin 
select category.name, count(film_id) as num_released
from category 
join film_category on category.category_id = film_category.category_id
group by category.name
having num_released > num; 
END $$ 
delimiter ;

call film_count_categories(60) ;


--                          AFT 

drop procedure if exists total_business_per_store_3;
delimiter //
create procedure total_business_per_store_3 (in param1 tinyint)
begin
	declare total_business float default 0.0;
	select sum(a.amount) into total_business from sakila.payment as a
	join sakila.staff as b on b.staff_id = a.staff_id
	group by b.store_id
    having b.store_id = param1;
    select total_business;
end
//
delimiter ;
call total_business_per_store_3 (1);

-- In the previous query, add another variable flag. If the total sales value for the store is over 30.000, then label it as green_flag, otherwise label is as red_flag


drop procedure if exists sales_by_store_io;
delimiter $$

create procedure sales_by_store_io(in store int)
begin
  declare total_sales_value float default 0.0;
  select round(sum(amount),2) into total_sales_value
  from payment as p
  join store as s on s.manager_staff_id = p.staff_id = p.staff_id
  where s.store_id = store
  group by s.store_id;
  select store, total_sales_value;
  case 
    when total_sales_value < 30000 then "green_flag"
    when total_sales_value >= 30000 then "red_flag" 
    end as flag; 
  end
  $$   
  delimiter ;
  
  call sales_by_store_io(1);
  select @x;
  

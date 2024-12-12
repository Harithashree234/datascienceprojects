create database wallmart;
use wallmart;


-- category
select * from category;
desc category;
alter table category change category category_id varchar(25);
alter table category modify category_id varchar(25); 
alter table category add primary key (category_id); 

-- product
desc product;
select * from product;
alter table product change category_id category_id varchar(25);
alter table product add primary key (product_id); 
alter table product add foreign key (category_id) references category(category_id); 

-- customer
select * from customer;
desc customer;
alter table customer change ï»¿customer_id customer_id varchar(40);
alter table customer add primary key (customer_id);

-- orders
select * from orders;
desc orders;
alter table orders change ï»¿order_id order_id varchar(40);
alter table orders modify column order_id varchar(25); 
alter table orders modify product_id int not null;
alter table orders modify customer_id varchar(40);
alter table orders add primary key (order_id);
alter table orders add foreign key (customer_id) references customer(customer_id);
alter table orders add foreign key (product_id) references product(product_id);

-- Queries

-- joins
select * from customer cu 
join orders o on cu.customer_id=o.customer_id
join product p on o.product_id=p.product_id
join category ca on p.category_id=ca.category_id;

-- 1. Find the date with the highest total sales in the month 
select order_date, sum(o.total_amount) as total_sales
from orders o
group by order_date
order by total_sales desc
Limit 1;

-- 2. To retreive the customers details whose delivery status is processing or cancelled 
select concat(cu.first_name," ",cu.last_name) as customer_name, cu.email, cu.address, 
cu.phone_number, cu.payment_method, o.`status`
from customer cu 
join orders o on cu.customer_id=o.customer_id
join product p on o.product_id=p.product_id
join category ca on p.category_id=ca.category_id
where o.`status`='cancelled' or o.`status`='processing';

-- 3. List all categories and the number of products in each category.
select category.category_name, count(product.product_id) as product_count
from category 
left join product  on category.category_id = product.category_id
group by category.category_id;

-- 4. To retrieve the total stock for each category and the number of products in that category.
select ca.category_id, ca.category_name,
    count(p.product_id) as product_count,
    sum(p.stock_quantity) as total_stock
from category ca
join product p on ca.category_id = p.category_id
group by ca.category_id, ca.category_name
order by total_stock desc;

-- 5. List of customers along with their frequency of order.
select cu.customer_id, concat(cu.first_name," ",cu.last_name) as  customer_name, 
count(o.order_id) as total_orders,
if (count(o.order_id)>=2, 'frequent buyer','Regular Buyer') as frequency_of_purchase
from customer cu
left join orders o on cu.customer_id = o.customer_id
group by cu.customer_id;

-- 6. To retrive the total number of products ordered and the total sales for each category
select c.category_name, count(o.product_id) as total_products_ordered, 
round(sum(o.total_amount),0) as total_sales_amount
from category c
join product p on c.category_id = p.category_id
join orders o on p.product_id = o.product_id
group by c.category_id;

-- 7.  Classify customers into spending tiers based on their total spending.
select cu.customer_id, cu.first_name, cu.last_name,
round(sum(o.total_amount),0) as total_spending,
case
	when sum(o.total_amount) >= 1000 then 'Platinum'
	When sum(o.total_amount) between 500 and 999 then 'Gold'
	when sum(o.total_amount) between 100 and 499 then 'Silver'
	else 'Bronze'
    end as spending_tier
from customer cu
left join  orders o on cu.customer_id = o.customer_id
group by cu.customer_id
order by total_spending desc;

-- 8. Show products and indicate if they are "Best Seller" based on quantity sold.
select p.product_id, p.product_name, sum(o.quantity) as total_quantity_sold,
if (sum(o.quantity)>=10,'Best Seller','Regular') as sales_category
from product p
left join orders o on p.product_id = o.product_id
group by p.product_id
order by total_quantity_sold desc;

-- 9. Customer Payment Method Effectiveness
select cu.payment_method, round(sum(o.total_amount),0) as total_spent,
case 
	when sum(o.total_amount) >= 10000 then 'Very Effective'
	when sum(o.total_amount) between 3000 and 6999 then 'Effective'
	else 'Needs Improvement'
    end as effectiveness
from customer cu
join orders o ON cu.customer_id = o.customer_id
group by cu.payment_method;

-- 10. Comparison of the highest order total for each customer to the average order total.
select cu.customer_id, cu.first_name, cu.last_name,
max(o.total_amount) as max_order,
    (select avg(total_amount) from orders 
     where customer_id = cu.customer_id) as average_order,
    case
        when max(o.total_amount) > (select avg(total_amount) from orders where customer_id = cu.customer_id) 
        then 'Above Average'
        else 'Below Average'
    end as order_comparison
from customer cu
join orders o on  cu.customer_id = o.customer_id
group by cu.customer_id, cu.first_name, cu.last_name;



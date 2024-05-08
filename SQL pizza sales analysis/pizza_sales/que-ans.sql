-- Retrieve total number of orders
SELECT 
    COUNT(order_id)
FROM
    orders;
-- 21350
-- -------------------------------------------------------------------------------------------------
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
-- 817860.05
-- -------------------------------------------------------------------------------------------------
-- Identify the highest-priced pizza.
SELECT 
    pizzas.price, pizza_types.name
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
-- 35.95	The Greek Pizza
-- ------------------------------------------------------------------------------------------------
-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(order_details.order_details_id) AS ct
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY ct DESC
LIMIT 1;
-- L	18526
-- ---------------------------------------------------------------------------------------------------
-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS order_sum
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY order_sum DESC
LIMIT 5;
-- The Classic Deluxe Pizza	2453
-- The Barbecue Chicken Pizza	2432
-- The Hawaiian Pizza	2422
-- The Pepperoni Pizza	2418
-- The Thai Chicken Pizza	2371
-- ----------------------------------------------------------------------------------------------------
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, SUM(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;
-- Classic	14888
-- Veggie	11649
-- Supreme	11987
-- Chicken	11050
-- ----------------------------------------------------------------------------------------------------
-- Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) 
from orders
group by hour(order_time);
-- ----------------------------------------------------------------------------------------------------
select pizza_types.category, count(order_details.order_id)
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;
-- Classic	14579
-- Veggie	11449
-- Supreme	11777
-- Chicken	10815
-- ------------------------------------------------------------------------------
-- Group the orders by date and calculate the average number of pizzas ordered per day.

select count(orders.order_id) as count_orders, orders.order_date
from orders
group by order_date;
-- ------------------------------------------------------------------------------
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(sum_quant)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS sum_quant
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS data_quant;
--     138.4749
-- ------------------------------------------------------------------------------
-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.category,
round(sum(order_details.quantity * pizzas.price) /(SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc;
-- ------------------------------------------------------------------------------
-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over(order by order_date) as cumulative
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;
-- ----------------------------------------------------------------------------
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as ct
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as sales) as salesb
where ct <=3;

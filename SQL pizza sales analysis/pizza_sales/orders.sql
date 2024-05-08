select * from orders;
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

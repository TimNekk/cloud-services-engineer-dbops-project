ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS date_created date DEFAULT current_date;
UPDATE orders o
    SET date_created = od.date_created
    FROM orders_date od
    WHERE o.id = od.order_id;
DROP TABLE IF EXISTS orders_date;

ALTER TABLE product
    ADD COLUMN IF NOT EXISTS picture_url varchar(255);
UPDATE product p
    SET picture_url = pi.picture_url
    FROM product_info pi
    WHERE p.id = pi.product_id;
DROP TABLE IF EXISTS product_info;
CREATE INDEX idx_order_product_order_id ON order_product(order_id);
CREATE INDEX idx_orders_date_created_status ON orders(date_created, status);
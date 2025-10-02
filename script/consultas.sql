-- Consultas
-- =====================

-- 1) Recuperações simples com SELECT: listar produtos
SELECT product_id, sku, name, price FROM products ORDER BY name;

-- 2) Filtros com WHERE: produtos com estoque baixo
SELECT p.product_id, p.name, i.quantity
FROM products p
JOIN inventory i ON p.product_id = i.product_id
WHERE i.quantity < 20
ORDER BY i.quantity ASC;

-- 3) Expressões para atributos derivados: total gasto por pedido
SELECT o.order_id,
       o.order_date,
       ROUND(SUM(oi.line_total),2) AS computed_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date DESC;

-- 4) ORDER BY: clientes por maior gasto total
SELECT c.customer_id, p.name AS customer_name, ROUND(SUM(o.total_amount),2) AS total_spent
FROM customers c
JOIN people p ON c.person_id = p.person_id
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, p.name
ORDER BY total_spent DESC;

-- 5) HAVING: clientes com mais de 1 pedido
SELECT c.customer_id, p.name, COUNT(o.order_id) AS orders_count
FROM customers c
JOIN people p ON c.person_id = p.person_id
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, p.name
HAVING COUNT(o.order_id) > 1
ORDER BY orders_count DESC;

-- 6) Junções complexas: relação de produtos, fornecedores e estoques
SELECT s.supplier_id, pe.name AS supplier_name, pr.product_id, pr.name AS product_name, i.quantity
FROM suppliers s
JOIN people pe ON s.person_id = pe.person_id
JOIN product_suppliers ps ON s.supplier_id = ps.supplier_id
JOIN products pr ON ps.product_id = pr.product_id
LEFT JOIN inventory i ON pr.product_id = i.product_id
ORDER BY pe.name, pr.name;

-- 7) Algum vendedor também é fornecedor?
SELECT pe.person_id, pe.name, pe.email, pe.is_seller, pe.is_supplier
FROM people pe
WHERE pe.is_seller = TRUE AND pe.is_supplier = TRUE;

-- 8) Relação de nomes dos fornecedores e nomes dos produtos
SELECT DISTINCT pe.name AS supplier_name, pr.name AS product_name
FROM suppliers s
JOIN people pe ON s.person_id = pe.person_id
JOIN product_suppliers ps ON s.supplier_id = ps.supplier_id
JOIN products pr ON ps.product_id = pr.product_id
ORDER BY pe.name, pr.name;

-- 9) Top 5 produtos por valor total vendido
SELECT pr.product_id, pr.name, SUM(oi.line_total) AS total_revenue, SUM(oi.quantity) AS total_qty
FROM products pr
JOIN order_items oi ON pr.product_id = oi.product_id
GROUP BY pr.product_id, pr.name
ORDER BY total_revenue DESC
LIMIT 5;

-- 10) Subconsulta: clientes que não possuem pagamento cadastrado
SELECT c.customer_id, pe.name
FROM customers c
JOIN people pe ON c.person_id = pe.person_id
WHERE NOT EXISTS (
    SELECT 1 FROM customer_payments cp WHERE cp.customer_id = c.customer_id
);

-- 11) Vendas por mês (últimos 6 meses)
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS year_month,
       ROUND(SUM(o.total_amount),2) AS total_sales
FROM orders o
WHERE o.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
GROUP BY year_month
ORDER BY year_month DESC;

-- 12) Vendedores que venderam mais de R$1000
SELECT s.seller_id, pe.name AS seller_name, ROUND(SUM(o.total_amount),2) AS seller_total
FROM sellers s
JOIN people pe ON s.person_id = pe.person_id
JOIN orders o ON s.seller_id = o.seller_id
GROUP BY s.seller_id, pe.name
HAVING SUM(o.total_amount) > 1000
ORDER BY seller_total DESC;
-- Criação do Schema (Banco de Dados)
DROP SCHEMA IF EXISTS ecommerce;
CREATE SCHEMA ecommerce;
USE ecommerce;

-- Tabela "people": armazena pessoas físicas/jurídicas, vendedores e fornecedores
CREATE TABLE people (
    person_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30),
    is_seller BOOLEAN DEFAULT FALSE,
    is_supplier BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Clientes: referenciam people; definimos tipo PF/PJ com campos específicos
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    customer_type CHAR(2) NOT NULL,
    cpf VARCHAR(14),        -- para PF
    birth_date DATE,
    cnpj VARCHAR(18),       -- para PJ
    company_name VARCHAR(200),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE CASCADE,
    -- A restrição CHECK é ignorada pelo MySQL, a lógica da aplicação deve garantir a regra
    CONSTRAINT chk_customer_type CHECK ((customer_type = 'PF' AND cpf IS NOT NULL AND cnpj IS NULL)
                                     OR (customer_type = 'PJ' AND cnpj IS NOT NULL AND cpf IS NULL))
);

-- Endereços dos clientes
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    street VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'Brazil',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Formas de pagamento (catálogo)
CREATE TABLE payment_methods (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Pagamentos do cliente
CREATE TABLE customer_payments (
    customer_payment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    card_last4 CHAR(4),
    holder_name VARCHAR(150),
    valid_until DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id)
);

-- Fornecedores
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    supplier_code VARCHAR(50) UNIQUE,
    contact_info TEXT,
    FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE CASCADE
);

-- Produtos
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_price CHECK (price >= 0)
);

-- Associação N:N entre produtos e fornecedores
CREATE TABLE product_suppliers (
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    supplier_product_code VARCHAR(100),
    lead_time_days INT DEFAULT 7,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE
);

-- Estoque (inventory) por produto
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    warehouse VARCHAR(100) DEFAULT 'main',
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    CONSTRAINT chk_quantity CHECK (quantity >= 0)
);

-- Vendedores (sellers)
CREATE TABLE sellers (
    seller_id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT NOT NULL,
    employee_code VARCHAR(50) UNIQUE,
    hire_date DATE,
    FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE CASCADE
);

-- Pedidos (orders)
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    seller_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) DEFAULT 'pending',
    delivery_status VARCHAR(30) DEFAULT 'preparing',
    tracking_code VARCHAR(100),
    shipping_address_id INT,
    total_amount DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id),
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0)
);

-- Itens do pedido
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    discount DECIMAL(5,2) DEFAULT 0,
    line_total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    CONSTRAINT chk_order_items_positive CHECK (unit_price >= 0 AND quantity > 0 AND discount >= 0),
    CONSTRAINT chk_line_total CHECK (line_total = ROUND((unit_price * quantity) - discount,2))
);

-- Pagamentos relacionados ao pedido
CREATE TABLE order_payments (
    order_payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method_id INT,
    amount DECIMAL(12,2) NOT NULL,
    paid_at DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id),
    CONSTRAINT chk_amount CHECK (amount >= 0)
);

-- Indexes para desempenho
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_products_sku ON products(sku);

-- =====================
-- Dados de exemplo (inserts)
-- =====================

-- Pessoas
INSERT INTO people (name, email, phone, is_seller, is_supplier) VALUES
('Maikon Silva', 'maikon@example.com', '+55 11 99999-0001', TRUE, FALSE),
('Loja Central Ltda', 'contato@lojacentral.com.br', '+55 11 3333-4444', FALSE, TRUE),
('Ana Pereira', 'ana.pereira@example.com', '+55 11 99999-0002', FALSE, FALSE),
('Carlos Vendedor', 'carlos.v@ecom.com', '+55 11 99999-0003', TRUE, TRUE),
('Distribuidora XYZ', 'comercial@xyz.com.br', '+55 11 4444-5555', FALSE, TRUE);

-- Customers (PF and PJ)
INSERT INTO customers (person_id, customer_type, cpf, birth_date) VALUES
(3, 'PF', '123.456.789-10', '1990-05-15');

INSERT INTO customers (person_id, customer_type, cnpj, company_name) VALUES
(2, 'PJ', '12.345.678/0001-99', 'Loja Central Ltda');

-- Suppliers (two suppliers reference people 2 and 5)
INSERT INTO suppliers (person_id, supplier_code, contact_info) VALUES
(2, 'SUP001', 'Contato comercial Loja Central'),
(5, 'SUP002', 'Distribuidor oficial');

-- Sellers (Maikon and Carlos as sellers)
INSERT INTO sellers (person_id, employee_code, hire_date) VALUES
(1, 'EMP1001', '2022-01-15'),
(4, 'EMP1002', '2023-06-10');

-- Payment methods
INSERT INTO payment_methods (name, description) VALUES
('Credit Card', 'Cartão de crédito'),
('Boleto', 'Boleto bancário'),
('Pix', 'Pagamento instantâneo Pix');

-- Customer payments (Maikon - PF has two forms)
INSERT INTO customer_payments (customer_id, payment_method_id, card_last4, holder_name, valid_until) VALUES
(1, 1, '4242', 'Maikon Silva', '2026-12-31'),
(1, 3, NULL, NULL, NULL);

-- Produtos
INSERT INTO products (sku, name, description, price) VALUES
('SKU-001', 'Camiseta Algodão', 'Camiseta 100% algodão, tamanho M', 59.90),
('SKU-002', 'Caneca Cerâmica', 'Caneca 300ml com logo', 24.50),
('SKU-003', 'Fone de Ouvido', 'Fone Bluetooth', 199.90),
('SKU-004', 'Teclado Mecânico', 'Switches azuis', 349.00);

-- Supplier-product associations
INSERT INTO product_suppliers (product_id, supplier_id, supplier_product_code, lead_time_days) VALUES
(1, 1, 'LC-TS-01', 5),
(2, 1, 'LC-CAN-05', 7),
(3, 2, 'XYZ-FONE-A1', 10),
(4, 2, 'XYZ-TECL-99', 15);

-- Inventory
INSERT INTO inventory (product_id, quantity, warehouse) VALUES
(1, 120, 'main'),
(2, 40, 'main'),
(3, 10, 'main'),
(4, 5, 'main');

-- Orders and order_items
INSERT INTO orders (customer_id, seller_id, order_date, status, delivery_status, tracking_code, shipping_address_id, total_amount)
VALUES
(1, 1, '2025-09-01 10:15:00', 'completed', 'delivered', 'TRK123456789', NULL, 0),
(1, 2, '2025-09-10 14:22:00', 'completed', 'delivered', 'TRK987654321', NULL, 0),
(2, 2, '2025-08-20 09:00:00', 'processing', 'preparing', NULL, NULL, 0);

-- Add order_items
INSERT INTO order_items (order_id, product_id, unit_price, quantity, discount, line_total) VALUES
(1, 1, 59.90, 2, 0.00, ROUND((59.90 * 2) - 0.00,2)),
(1, 2, 24.50, 1, 0.00, ROUND((24.50 * 1) - 0.00,2)),
(2, 3, 199.90, 1, 20.00, ROUND((199.90 * 1) - 20.00,2)),
(3, 4, 349.00, 1, 0.00, ROUND((349.00 * 1) - 0.00,2));

-- Update orders.total_amount from items 
UPDATE orders o
JOIN (
    SELECT order_id, ROUND(SUM(line_total),2) AS total
    FROM order_items
    GROUP BY order_id
) sub ON o.order_id = sub.order_id
SET o.total_amount = sub.total;

-- Order payments
INSERT INTO order_payments (order_id, payment_method_id, amount, paid_at) VALUES
(1, 1, 144.30, '2025-09-01 10:17:00'),
(2, 3, 179.90, '2025-09-10 14:30:00');

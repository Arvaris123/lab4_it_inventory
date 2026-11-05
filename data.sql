SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS it_inventory
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE it_inventory;

DROP TABLE IF EXISTS equipment_assignment;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS computer_configuration;
DROP TABLE IF EXISTS equipment_model;
DROP TABLE IF EXISTS equipment_type;
DROP TABLE IF EXISTS manufacturer;
DROP TABLE IF EXISTS employee_workplace;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS workplace;
DROP TABLE IF EXISTS office;

CREATE TABLE office (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  name    VARCHAR(100) NOT NULL,
  city    VARCHAR(60)  NOT NULL,
  address VARCHAR(150) NOT NULL,
  CONSTRAINT uq_office_name UNIQUE (name)
) ENGINE = InnoDB;

CREATE TABLE workplace (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  code        VARCHAR(10) NOT NULL,
  room_number VARCHAR(10) NOT NULL,
  office_id   INT         NOT NULL
) ENGINE = InnoDB;

CREATE TABLE employee (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50)  NOT NULL,
  last_name  VARCHAR(50)  NOT NULL,
  email      VARCHAR(100) NOT NULL,
  position   VARCHAR(60)  NOT NULL,
  CONSTRAINT uq_employee_email UNIQUE (email)
) ENGINE = InnoDB;

CREATE TABLE employee_workplace (
  employee_id  INT NOT NULL,
  workplace_id INT NOT NULL,
  PRIMARY KEY (employee_id, workplace_id)
) ENGINE = InnoDB;

CREATE TABLE manufacturer (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  name    VARCHAR(60) NOT NULL,
  country VARCHAR(60) NOT NULL,
  CONSTRAINT uq_manufacturer_name UNIQUE (name)
) ENGINE = InnoDB;

CREATE TABLE equipment_type (
  id   INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(40) NOT NULL,
  CONSTRAINT uq_equipment_type_name UNIQUE (name)
) ENGINE = InnoDB;

CREATE TABLE equipment_model (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(80) NOT NULL,
  manufacturer_id   INT         NOT NULL,
  equipment_type_id INT         NOT NULL
) ENGINE = InnoDB;

CREATE TABLE computer_configuration (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  cpu        VARCHAR(60) NOT NULL,
  ram_gb     INT         NOT NULL,
  storage_gb INT         NOT NULL,
  os         VARCHAR(40) NOT NULL,
  CONSTRAINT chk_config_positive CHECK (ram_gb > 0 AND storage_gb > 0)
) ENGINE = InnoDB;

CREATE TABLE equipment (
  id                        INT AUTO_INCREMENT PRIMARY KEY,
  inventory_number          VARCHAR(20) NOT NULL,
  serial_number             VARCHAR(40) NOT NULL,
  status                    ENUM('В роботі', 'На складі', 'В ремонті', 'Списано') NOT NULL,
  purchase_date             DATE        NOT NULL,
  equipment_model_id        INT         NOT NULL,
  computer_configuration_id INT         NULL,
  office_id                 INT         NOT NULL,
  CONSTRAINT uq_equipment_inventory_number UNIQUE (inventory_number),
  CONSTRAINT uq_equipment_serial_number    UNIQUE (serial_number)
) ENGINE = InnoDB;

CREATE TABLE equipment_assignment (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  issued_at    DATE NOT NULL,
  returned_at  DATE NULL,
  equipment_id INT  NOT NULL,
  employee_id  INT  NULL,
  workplace_id INT  NULL,
  CONSTRAINT chk_assignment_target CHECK (employee_id IS NOT NULL OR workplace_id IS NOT NULL),
  CONSTRAINT chk_assignment_dates  CHECK (returned_at IS NULL OR returned_at >= issued_at)
) ENGINE = InnoDB;

ALTER TABLE workplace
  ADD CONSTRAINT fk_workplace_office
  FOREIGN KEY (office_id) REFERENCES office (id);

ALTER TABLE employee_workplace
  ADD CONSTRAINT fk_ew_employee
  FOREIGN KEY (employee_id) REFERENCES employee (id),
  ADD CONSTRAINT fk_ew_workplace
  FOREIGN KEY (workplace_id) REFERENCES workplace (id);

ALTER TABLE equipment_model
  ADD CONSTRAINT fk_model_manufacturer
  FOREIGN KEY (manufacturer_id) REFERENCES manufacturer (id),
  ADD CONSTRAINT fk_model_type
  FOREIGN KEY (equipment_type_id) REFERENCES equipment_type (id);

ALTER TABLE equipment
  ADD CONSTRAINT fk_equipment_model
  FOREIGN KEY (equipment_model_id) REFERENCES equipment_model (id),
  ADD CONSTRAINT fk_equipment_config
  FOREIGN KEY (computer_configuration_id) REFERENCES computer_configuration (id),
  ADD CONSTRAINT fk_equipment_office
  FOREIGN KEY (office_id) REFERENCES office (id);

ALTER TABLE equipment_assignment
  ADD CONSTRAINT fk_assignment_equipment
  FOREIGN KEY (equipment_id) REFERENCES equipment (id),
  ADD CONSTRAINT fk_assignment_employee
  FOREIGN KEY (employee_id) REFERENCES employee (id),
  ADD CONSTRAINT fk_assignment_workplace
  FOREIGN KEY (workplace_id) REFERENCES workplace (id);

CREATE UNIQUE INDEX uq_workplace_office_code ON workplace (office_id, code);

CREATE UNIQUE INDEX uq_model_manufacturer_name ON equipment_model (manufacturer_id, name);

CREATE INDEX idx_employee_full_name ON employee (last_name, first_name);

CREATE INDEX idx_office_city ON office (city);

CREATE INDEX idx_equipment_office_status ON equipment (office_id, status);

CREATE INDEX idx_equipment_purchase_date ON equipment (purchase_date);

CREATE INDEX idx_assignment_equipment_returned ON equipment_assignment (equipment_id, returned_at);

CREATE INDEX idx_assignment_issued_at ON equipment_assignment (issued_at);

INSERT INTO office (id, name, city, address) VALUES
  (1,  'Офіс Львів',            'Львів',            'вул. Шевченка, 120'),
  (2,  'Офіс Київ',             'Київ',             'вул. Хрещатик, 22'),
  (3,  'Офіс Івано-Франківськ', 'Івано-Франківськ', 'вул. Незалежності, 15'),
  (4,  'Офіс Тернопіль',        'Тернопіль',        'вул. Руська, 8'),
  (5,  'Офіс Рівне',            'Рівне',            'вул. Соборна, 40'),
  (6,  'Офіс Харків',           'Харків',           'просп. Науки, 14'),
  (7,  'Офіс Одеса',            'Одеса',            'вул. Дерибасівська, 5'),
  (8,  'Офіс Дніпро',           'Дніпро',           'просп. Яворницького, 60'),
  (9,  'Офіс Луцьк',            'Луцьк',            'вул. Лесі Українки, 30'),
  (10, 'Офіс Ужгород',          'Ужгород',          'пл. Театральна, 2');

INSERT INTO workplace (id, code, room_number, office_id) VALUES
  (1,  'A-01', '101', 1),
  (2,  'A-02', '101', 1),
  (3,  'K-01', '305', 2),
  (4,  'F-01', '12',  3),
  (5,  'T-01', '5',   4),
  (6,  'A-03', '102', 1),
  (7,  'K-02', '306', 2),
  (8,  'R-01', '7',   5),
  (9,  'H-01', '210', 6),
  (10, 'O-01', '15',  7),
  (11, 'D-01', '401', 8),
  (12, 'L-01', '3',   9);

INSERT INTO employee (id, first_name, last_name, email, position) VALUES
  (1,  'Олег',    'Коваленко', 'o.kovalenko@company.ua',  'Software Engineer'),
  (2,  'Ірина',   'Шевчук',    'i.shevchuk@company.ua',   'QA Engineer'),
  (3,  'Андрій',  'Мельник',   'a.melnyk@company.ua',     'DevOps Engineer'),
  (4,  'Наталія', 'Бондар',    'n.bondar@company.ua',     'Project Manager'),
  (5,  'Тарас',   'Лисенко',   't.lysenko@company.ua',    'System Administrator'),
  (6,  'Софія',   'Ткаченко',  's.tkachenko@company.ua',  'HR Manager'),
  (7,  'Максим',  'Гнатюк',    'm.hnatiuk@company.ua',    'Frontend Developer'),
  (8,  'Юлія',    'Кравчук',   'y.kravchuk@company.ua',   'Business Analyst'),
  (9,  'Богдан',  'Савчук',    'b.savchuk@company.ua',    'Backend Developer'),
  (10, 'Оксана',  'Романюк',   'o.romaniuk@company.ua',   'UI/UX Designer'),
  (11, 'Дмитро',  'Поліщук',   'd.polishchuk@company.ua', 'Team Lead'),
  (12, 'Марта',   'Іваненко',  'm.ivanenko@company.ua',   'Data Engineer');

INSERT INTO employee_workplace (employee_id, workplace_id) VALUES
  (1, 1), (1, 3),
  (2, 3),
  (3, 2),
  (4, 4),
  (5, 5),
  (6, 6),
  (7, 7), (7, 9),
  (8, 8),
  (9, 9),
  (10, 10),
  (11, 11), (11, 1),
  (12, 12);

INSERT INTO manufacturer (id, name, country) VALUES
  (1,  'Lenovo',   'Китай'),
  (2,  'Dell',     'США'),
  (3,  'HP',       'США'),
  (4,  'Yealink',  'Китай'),
  (5,  'MikroTik', 'Латвія'),
  (6,  'Ubiquiti', 'США'),
  (7,  'Apple',    'США'),
  (8,  'Samsung',  'Південна Корея'),
  (9,  'Cisco',    'США'),
  (10, 'ASUS',     'Тайвань');

INSERT INTO equipment_type (id, name) VALUES
  (1,  'Ноутбук'),
  (2,  'Комп''ютер'),
  (3,  'Монітор'),
  (4,  'IP-телефон'),
  (5,  'Роутер'),
  (6,  'Принтер'),
  (7,  'Точка доступу'),
  (8,  'Комутатор'),
  (9,  'Сканер'),
  (10, 'Проєктор');

INSERT INTO equipment_model (id, name, manufacturer_id, equipment_type_id) VALUES
  (1,  'ThinkPad T14',        1,  1),
  (2,  'OptiPlex 7010',       2,  2),
  (3,  'UltraSharp U2723QE',  2,  3),
  (4,  'SIP-T54W',            4,  4),
  (5,  'hAP ax3',             5,  5),
  (6,  'LaserJet Pro M404dn', 3,  6),
  (7,  'UniFi U6 Pro',        6,  7),
  (8,  'MacBook Pro 14',      7,  1),
  (9,  'Odyssey G5 27',       8,  3),
  (10, 'EliteBook 840 G10',   3,  1),
  (11, 'IP Phone 8841',       9,  4),
  (12, 'Catalyst 9200L',      9,  8),
  (13, 'ProArt PA278QV',      10, 3),
  (14, 'ScanJet Pro 3600 f1', 3,  9);

INSERT INTO computer_configuration (id, cpu, ram_gb, storage_gb, os) VALUES
  (1,  'Intel Core i7-1365U', 32, 1024, 'Windows 11 Pro'),
  (2,  'Intel Core i5-1345U', 16, 512,  'Windows 11 Pro'),
  (3,  'Intel Core i5-13500', 16, 512,  'Windows 11 Pro'),
  (4,  'Intel Core i9-13900', 64, 2048, 'Ubuntu 22.04'),
  (5,  'AMD Ryzen 5 7530U',   16, 512,  'Ubuntu 22.04'),
  (6,  'Apple M3 Pro',        18, 512,  'macOS Sonoma'),
  (7,  'Intel Core i7-1355U', 16, 512,  'Windows 11 Pro'),
  (8,  'AMD Ryzen 7 7840U',   32, 1024, 'Windows 11 Pro'),
  (9,  'Intel Core i7-13700', 32, 1024, 'Windows 11 Pro'),
  (10, 'Apple M3 Max',        36, 1024, 'macOS Sonoma');

INSERT INTO equipment (id, inventory_number, serial_number, status, purchase_date,
                       equipment_model_id, computer_configuration_id, office_id) VALUES
  (1,  'INV-001', 'PF4A001',     'В роботі',  '2023-03-01', 1,  1,    1),
  (2,  'INV-002', 'PF4A002',     'В роботі',  '2024-05-20', 1,  1,    1),
  (3,  'INV-003', 'PF4A003',     'В роботі',  '2023-06-10', 1,  2,    2),
  (4,  'INV-004', 'DL7010A',     'В роботі',  '2022-08-15', 2,  3,    1),
  (5,  'INV-005', 'DLU27001',    'В роботі',  '2023-03-01', 3,  NULL, 1),
  (6,  'INV-006', 'DLU27002',    'В роботі',  '2023-09-05', 3,  NULL, 2),
  (7,  'INV-007', 'YLT54001',    'В роботі',  '2022-02-20', 4,  NULL, 1),
  (8,  'INV-008', 'MTAX3001',    'В роботі',  '2022-07-01', 5,  NULL, 1),
  (9,  'INV-009', 'HPM404001',   'В ремонті', '2021-09-10', 6,  NULL, 2),
  (10, 'INV-010', 'UBU6P001',    'В роботі',  '2023-03-03', 7,  NULL, 3),
  (11, 'INV-011', 'MBP14001',    'В роботі',  '2024-01-15', 8,  6,    2),
  (12, 'INV-012', 'HP840G10001', 'В роботі',  '2024-02-10', 10, 7,    6),
  (13, 'INV-013', 'SMG5001',     'На складі', '2024-03-05', 9,  NULL, 1),
  (14, 'INV-014', 'CSC8841001',  'В роботі',  '2023-11-20', 11, NULL, 2),
  (15, 'INV-015', 'CAT9200001',  'Списано',   '2020-05-12', 12, NULL, 1);

INSERT INTO equipment_assignment (id, issued_at, returned_at, equipment_id, employee_id, workplace_id) VALUES
  (1,  '2023-03-15', NULL,         1,  1,    NULL),
  (2,  '2024-06-01', NULL,         2,  1,    NULL),
  (3,  '2023-06-15', NULL,         3,  2,    NULL),
  (4,  '2022-09-01', NULL,         4,  3,    2),
  (5,  '2023-03-15', NULL,         5,  1,    1),
  (6,  '2023-09-10', NULL,         6,  1,    3),
  (7,  '2022-03-01', NULL,         7,  NULL, 1),
  (8,  '2024-01-20', NULL,         11, 7,    NULL),
  (9,  '2024-02-15', NULL,         12, 9,    NULL),
  (10, '2023-12-01', NULL,         14, NULL, 3),
  (11, '2021-10-01', '2023-01-15', 9,  NULL, 3),
  (12, '2024-03-10', '2024-09-01', 13, 6,    6),
  (13, '2023-07-01', NULL,         10, NULL, 4),
  (14, '2022-07-10', NULL,         8,  NULL, 6),
  (15, '2023-03-02', '2023-03-14', 5,  11,   1);

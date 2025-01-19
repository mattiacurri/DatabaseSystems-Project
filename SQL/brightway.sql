-- DROP TYPE AddressTY FORCE;
-- DROP TYPE OperationalCenterTY FORCE;
-- DROP TYPE TeamTY FORCE;
-- DROP TYPE EmployeeVA FORCE;
-- DROP TYPE EmployeeTY FORCE;
-- DROP TYPE FeedbackTY FORCE;
-- DROP TYPE BusinessAccountTY FORCE;
-- DROP TYPE CustomerTY FORCE;
-- DROP TYPE OrderTY FORCE;
/

-- Types definition
CREATE OR REPLACE TYPE AddressTY AS OBJECT (
    street VARCHAR2(50),
    civicNum NUMBER,
    city VARCHAR2(50),
    province VARCHAR2(50),
    region VARCHAR2(50),
    state VARCHAR2(50)
);
/
CREATE OR REPLACE TYPE OperationalCenterTY AS OBJECT (
    name VARCHAR2(50),
    address AddressTY
);
/
CREATE OR REPLACE TYPE TeamTY AS OBJECT (
    ID VARCHAR2(50), -- Format: TXXXXXX
    name VARCHAR2(20),
    numOrder NUMBER,
    performanceScore NUMBER,
    operationalCenter ref OperationalCenterTY
);
/
CREATE OR REPLACE TYPE EmployeeTY AS OBJECT (
    FC VARCHAR2(16),
    name VARCHAR2(20),
    surname VARCHAR2(20),
    dob DATE,
    phone VARCHAR2(14),
    email VARCHAR2(50),
    team ref TeamTY
);
/

CREATE OR REPLACE TYPE FeedbackTY AS OBJECT (
    score NUMBER(1), -- check (score between 1 and 5),
    commentF VARCHAR2(1000)
);
/

CREATE OR REPLACE TYPE CustomerTY AS OBJECT (
    VAT VARCHAR2(11),
    phone VARCHAR2(14),
    email VARCHAR2(50),
    type VARCHAR2(10), -- CHECK (type IN ('individual', 'business')
    name VARCHAR2(20),
    surname VARCHAR2(20),
    dob DATE,
    companyName VARCHAR2(50),
    address AddressTY
) NOT FINAL;
/

CREATE OR REPLACE TYPE BusinessAccountTY AS OBJECT (
    CODE VARCHAR2(10), -- Format: BXXXXXXXXX
    creationDate DATE,
    customer ref CustomerTY
);
/

CREATE OR REPLACE TYPE EmployeeVA AS VARRAY(8) OF REF EmployeeTY;
/

CREATE OR REPLACE TYPE OrderTY AS OBJECT (
    ID VARCHAR2(10), -- Format: OXXXXXXXXX
    placingDate DATE,
    orderMode VARCHAR2(6), -- CHECK (orderMode IN ('online', 'phone', 'email')),
    orderType VARCHAR2(7), -- CHECK (orderType IN ('regular', 'urgent', 'bulk')),
    cost NUMBER(10, 2),
    businessAccount ref BusinessAccountTY,
    team ref TeamTY,
    employees EmployeeVA,
    completionDate DATE,
    feedback FeedbackTY
);
/

-- TABLE CREATION

-- DROP TABLE OperationalCenterTB FORCE;
-- DROP TABLE TeamTB FORCE;
-- DROP TABLE EmployeeTB FORCE;
-- DROP TABLE CustomerTB FORCE;
-- DROP TABLE BusinessAccountTB FORCE;
-- DROP TABLE OrderTB FORCE;
/

CREATE TABLE OperationalCenterTB OF OperationalCenterTY (
    name PRIMARY KEY,
    address NOT NULL
);
/ 

CREATE TABLE TeamTB OF TeamTY (
    ID PRIMARY KEY check (REGEXP_LIKE(ID, '^T[0-9]{6}$')),
    name NOT NULL,
    numOrder check (numOrder >= 0),
    performanceScore check (performanceScore between 1 and 5),
    operationalCenter NOT NULL
);
/

CREATE TABLE EmployeeTB OF EmployeeTY (
    FC PRIMARY KEY CHECK (LENGTH(FC) = 16),
    name NOT NULL,
    surname NOT NULL,
    dob NOT NULL,
    phone NOT NULL,
    email NOT NULL
);
/

CREATE TABLE CustomerTB OF CustomerTY (
    VAT PRIMARY KEY CHECK (LENGTH(VAT) = 11),
    phone NOT NULL,
    email NOT NULL,
    type NOT NULL CHECK (type IN ('individual', 'business'))
);
/

CREATE TABLE BusinessAccountTB OF BusinessAccountTY (
    CODE PRIMARY KEY check (REGEXP_LIKE(CODE, '^B[0-9]{9}$')),
    creationDate NOT NULL,
    customer NOT NULL
);
/

CREATE TABLE OrderTB OF OrderTY (
    ID PRIMARY KEY check (REGEXP_LIKE(ID, '^O[0-9]{9}$')),
    placingDate NOT NULL,
    orderMode NOT NULL CHECK (orderMode IN ('online', 'phone', 'email')),
    orderType NOT NULL CHECK (orderType IN ('regular', 'urgent', 'bulk')),
    cost NOT NULL CHECK (cost > 0),
    businessAccount NOT NULL
    -- TODO: completionDate check (completionDate >= placingDate) TRIGGER
);
/

-- ? Prove Varie
-- INSERT INTO OperationalCenterTB VALUES ('OC1', AddressTY('Via Roma', 1, 'Roma', 'RM', 'Lazio', 'Italia'));

-- INSERT INTO TeamTB VALUES ('T123456', 'Team1', 0, 1, (SELECT REF(oc) FROM OperationalCenterTB oc WHERE oc.name = 'OC1'));

-- INSERT INTO EmployeeTB VALUES ('ABCDEFGHJKLMNOPQ', 'Mario', 'Rossi', TO_DATE('1990-01-01', 'YYYY-MM-DD'), '1234567890', 'A@A.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
-- INSERT INTO EmployeeTB VALUES ('1BCDEFGHJKLMNOPQ', 'Luigi', 'Verdi', TO_DATE('1985-02-02', 'YYYY-MM-DD'), '2345678901', 'B@B.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
-- INSERT INTO EmployeeTB VALUES ('2BCDEFGHJKLMNOPQ', 'Giovanni', 'Bianchi', TO_DATE('1980-03-03', 'YYYY-MM-DD'), '3456789012', 'C@C.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
-- INSERT INTO EmployeeTB VALUES ('3BCDEFGHJKLMNOPQ', 'Paolo', 'Neri', TO_DATE('1975-04-04', 'YYYY-MM-DD'), '4567890123', 'D@D.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
-- INSERT INTO EmployeeTB VALUES ('4BCDEFGHJKLMNOPQ', 'Francesco', 'Rossi', TO_DATE('1995-05-05', 'YYYY-MM-DD'), '5678901234', 'E@E.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
-- INSERT INTO EmployeeTB VALUES ('5BCDEFGHJKLMNOPQ', 'Marco', 'Gialli', TO_DATE('1992-06-06', 'YYYY-MM-DD'), '6789012345', 'F@F.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
-- INSERT INTO EmployeeTB VALUES ('6BCDEFGHJKLMNOPQ', 'Antonio', 'Blu', TO_DATE('1988-07-07', 'YYYY-MM-DD'), '7890123456', 'G@G.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
-- INSERT INTO EmployeeTB VALUES ('7BCDEFGHJKLMNOPQ', 'Roberto', 'Viola', TO_DATE('1991-08-08', 'YYYY-MM-DD'), '8901234567', 'H@H.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
-- INSERT INTO EmployeeTB VALUES ('8BCDEFGHJKLMNOPQ', 'Luca', 'Marrone', TO_DATE('1993-09-09', 'YYYY-MM-DD'), '9012345678', 'I@I.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));

-- INSERT INTO CustomerTB VALUES ('12345678900', '1234567890', 'ciccio@gmail.com', 'individual', 'Ciccio', 'Pasticcio', TO_DATE('1990-01-01', 'YYYY-MM-DD'), NULL, NULL);
-- INSERT INTO CustomerTB VALUES ('12345678901', '1234567890', 'ciccio@gmail.com', 'individual', 'Ciccio', 'Pasticcio', TO_DATE('1990-01-01', 'YYYY-MM-DD'), NULL, NULL);
-- INSERT INTO CustomerTB VALUES ('12345678921', '1234567890', 'ciccio@gmail.com', 'business', NULL, NULL, NULL, 'La Locanda', AddressTY('Via Roma', 1, 'Roma', 'RM', 'Lazio', 'Italia'));
-- INSERT INTO CustomerTB VALUES ('12345678902', '1234567890', 'lp@lp.com', 'business', NULL, NULL, NULL, 'La Pizzeria', AddressTY('Via Roma', 2, 'Roma', 'RM', 'Lazio', 'Italia'));
-- /

-- INSERT INTO BusinessAccountTB VALUES ('B123456789', TO_DATE('2021-01-01', 'YYYY-MM-DD'), (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = '12345678900'));
-- /
-- INSERT INTO BusinessAccountTB VALUES ('B987654321', TO_DATE('2022-01-01', 'YYYY-MM-DD'), (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = '12345678901'));
-- /
-- INSERT INTO OrderTB VALUES ('O123456789', TO_DATE('2021-01-01', 'YYYY-MM-DD'), 'online', 'regular', 100, (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B123456789'), NULL, NULL, TO_DATE('2021-01-02', 'YYYY-MM-DD'), NULL);
-- /
-- INSERT INTO OrderTB VALUES (
--     'O123456700', 
--     TO_DATE('2021-01-01', 'YYYY-MM-DD'), 
--     'online', 
--     'regular', 
--     100, 
--     (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
--     (SELECT REF(ta) FROM TeamTB ta WHERE ta.ID = 'T123456'), 
--     EmployeeVA(
--         (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'ABCDEFGHJKLMNOPQ'),
--         (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '1BCDEFGHJKLMNOPQ'),
--         (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '2BCDEFGHJKLMNOPQ'),
--         (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '3BCDEFGHJKLMNOPQ'),
--         (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '4BCDEFGHJKLMNOPQ'),
--         (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '5BCDEFGHJKLMNOPQ'),
--         (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '6BCDEFGHJKLMNOPQ'),
--         (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '7BCDEFGHJKLMNOPQ')
--     ), 
--     TO_DATE('2021-01-02', 'YYYY-MM-DD'), 
--     FeedbackTY(5, 'Good job')
-- );
-- /

-- SELECT * FROM CustomerTB;
-- SELECT CODE, creationDate, deref(customer) FROM BusinessAccountTB BA where BA.Customer.VAT = '12345678900';
-- SELECT 
--     ID, 
--     placingDate, 
--     orderMode, 
--     orderType, 
--     cost, 
--     DEREF(businessAccount) AS businessAccount, 
--     DEREF(team) AS team, 
--     completionDate, 
--     feedback 
-- FROM OrderTB;

-- Trigger creation
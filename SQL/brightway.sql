-- Connect to Brightway admin
CONNECT brightway_admin/BRIGHTWAY_ADMIN;

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
    ID VARCHAR2(32),
    name VARCHAR2(20),
    numOrder NUMBER,
    performanceScore NUMBER(4, 2),
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
    CODE VARCHAR2(32),
    creationDate DATE,
    customer ref CustomerTY
);
/

CREATE OR REPLACE TYPE EmployeeVA AS VARRAY(8) OF REF EmployeeTY;
/

CREATE OR REPLACE TYPE OrderTY AS OBJECT (
    ID VARCHAR2(32),
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
CREATE TABLE OperationalCenterTB OF OperationalCenterTY (
    name PRIMARY KEY,
    address NOT NULL
);
/ 

CREATE TABLE TeamTB OF TeamTY (
    ID DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY,
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
    CODE DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY, -- CHECK (REGEXP_LIKE(CODE, '^B[0-9]{9}$')),
    creationDate NOT NULL,
    customer NOT NULL
);
/

CREATE TABLE OrderTB OF OrderTY (
    ID DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY, -- CHECK (REGEXP_LIKE(ID, '^O[0-9]{9}$')),
    placingDate NOT NULL,
    orderMode NOT NULL CHECK (orderMode IN ('online', 'phone', 'email')),
    orderType NOT NULL CHECK (orderType IN ('regular', 'urgent', 'bulk')),
    cost NOT NULL CHECK (cost > 0),
    businessAccount NOT NULL,

    check (placingDate <= completionDate),
    check (feedback.score between 1 and 5)
);
/
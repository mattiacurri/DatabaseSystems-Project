-- TODO: CAMBIARE NUMERI NEI LOOP
CREATE OR REPLACE PROCEDURE populateCustomer AS
BEGIN
    dbms_output.put_line('Populating Customer table...');
    FOR i in 1..100 LOOP
        INSERT INTO CustomerTB VALUES (
            'IT' || TO_CHAR(DBMS_RANDOM.value(100000000, 999999999), 'FM000000000'),
            '+39' || TO_CHAR(DBMS_RANDOM.value(3000000000, 3999999999), 'FM0000000000'),
            DBMS_RANDOM.STRING('U', 10) || '@gmail.com',
            'individual',
            'customer' || DBMS_RANDOM.STRING('U', 10),
            'surname' || DBMS_RANDOM.STRING('U', 10),
            NULL,
            NULL,
            NULL
        );
    END LOOP;
    FOR i in 101..200 LOOP
        INSERT INTO CustomerTB VALUES (
            'IT' || TO_CHAR(DBMS_RANDOM.value(100000000, 999999999), 'FM000000000'),
            '+39' || TO_CHAR(DBMS_RANDOM.value(3000000000, 3999999999), 'FM0000000000'),
            DBMS_RANDOM.STRING('U', 10) || '@gmail.com',
            'business',
            NULL,
            NULL,
            NULL,
            DBMS_RANDOM.STRING('U', 10),
            AddressTY(
                DBMS_RANDOM.STRING('U', 10),
                DBMS_RANDOM.value(1, 25),
                DBMS_RANDOM.STRING('U', 10),
                DBMS_RANDOM.STRING('U', 10),
                DBMS_RANDOM.STRING('U', 10),
                DBMS_RANDOM.STRING('U', 10)
            )
        );
    END LOOP;
    dbms_output.put_line('Customer table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateOperationalCenter AS
BEGIN
    dbms_output.put_line('Populating OperationalCenter table...');
    FOR i in 1..10 LOOP
        INSERT INTO OperationalCenterTB VALUES (
            'center-' || DBMS_RANDOM.STRING('U', 10),
            AddressTY(
                DBMS_RANDOM.STRING('U', 10),
                DBMS_RANDOM.value(1, 25),
                DBMS_RANDOM.STRING('U', 10),
                DBMS_RANDOM.STRING('U', 10),
                DBMS_RANDOM.STRING('U', 10),
                DBMS_RANDOM.STRING('U', 10)
            )
        );
    END LOOP;
    dbms_output.put_line('OperationalCenter table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateTeam AS
BEGIN
    dbms_output.put_line('Populating Team table...');
    FOR i in 1..100 LOOP
        INSERT INTO TeamTB VALUES (
            'T' || TO_CHAR(DBMS_RANDOM.value(100000, 999999), 'FM000000'),
            'team-' || DBMS_RANDOM.STRING('U', 10),
            0,
            0,
            (SELECT * FROM (SELECT REF(o) FROM OperationalCenterTB o ORDER BY dbms_random.value) WHERE rownum = 1)
        );
    END LOOP;
    dbms_output.put_line('Team table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateEmployee AS
BEGIN
    dbms_output.put_line('Populating Employee table...');
    FOR i in 1..100 LOOP
        INSERT INTO EmployeeTB VALUES (
            'E' || DBMS_RANDOM.STRING('U', 15),
            DBMS_RANDOM.STRING('U', 10),
            DBMS_RANDOM.STRING('U', 10),
            TO_DATE(
                TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '1970-01-01', 'J'), TO_CHAR(DATE '2000-12-31', 'J'))),
                'J'
            ),
            '+39' || TO_CHAR(DBMS_RANDOM.value(3000000000, 3999999999), 'FM0000000000'),
            DBMS_RANDOM.STRING('U', 10) || '@gmail.com',
            (SELECT * FROM (SELECT REF(t) FROM TeamTB t ORDER BY dbms_random.value) WHERE rownum = DBMS_RANDOM.value(1, 100))
        );
    END LOOP;
    dbms_output.put_line('Employee table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateBusinessAccount AS
BEGIN
    dbms_output.put_line('Populating BusinessAccount table...');
    FOR i in 1..100 LOOP
        INSERT INTO BusinessAccountTB VALUES (
            'B' ||  TO_CHAR(DBMS_RANDOM.value(100000000, 999999999), 'FM000000000'),
            TO_DATE(
                TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2010-01-01', 'J'), TO_CHAR(DATE '2020-12-31', 'J'))),
                'J'
            ),
            (SELECT * FROM (SELECT REF(c) FROM CustomerTB c WHERE c.type = 'business' ORDER BY dbms_random.value) WHERE rownum = 1)
        );
    END LOOP;
    dbms_output.put_line('BusinessAccount table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateOrder AS
BEGIN
    dbms_output.put_line('Populating Order table...');
    FOR i in 1..1000 LOOP
        INSERT INTO OrderTB VALUES (
            'O' || TO_CHAR(DBMS_RANDOM.value(100000000, 999999999), 'FM000000000'),
            TO_DATE(
                TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2010-01-01', 'J'), TO_CHAR(DATE '2020-12-31', 'J'))), 'J'),
            CASE
                WHEN DBMS_RANDOM.VALUE(0, 1) < 0.33 THEN 'online'
                WHEN DBMS_RANDOM.VALUE(0, 1) < 0.66 THEN 'phone'
                ELSE 'email'
            END,
            CASE
                WHEN DBMS_RANDOM.VALUE(0, 1) < 0.33 THEN 'regular'
                WHEN DBMS_RANDOM.VALUE(0, 1) < 0.66 THEN 'urgent'
                ELSE 'bulk'
            END,
            DBMS_RANDOM.VALUE(1, 10000),
            (SELECT * FROM (SELECT REF(b) FROM BusinessAccountTB b ORDER BY dbms_random.value) WHERE rownum = 1),
            (SELECT * FROM (SELECT REF(t) FROM TeamTB t ORDER BY dbms_random.value) WHERE rownum = 1),
            EmployeeVA(
                (SELECT * FROM (SELECT REF(e) FROM EmployeeTB e ORDER BY dbms_random.value) WHERE rownum = 1),
                (SELECT * FROM (SELECT REF(e) FROM EmployeeTB e ORDER BY dbms_random.value) WHERE rownum = 1),
                (SELECT * FROM (SELECT REF(e) FROM EmployeeTB e ORDER BY dbms_random.value) WHERE rownum = 1)
            ),
            NULL,
            NULL
        );
    END LOOP;
    dbms_output.put_line('Order table populated.');
END;
/

BEGIN
    populateCustomer;
    populateOperationalCenter;
    populateTeam;
    populateEmployee;
    populateBusinessAccount;
    populateOrder;
END;
/

-- Check
SELECT * FROM CustomerTB FETCH FIRST 10 ROWS ONLY;
SELECT * FROM OperationalCenterTB FETCH FIRST 10 ROWS ONLY;
SELECT * FROM TeamTB FETCH FIRST 10 ROWS ONLY;
SELECT * FROM EmployeeTB FETCH FIRST 10 ROWS ONLY;
SELECT * FROM BusinessAccountTB FETCH FIRST 10 ROWS ONLY;
SELECT * FROM OrderTB FETCH FIRST 10 ROWS ONLY;

SELECT COUNT(*) FROM CustomerTB;
SELECT COUNT(*) FROM OperationalCenterTB;
SELECT COUNT(*) FROM TeamTB;
SELECT COUNT(*) FROM EmployeeTB;
SELECT COUNT(*) FROM BusinessAccountTB;
SELECT COUNT(*) FROM OrderTB;
/
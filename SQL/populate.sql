CONNECT brightway_admin/BRIGHTWAY_ADMIN@localhost:1521/xepdb1;

CREATE OR REPLACE PROCEDURE populateCustomer(individualCount IN NUMBER, businessCount IN NUMBER) AS
    maxC NUMBER;
    cc VARCHAR2(11);
BEGIN
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(c.VAT, 3))), 0) INTO maxC FROM CustomerTB c;

    FOR i in 1..individualCount LOOP
        cc := LPAD(TO_CHAR(maxC + i), 9, '0');
        INSERT INTO CustomerTB VALUES (
            'IT' || TO_CHAR(cc),
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
    
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(c.VAT, 3))), 0) INTO maxC FROM CustomerTB c;
    
    FOR i in 1..businessCount LOOP
        cc := LPAD(TO_CHAR(maxC + i), 9, '0');
        INSERT INTO CustomerTB VALUES (
            'IT' || TO_CHAR(cc),
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
END;
/

CREATE OR REPLACE PROCEDURE populateOperationalCenter(centerCount IN NUMBER) AS
BEGIN
    FOR i in 1..centerCount LOOP
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
END;
/

CREATE OR REPLACE PROCEDURE populateTeam(teamCount IN NUMBER) AS
BEGIN
    FOR i in 1..teamCount LOOP
        INSERT INTO TeamTB VALUES (
            RAWTOHEX(SYS_GUID()),
            'team-' || DBMS_RANDOM.STRING('U', 10),
            0,
            0,
            (SELECT * FROM (SELECT REF(o) FROM OperationalCenterTB o ORDER BY dbms_random.value()) FETCH FIRST 1 ROW ONLY)
        );
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE populateEmployee(employeeCount IN NUMBER) AS
    TYPE refTeamTB IS TABLE OF REF TeamTY INDEX BY PLS_INTEGER;
    teams refTeamTB;
    currentTeamIndex PLS_INTEGER := 1;
    employeesInCurrentTeam NUMBER := 0;
    cc VARCHAR2(15);
BEGIN
    -- Bulk collect all teams
    SELECT REF(t) BULK COLLECT INTO teams
    FROM TeamTB t;

    FOR i in 1..employeeCount LOOP
        -- If current team has 7 employees, move to next team
        IF employeesInCurrentTeam = 7 THEN
            currentTeamIndex := currentTeamIndex + 1;
            employeesInCurrentTeam := 0;
            -- Exit if no more teams available
            IF currentTeamIndex > teams.COUNT THEN
                EXIT;
            END IF;
        END IF;

        INSERT INTO EmployeeTB VALUES (
            'E' || DBMS_RANDOM.STRING('U', 15),
            DBMS_RANDOM.STRING('U', 10),
            DBMS_RANDOM.STRING('U', 10),
            TO_DATE(
                TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '1980-01-01', 'J'), TO_CHAR(DATE '1999-01-01', 'J'))),
                'J'
            ),
            '+39' || TO_CHAR(DBMS_RANDOM.value(3000000000, 3999999999), 'FM0000000000'),
            DBMS_RANDOM.STRING('U', 10) || '@gmail.com',
            teams(currentTeamIndex)
        );
        employeesInCurrentTeam := employeesInCurrentTeam + 1;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE populateBusinessAccount (numAccount IN NUMBER) AUTHID CURRENT_USER AS
    TYPE refCustomerTB IS TABLE OF REF CUSTOMERTY INDEX BY PLS_INTEGER;
    customers refCustomerTB;
    randCustomer REF CUSTOMERTY;
    randIndex PLS_INTEGER;
BEGIN
    -- Fetch all customer refs into the collection
    SELECT REF(c) BULK COLLECT INTO customers FROM CustomerTB c;

    FOR i IN 1..numAccount LOOP
        randIndex := TRUNC(DBMS_RANDOM.VALUE(customers.FIRST, customers.LAST));
        randCustomer := customers(randIndex);

        INSERT INTO BusinessAccountTB values
        (
            RAWTOHEX(SYS_GUID()),
            sysdate,
            randCustomer
        );
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE populateOrder(orderCount IN NUMBER, probability IN NUMBER) AS
    TYPE refBusinessAccountTB IS TABLE OF REF BusinessAccountTY INDEX BY PLS_INTEGER;
    businessAccounts refBusinessAccountTB;
    randBA REF BusinessAccountTY;

    TYPE refTeamTB IS TABLE OF REF TeamTY INDEX BY PLS_INTEGER;
    teams refTeamTB;
    randTeam REF TeamTY;

    randIndexB PLS_INTEGER;
    randIndexT PLS_INTEGER;

BEGIN
    SELECT REF(b) BULK COLLECT INTO businessAccounts FROM BusinessAccountTB b;

    SELECT REF(t) BULK COLLECT INTO teams FROM TeamTB t;

    FOR i in 1..orderCount LOOP
        -- Probability of having a team
        randIndexB := TRUNC(DBMS_RANDOM.VALUE(businessAccounts.FIRST, businessAccounts.LAST));
        randBA := businessAccounts(randIndexB);
        IF DBMS_RANDOM.VALUE(0, 1) <= probability THEN
            randIndexT := TRUNC(DBMS_RANDOM.VALUE(teams.FIRST, teams.LAST));
            randTeam := teams(randIndexT);
            INSERT INTO OrderTB VALUES (
                RAWTOHEX(SYS_GUID()),
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
                DBMS_RANDOM.VALUE(1, 1000),
                randBA,
                randTeam,
                NULL,
                NULL,
                NULL
            );
        ELSE
            INSERT INTO OrderTB VALUES (
                RAWTOHEX(SYS_GUID()),
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
                DBMS_RANDOM.VALUE(1, 1000),
                randBA,
                NULL,
                NULL,
                NULL,
                NULL
            );
        END IF;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE populateEmployeeInOrder(probability IN NUMBER) AS
BEGIN
    FOR orderRow IN (SELECT o.ID, DEREF(o.team) AS team FROM OrderTB o WHERE o.team IS NOT NULL AND o.completionDate IS NULL AND o.feedback IS NULL) LOOP
        IF DBMS_RANDOM.VALUE(0, 1) <= probability THEN
            -- Create temporary varray
            DECLARE
                emp_array EmployeeVA := EmployeeVA();
                v_team_emp_count NUMBER;
            BEGIN
                -- Get number of employees in the team
                SELECT COUNT(*) INTO v_team_emp_count
                FROM EmployeeTB e 
                WHERE DEREF(e.team).ID = orderRow.team.ID;

                -- Get random number of employees (0 to team size) from the same team
                FOR i in 1..DBMS_RANDOM.value(0, v_team_emp_count) LOOP
                    -- Extend the varray
                    emp_array.EXTEND;
                    -- Get random employee reference from the same team
                    SELECT REF(e) INTO emp_array(emp_array.COUNT)
                    FROM EmployeeTB e
                    WHERE DEREF(e.team).ID = orderRow.team.ID
                    ORDER BY dbms_random.value()
                    FETCH FIRST 1 ROW ONLY;
                END LOOP;

                -- Update the order with the new employee array
                UPDATE OrderTB o
                SET o.employees = emp_array
                WHERE o.ID = orderRow.ID;
            END;
        END IF;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE populateCompletionDateAndFeedbackInOrder(probability IN NUMBER) AS
v_team_id VARCHAR2(50);
v_team_name VARCHAR2(50);
v_team_score NUMBER;
BEGIN
    FOR orderRow IN (SELECT o.ID FROM OrderTB o WHERE o.team IS NOT NULL AND o.completionDate IS NULL AND O.feedback IS NULL) LOOP
        -- Only process orders based on probability
        IF DBMS_RANDOM.VALUE(0, 1) <= probability THEN
            -- Update the order with the new completion date and feedback
            UPDATE OrderTB o
            SET o.completionDate = TO_DATE(
                TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2021-01-01', 'J'), TO_CHAR(DATE '2021-12-31', 'J'))),
                'J'
            ),
            o.feedback = FeedbackTY(
                ROUND(DBMS_RANDOM.VALUE(1, 5)),
                CASE
                    WHEN DBMS_RANDOM.VALUE(0, 1) < 0.33 THEN 'Great service!'
                    WHEN DBMS_RANDOM.VALUE(0, 1) < 0.66 THEN 'Could be better'
                    ELSE 'Average experience'
                END
            )
            WHERE o.ID = orderRow.ID;

            SELECT t.ID, t.name, t.performanceScore
            INTO v_team_id, v_team_name, v_team_score
            FROM TeamTB t
            WHERE t.ID = (SELECT DEREF(o.team).ID FROM OrderTB o WHERE o.ID = orderRow.ID);
        END IF;
    END LOOP;
END;
/

BEGIN
    dbms_output.put_line('Starting population...');
    populateCustomer(18000, 2000);
    populateOperationalCenter(15);
    populateBusinessAccount(10000); -- 20000 are created in populateCustomer
    populateTeam(150); 
    populateEmployee(250);
    --EXECUTE IMMEDIATE 'ALTER TRIGGER ComputePerformanceScore DISABLE';
    populateOrder(45100, 0.9);
    populateEmployeeInOrder(0.1);
    populateCompletionDateAndFeedbackInOrder(0.1);
    --EXECUTE IMMEDIATE 'ALTER TRIGGER ComputePerformanceScore ENABLE';
    dbms_output.put_line('Population completed.');

    -- trigger ComputePerformanceScore by updating feedback in the first order
    --UPDATE OrderTB
    --SET feedback = FeedbackTY(5, 'Great service!')
    --WHERE ID = (SELECT ID FROM OrderTB o WHERE o.completionDate IS NOT NULL FETCH FIRST 1 ROW ONLY);
END;
/

-- count tuple in customer, oc, businessacc, team, employee, order
-- SELECT COUNT(*) FROM CustomerTB;
-- SELECT COUNT(*) FROM OperationalCenterTB;
-- SELECT COUNT(*) FROM BusinessAccountTB;
-- SELECT COUNT(*) FROM TeamTB;
-- SELECT COUNT(*) FROM EmployeeTB;
-- SELECT COUNT(*) FROM OrderTB;
-- /

-- SELECT ID, numOrder 
-- FROM TeamTB 
-- WHERE numOrder = (SELECT MAX(numOrder) FROM TeamTB)
-- FETCH FIRST 1 ROW ONLY;
-- /

-- -- First query: Select all orders for a specific team (e.g., team 'T000001')
-- SELECT feedback
-- FROM OrderTB o
-- WHERE DEREF(o.team).ID = (SELECT ID
-- FROM TeamTB 
-- WHERE numOrder = (SELECT MAX(numOrder) FROM TeamTB) FETCH FIRST 1 ROW ONLY)
-- ORDER BY o.placingDate;
-- /

-- -- Second query: Select the performance score for the same team
-- SELECT t.ID, t.name, t.performanceScore
-- FROM TeamTB t
-- WHERE t.ID = (SELECT ID
-- FROM TeamTB 
-- WHERE numOrder = (SELECT MAX(numOrder) FROM TeamTB) FETCH FIRST 1 ROW ONLY);
-- /

-- SELECT COUNT(*) from orderTB o where o.team IS NULL;
-- SELECT COUNT(*) from orderTB o where o.team IS NOT NULL;
-- /

commit work;
/
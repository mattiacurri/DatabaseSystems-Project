CREATE OR REPLACE PROCEDURE populateCustomer(individualCount IN NUMBER, businessCount IN NUMBER) AS
x Number;
BEGIN
    dbms_output.put_line('Populating Customer table...');
    SELECT COUNT(*) INTO x FROM CustomerTB WHERE VAT = '00000000000';
    IF x = 0 THEN
    dbms_output.put_line('Inserting Dummy customer...');
        INSERT INTO CustomerTB VALUES (
            '00000000000',
            '+390000000000',
            'dummy@dummy.com',
            'individual',
            'dummy',
            'dummy',
            TO_DATE('01/01/1971', 'DD/MM/YYYY'),
            NULL,
            NULL
        );
    END IF;
    FOR i in 1..individualCount LOOP
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
    FOR i in 1..businessCount LOOP
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

CREATE OR REPLACE PROCEDURE populateOperationalCenter(centerCount IN NUMBER) AS
BEGIN
    dbms_output.put_line('Populating OperationalCenter table...');
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
    dbms_output.put_line('OperationalCenter table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateTeam(teamCount IN NUMBER) AS
BEGIN
    dbms_output.put_line('Populating Team table...');
    FOR i in 1..teamCount LOOP
        INSERT INTO TeamTB VALUES (
            'T' || TO_CHAR(DBMS_RANDOM.value(100000, 999999), 'FM000000'),
            'team-' || DBMS_RANDOM.STRING('U', 10),
            0,
            0,
            (SELECT * FROM (SELECT REF(o) FROM OperationalCenterTB o ORDER BY dbms_random.value()) FETCH FIRST 1 ROW ONLY)
        );
    END LOOP;
    dbms_output.put_line('Team table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateEmployee(employeeCount IN NUMBER) AS
BEGIN
    dbms_output.put_line('Populating Employee table...');
    FOR i in 1..employeeCount LOOP
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
            (SELECT * FROM (SELECT REF(t) FROM TeamTB t ORDER BY dbms_random.value()) FETCH FIRST 1 ROW ONLY)
        );
    END LOOP;
    dbms_output.put_line('Employee table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateBusinessAccount(accountCount IN NUMBER) AS
x NUMBER;
BEGIN
    dbms_output.put_line('Populating BusinessAccount table...');
    SELECT COUNT(*) INTO x FROM BusinessAccountTB WHERE CODE = 'B000000000';
    if x = 0 THEN
    dbms_output.put_line('Inserting Dummy businessaccount...');
        INSERT INTO BusinessAccountTB VALUES (
            'B000000000',
            SYSDATE,
            (SELECT REF(c) FROM CustomerTB c WHERE c.type = 'individual' AND c.VAT = '00000000000')
        );
    end if;
    FOR i in 1..accountCount LOOP
        INSERT INTO BusinessAccountTB VALUES (
            'B' ||  TO_CHAR(DBMS_RANDOM.value(100000000, 999999999), 'FM000000000'),
            TO_DATE(
                TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2010-01-01', 'J'), TO_CHAR(DATE '2020-12-31', 'J'))),
                'J'
            ),
            (SELECT * FROM (SELECT REF(c) FROM CustomerTB c WHERE c.type = 'business' ORDER BY dbms_random.value()) FETCH FIRST 1 ROW ONLY)
        );
    END LOOP;
    dbms_output.put_line('BusinessAccount table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateOrder(orderCount IN NUMBER) AS
    empTeam TeamTY;
BEGIN
    dbms_output.put_line('Populating Order table...');
    FOR i in 1..orderCount LOOP
        SELECT DEREF(e.team) INTO empTeam 
        FROM (SELECT * FROM EmployeeTB e ORDER BY dbms_random.value()) e 
        FETCH FIRST 1 ROW ONLY;

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
            (SELECT * FROM (SELECT REF(b) FROM BusinessAccountTB b ORDER BY dbms_random.value()) FETCH FIRST 1 ROW ONLY),
            (SELECT * FROM (SELECT REF(t) FROM TeamTB t ORDER BY dbms_random.value()) FETCH FIRST 1 ROW ONLY),
            NULL,
            NULL,
            NULL
        );
    END LOOP;
    dbms_output.put_line('Order table populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateEmployeeInOrder(probability IN NUMBER) AS
    teamRef REF TeamTY;
BEGIN
    dbms_output.put_line('Populating Employee in Order...');
    FOR orderRow IN (SELECT o.ID, DEREF(o.team) AS team FROM OrderTB o) LOOP
        -- Only process orders based on probability
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
    dbms_output.put_line('Employee in Order populated.');
END;
/

CREATE OR REPLACE PROCEDURE populateCompletionDateAndFeedbackInOrder(probability IN NUMBER) AS
v_team_id VARCHAR2(50);
v_team_name VARCHAR2(50);
v_team_score NUMBER;
BEGIN
    dbms_output.put_line('Populating Completion Date and Feedback in Order...');
    FOR orderRow IN (SELECT o.ID FROM OrderTB o) LOOP
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

            -- Select id, name and performancescore of the team just updated
            SELECT t.ID, t.name, t.performanceScore
            INTO v_team_id, v_team_name, v_team_score
            FROM TeamTB t
            WHERE t.ID = (SELECT DEREF(o.team).ID FROM OrderTB o WHERE o.ID = orderRow.ID);
        
            -- print the team id, name and performance score
            dbms_output.put_line('Team ' || v_team_id || ' (' || v_team_name || ') has performance score ' || v_team_score);
        END IF;
    END LOOP;
    dbms_output.put_line('Completion Date and Feedback in Order populated.');
END;
/

BEGIN
    dbms_output.put_line('Starting population...');
    populateCustomer(100, 100);
    populateOperationalCenter(10);
    populateBusinessAccount(100);
    populateTeam(100); 
    populateEmployee(100);
    populateOrder(1000);
    populateEmployeeInOrder(0.6);
    populateCompletionDateAndFeedbackInOrder(0.6);
    dbms_output.put_line('Population completed.');
END;
/

SELECT ID, numOrder 
FROM TeamTB 
WHERE numOrder = (SELECT MAX(numOrder) FROM TeamTB)
FETCH FIRST 1 ROW ONLY;
/

-- First query: Select all orders for a specific team (e.g., team 'T000001')
SELECT feedback
FROM OrderTB o
WHERE DEREF(o.team).ID = (SELECT ID
FROM TeamTB 
WHERE numOrder = (SELECT MAX(numOrder) FROM TeamTB) FETCH FIRST 1 ROW ONLY)
ORDER BY o.placingDate;
/

-- Second query: Select the performance score for the same team
SELECT t.ID, t.name, t.performanceScore
FROM TeamTB t
WHERE t.ID = (SELECT ID
FROM TeamTB 
WHERE numOrder = (SELECT MAX(numOrder) FROM TeamTB) FETCH FIRST 1 ROW ONLY);
/

commit work;
/

-- SELECT t.ID, t.numOrder
-- FROM TeamTB t 
-- order by t.numOrder desc;


-- DECLARE
--     v_team_id VARCHAR2(50);
--     v_num NUMBER;
-- BEGIN
--     -- Get the team ID with max number of orders

    
--     SELECT t.ID, t.numOrder INTO v_team_id, v_num
--     FROM TeamTB t 
--     order by t.numOrder desc 
--     FETCH FIRST 1 ROW ONLY;
    
--     -- Show orders for this team
--     dbms_output.put_line('Orders for team ' || v_team_id || ':');
--     FOR ord IN (
--         SELECT o.ID, o.placingDate, o.orderType, o.cost
--         FROM OrderTB o
--         WHERE DEREF(o.team).ID = v_team_id
--     ) LOOP
--         dbms_output.put_line('Order ID: ' || ord.ID || ', Date: ' || ord.placingDate || 
--                             ', Type: ' || ord.orderType || ', Cost: ' || ord.cost);
--     END LOOP;

--     -- Count orders for this team
--     DECLARE
--         v_count NUMBER;
--     BEGIN
--         SELECT COUNT(*) INTO v_count
--         FROM OrderTB o
--         WHERE DEREF(o.team).ID = v_team_id;
        
--         dbms_output.put_line('Total orders for team ' || v_team_id || ': ' || v_count);
--     END;
-- END;
-- /

-- TODO: provare a fare sta roba, per ora non funziona
-- BEGIN
--     -- First, drop the chain if it already exists
--     BEGIN
--         DBMS_SCHEDULER.drop_chain('populate_chain', FORCE => TRUE);
--     EXCEPTION
--         WHEN OTHERS THEN
--             NULL; -- Ignore if chain doesn't exist
--     END;

--     -- Create the chain
--     DBMS_SCHEDULER.create_chain(
--         chain_name => 'populate_chain',
--         rule_set   => NULL,
--         evaluation_interval => NULL,
--         comments    => 'Chain to populate database tables in parallel with dependencies'
--     );

--     -- Define chain steps (each procedure becomes a step)
--     DBMS_SCHEDULER.define_chain_step(
--         chain_name => 'populate_chain',
--         step_name  => 'customer_step',
--         job_action => 'BEGIN populateCustomer(100, 100); END;'
--     );

--     DBMS_SCHEDULER.define_chain_step(
--         chain_name => 'populate_chain',
--         step_name  => 'center_step',
--         job_action => 'BEGIN populateOperationalCenter(10); END;'
--     );

--     DBMS_SCHEDULER.define_chain_step(
--         chain_name => 'populate_chain',
--         step_name  => 'account_step',
--         job_action => 'BEGIN populateBusinessAccount(100); END;'
--     );

--     DBMS_SCHEDULER.define_chain_step(
--         chain_name => 'populate_chain',
--         step_name  => 'team_step',
--         job_action => 'BEGIN populateTeam(100); END;'
--     );

--     DBMS_SCHEDULER.define_chain_step(
--         chain_name => 'populate_chain',
--         step_name  => 'employee_step',
--         job_action => 'BEGIN populateEmployee(100); END;'
--     );

--     DBMS_SCHEDULER.define_chain_step(
--         chain_name => 'populate_chain',
--         step_name  => 'order_step',
--         job_action => 'BEGIN populateOrder(1000); END;'
--     );

--     DBMS_SCHEDULER.define_chain_step(
--         chain_name => 'populate_chain',
--         step_name  => 'emp_in_order_step',
--         job_action => 'BEGIN populateEmployeeInOrder(0.5); END;'
--     );

--     -- Define chain rules to manage dependencies and parallel execution

--     -- Start customer_step and center_step immediately
--     DBMS_SCHEDULER.define_chain_rule(
--         chain_name => 'populate_chain',
--         condition  => 'TRUE',
--         action     => 'START customer_step, center_step'
--     );

--     -- account_step starts after customer_step completes
--     DBMS_SCHEDULER.define_chain_rule(
--         chain_name => 'populate_chain',
--         condition  => 'customer_step COMPLETED',
--         action     => 'START account_step'
--     );

--     -- team_step starts after center_step completes
--     DBMS_SCHEDULER.define_chain_rule(
--         chain_name => 'populate_chain',
--         condition  => 'center_step COMPLETED',
--         action     => 'START team_step'
--     );

--     -- employee_step starts after team_step completes
--     DBMS_SCHEDULER.define_chain_rule(
--         chain_name => 'populate_chain',
--         condition  => 'team_step COMPLETED',
--         action     => 'START employee_step'
--     );

--     -- order_step starts after employee_step completes
--     DBMS_SCHEDULER.define_chain_rule(
--         chain_name => 'populate_chain',
--         condition  => 'employee_step COMPLETED',
--         action     => 'START order_step'
--     );

--     -- emp_in_order_step starts after order_step completes
--     DBMS_SCHEDULER.define_chain_rule(
--         chain_name => 'populate_chain',
--         condition  => 'order_step COMPLETED',
--         action     => 'START emp_in_order_step'
--     );

--     -- End the chain after emp_in_order_step completes
--     DBMS_SCHEDULER.define_chain_rule(
--         chain_name => 'populate_chain',
--         condition  => 'emp_in_order_step COMPLETED',
--         action     => 'END'
--     );

--     -- Enable the chain
--     DBMS_SCHEDULER.enable('populate_chain');

--     -- Create a job to run the chain
--     DBMS_SCHEDULER.create_job(
--         job_name   => 'job_populate_chain',
--         job_type   => 'CHAIN',
--         job_action => 'populate_chain',
--         start_date => SYSTIMESTAMP,
--         enabled    => TRUE,
--         auto_drop  => FALSE,
--         comments   => 'Job to execute populate_chain'
--     );

--     DBMS_OUTPUT.put_line('Chain created and job started.');
-- END;
-- /
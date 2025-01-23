connect brightway_admin/BRIGHTWAY_ADMIN;

-- Operation 1: Register a new customer
CREATE OR REPLACE PROCEDURE registerCustomer(
    VAT IN VARCHAR2,
    phone IN VARCHAR2,
    email IN VARCHAR2,
    type IN VARCHAR2,
    name IN VARCHAR2,
    surname IN VARCHAR2,
    dob IN DATE,
    companyName IN VARCHAR2,
    address IN AddressTY
) AS
    customer CustomerTY;
BEGIN
    IF type = 'individual' THEN
        customer := CustomerTY(VAT, phone, email, type, name, surname, dob, NULL, address);
    ELSIF type = 'business' THEN
        customer := CustomerTY(VAT, phone, email, type, NULL, NULL, NULL, companyName, address);
    ELSE
        RAISE_APPLICATION_ERROR(-20000, 'Invalid customer type; must be either individual or business');
    END IF;
    INSERT INTO CustomerTB VALUES customer;
    COMMIT;
END;
/

-- Operation 2: Add a new order
CREATE OR REPLACE PROCEDURE addOrder(
    ID IN VARCHAR2,
    placingDate IN DATE,
    orderMode IN VARCHAR2,
    orderType IN VARCHAR2,
    cost IN NUMBER,
    businessAccountName IN VARCHAR2,
    employees IN EmployeeVA DEFAULT NULL
) AS 
    baRef REF BusinessAccountTY;
BEGIN
    SELECT REF(b)
    INTO baRef
    FROM BusinessAccountTB b
    WHERE b.CODE = businessAccountName;

    INSERT INTO OrderTB (ID, placingDate, orderMode, orderType, cost, businessAccount, employees) VALUES (ID, placingDate, orderMode, orderType, cost, baRef, employees);
    COMMIT;
END;
/

-- Operation 3: Assign an order to a team
CREATE OR REPLACE PROCEDURE assignOrderToTeam(
    orderID IN VARCHAR2,
    teamID IN VARCHAR2
) AS
BEGIN
    -- Update the order with the team reference
    UPDATE OrderTB
    SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = teamID)
    WHERE ID = orderID;
    COMMIT;
END;
/

-- Operation 4A: View the total number of operations handled by a specific team
CREATE OR REPLACE FUNCTION totalNumOrder(
    teamID IN VARCHAR2
) RETURN NUMBER AS
    v_count NUMBER;
BEGIN
    SELECT numOrder INTO v_count
    FROM TeamTB
    WHERE ID = teamID;
    RETURN NVL(v_count, 0);
END;
/

-- Operation 4B: Show the total cost of the orders handled by one specific team
CREATE OR REPLACE FUNCTION totalOrderCost(
    teamID IN VARCHAR2
) RETURN NUMBER AS
    totalCost NUMBER;
BEGIN
    SELECT SUM(cost) INTO totalCost
    FROM OrderTB o
    WHERE o.team.ID = teamID;
    RETURN NVL(totalCost, 0);
END;
/

-- Operation 5: Print list of teams sorted by performance score
CREATE OR REPLACE PROCEDURE printTeamsByPerformanceScore AS
BEGIN
    FOR team IN (SELECT * FROM TeamTB ORDER BY performanceScore DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('Team ID: ' || team.ID || ', Performance Score: ' || team.performanceScore);
    END LOOP;
    COMMIT;
END;
/

-- -- -- Insert Operational Centers with AddressTY
-- -- INSERT INTO OperationalCenterTB VALUES ('OC1', AddressTY('123 Main St', 1, 'City1', 'Province1', 'Region1', 'State1'));
-- -- INSERT INTO OperationalCenterTB VALUES ('OC2', AddressTY('456 Elm St', 2, 'City2', 'Province2', 'Region2', 'State2'));
-- -- INSERT INTO OperationalCenterTB VALUES ('OC3', AddressTY('789 Oak St', 3, 'City3', 'Province3', 'Region3', 'State3'));

-- -- INSERT INTO TeamTB VALUES ('T000001', 'Team 1', 0, 5, (SELECT REF(oc) FROM OperationalCenterTB oc WHERE oc.name = 'OC1'));
-- -- INSERT INTO TeamTB VALUES ('T000002', 'Team 2', 0, 4, (SELECT REF(oc) FROM OperationalCenterTB oc WHERE oc.name = 'OC1'));
-- -- INSERT INTO TeamTB VALUES ('T000003', 'Team 3', 0, 3, (SELECT REF(oc) FROM OperationalCenterTB oc WHERE oc.name = 'OC2'));


-- -- INSERT INTO EmployeeTB VALUES ('1234567890123456', 'John', 'Doe', TO_DATE('01-01-2000', 'DD-MM-YYYY'), '123456789', 'a@a.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000001'));
-- -- INSERT INTO EmployeeTB VALUES ('1234567890123457', 'Jane', 'Doe', TO_DATE('01-01-2000', 'DD-MM-YYYY'), '123456789', 'b@b.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000001'));

-- -- INSERT INTO CustomerTB VALUES ('12345678901', '123456789', 'a@a.com', 'individual', 'John', 'Doe', TO_DATE('01-01-2000', 'DD-MM-YYYY'), NULL, NULL);

-- -- INSERT INTO BusinessAccountTB VALUES ('B000000001', SYSDATE, (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = '12345678901'));

-- -- execute addOrder('O000001111', SYSDATE, 'online', 'regular', 100.00, 'B000000001', EmployeeVA());
-- -- /

-- -- execute assignOrderToTeam('O000001111', 'T000001');
-- -- /

-- -- select totalNumOrder('T000001') from dual;
-- -- /

-- -- select totalOrderCost('T000001') from dual;
-- -- /


-- Operation 1 == Explain plan
EXPLAIN PLAN FOR INSERT INTO CustomerTB VALUES ('12345678901', '123456789', 'a@a.com', 'individual', 'John', 'Doe', TO_DATE('01-01-2000', 'DD-MM-YYYY'), NULL, NULL);

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Operation 2 == Explain plan
EXPLAIN PLAN FOR
(SELECT REF(b) FROM BusinessAccountTB b
WHERE b.CODE = 'B000000001');

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Operation 3 == Explain Plan
EXPLAIN PLAN FOR
INSERT INTO OrderTB (ID, placingDate, orderMode, orderType, cost, businessAccount, employees) VALUES ('O000001111', SYSDATE, 'online', 'regular', 100.00, (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000001'), EmployeeVA());

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Explain plan for INSERT INTO OrderTB
EXPLAIN PLAN FOR
INSERT INTO OrderTB (ID, placingDate, orderMode, orderType, cost, businessAccount, employees)
VALUES ('O000001111', SYSDATE, 'online', 'regular', 100.00, (SELECT REF(b) FROM BusinessAccountTB b
WHERE b.CODE = 'B000000001'), EmployeeVA());

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Operation 3 == Explain Plan
EXPLAIN PLAN FOR
UPDATE OrderTB o
SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000001')
WHERE o.ID = 'O000001111';

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Operation 4A == Explain Plan
EXPLAIN PLAN FOR
SELECT numOrder
FROM TeamTB
WHERE ID = 'T000001';

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Operation 4B == Explain Plan
-- TODO: PRENDERE QUELLO CON PIU ORDINI
EXPLAIN PLAN FOR
SELECT SUM(cost)
FROM OrderTB o
WHERE o.team.ID = 'T000001';

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/


-- Operation 5 == Explain Plan
EXPLAIN PLAN FOR
SELECT * 
FROM TeamTB 
ORDER BY performanceScore DESC;

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

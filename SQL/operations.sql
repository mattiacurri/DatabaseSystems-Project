CONNECT brightway_admin/BRIGHTWAY_ADMIN@localhost:1521/xepdb1;

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
        IF VAT IS NULL THEN
            customer := CustomerTY(SYS_GUID(), phone, email, type, name, surname, dob, NULL, NULL);
        ELSE
            customer := CustomerTY(VAT, phone, email, type, name, surname, dob, NULL, NULL);
        END IF;
    ELSIF type = 'business' THEN
        IF VAT IS NULL THEN
            customer := CustomerTY(SYS_GUID(), phone, email, type, NULL, NULL, NULL, companyName, address);
        ELSE
            customer := CustomerTY(VAT, phone, email, type, NULL, NULL, NULL, companyName, address);
        END IF;
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
    IF ID IS NULL THEN
        INSERT INTO OrderTB (ID, placingDate, orderMode, orderType, cost, businessAccount, employees) VALUES (sys_GUID(), placingDate, orderMode, orderType, cost, baRef, employees);
    ELSE
        INSERT INTO OrderTB (ID, placingDate, orderMode, orderType, cost, businessAccount, employees) VALUES (ID, placingDate, orderMode, orderType, cost, baRef, employees);
    END IF;
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

-- Operation 1 == Explain plan
EXPLAIN PLAN FOR INSERT INTO CustomerTB VALUES (sys_guid(), '123456789', 'a@a.com', 'individual', 'John', 'Doe', TO_DATE('01-01-2000', 'DD-MM-YYYY'), NULL, NULL);

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Operation 2 == Explain plan
EXPLAIN PLAN FOR
(SELECT REF(b) FROM BusinessAccountTB b
WHERE b.CODE = 'B000000001');

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

EXPLAIN PLAN FOR
INSERT INTO OrderTB (ID, placingDate, orderMode, orderType, cost, businessAccount, employees) VALUES ('O000001111', SYSDATE, 'online', 'regular', 100.00, (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000001'), EmployeeVA());
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
-- * choose the teamId with the most orders
EXPLAIN PLAN FOR
SELECT numOrder
FROM TeamTB
WHERE ID = '2C6535D4B8FF9D06E063020012AC4D2C';

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Operation 4B == Explain Plan
-- * choose the teamId with the most orders
EXPLAIN PLAN FOR
SELECT SUM(cost)
FROM OrderTB o
WHERE o.team.ID = '2C6535D4B8FF9D06E063020012AC4D2C';

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/

-- Operation 5 == Explain Plan
EXPLAIN PLAN FOR
SELECT * 
FROM TeamTB 
ORDER BY performanceScore DESC;

SELECT * FROM table(DBMS_XPLAN.DISPLAY);
/
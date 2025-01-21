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
    street IN VARCHAR2,
    civicNum IN NUMBER,
    city IN VARCHAR2,
    province IN VARCHAR2,
    region IN VARCHAR2,
    state IN VARCHAR2
) AS
    address AddressTY;
    customer CustomerTY;
BEGIN
    address := AddressTY(street, civicNum, city, province, region, state);
    IF type = 'individual' THEN
        customer := CustomerTY(VAT, phone, email, type, name, surname, dob, NULL, address);
    ELSE
        customer := CustomerTY(VAT, phone, email, type, NULL, NULL, NULL, companyName, address);
    END IF;
    INSERT INTO CustomerTB VALUES customer;
END;
/

-- Operation 2: Add a new order
CREATE OR REPLACE PROCEDURE addOrder(
    ID IN VARCHAR2,
    placingDate IN DATE,
    orderMode IN VARCHAR2,
    orderType IN VARCHAR2,
    cost IN NUMBER,
    businessAccount IN REF BusinessAccountTY,
    teamID IN REF TeamTY DEFAULT NULL,
    employees IN EmployeeVA DEFAULT NULL,
    completionDate IN DATE DEFAULT NULL,
    feedback IN FeedbackTY DEFAULT NULL
) AS 
    new_order OrderTY;
BEGIN
    IF teamID IS NULL THEN
        new_order := OrderTY(ID, placingDate, orderMode, orderType, cost, businessAccount, NULL, employees, completionDate, feedback);
    ELSE
        new_order := OrderTY(ID, placingDate, orderMode, orderType, cost, businessAccount, teamID, employees, completionDate, feedback);
    END IF;
    INSERT INTO OrderTB VALUES new_order;
END;
/

-- Operation 3: Assign an order to a team
CREATE OR REPLACE PROCEDURE assignOrderToTeam(
    orderID IN REF OrderTY,
    teamID IN REF TeamTY
) AS
    n_team REF TeamTY;
    order_ref REF OrderTY;
BEGIN
    SELECT REF(t)
    INTO n_team
    FROM TeamTB t
    WHERE t.ID = deref(teamID).ID;
    
    SELECT REF(o)
    INTO order_ref
    FROM OrderTB o
    WHERE o.ID = deref(orderID).ID;
    
    UPDATE OrderTB
    SET team = n_team
    WHERE ID = deref(orderID).ID;
END;
/

-- Operation 4: Show the total cost of the orders handled by one specific team
CREATE OR REPLACE FUNCTION totalCostOfOrders(
    teamID IN VARCHAR2
) RETURN NUMBER AS
    totalCost NUMBER;
BEGIN
    SELECT SUM(cost)
    INTO totalCost
    FROM OrderTB o
    WHERE o.team.ID = teamID;
    RETURN totalCost;
END;
/

-- Operation 5: Print list of teams sorted by performance score
CREATE OR REPLACE PROCEDURE printTeamsByPerformanceScore AS
BEGIN
    FOR team IN (SELECT * FROM TeamTB ORDER BY performanceScore DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('Team ID: ' || team.ID || ', Performance Score: ' || team.performanceScore);
    END LOOP;
END;
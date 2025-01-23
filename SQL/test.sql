CONNECT brightway_admin/BRIGHTWAY_ADMIN@localhost:1521/xepdb1;

INSERT INTO OperationalCenterTB VALUES (
    OperationalCenterTY('Center1', AddressTY('Via Roma', 12, 'Roma', 'RM', 'Lazio', 'Italia'))
);
/

INSERT INTO TeamTB VALUES (
    TeamTY('T000001', 'Team1', 1, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);
INSERT INTO TeamTB VALUES (
    TeamTY('T000002', 'Team12', 0, 2.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);
INSERT INTO TeamTB VALUES (
    TeamTY('T000003', 'Team3', 0, 3.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);
INSERT INTO TeamTB VALUES (
    TeamTY('T000004', 'Team4', 0, 4.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);

SELECT ID, numOrder, performanceScore FROM TeamTB; WHERE ID IN ('T000001', 'T000002', 'T000003', 'T000004');

INSERT INTO EmployeeTB VALUES (
    EmployeeTY('FC00000000000001', 'Mario', 'Rossi', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000001'))
);
INSERT INTO EmployeeTB VALUES (
    EmployeeTY('FC00000000000002', 'Luigi', 'Verdi', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000002'))
);
INSERT INTO EmployeeTB VALUES (
    EmployeeTY('FC00000000000003', 'Luigi', 'Verdi', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000001'))
);

-- Insert 9 employees for team T000004
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000004', 'Emp4', 'Last4', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e4@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000005', 'Emp5', 'Last5', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e5@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000006', 'Emp6', 'Last6', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e6@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000007', 'Emp7', 'Last7', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e7@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000008', 'Emp8', 'Last8', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e8@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000009', 'Emp9', 'Last9', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e9@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000010', 'Emp10', 'Last10', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e10@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000011', 'Emp11', 'Last11', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e11@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));

-- ! Max number of employee --> BRIGHTWAY_ADMIN.CHECKNUMEMPLOYEEINTEAM
INSERT INTO EmployeeTB VALUES (EmployeeTY('FC00000000000012', 'Emp12', 'Last12', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '3331234567', 'e12@e.com', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004')));

-- Change two employees to team T000003
UPDATE EmployeeTB SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000003') WHERE FC IN ('FC00000000000006', 'FC00000000000007');

-- Change them back to T000004
UPDATE EmployeeTB SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000004') WHERE FC IN ('FC00000000000006', 'FC00000000000007');
/

INSERT INTO CustomerTB VALUES (
    CustomerTY('00000000001', '3331234567', 'a@a.com', 'individual', 'Mario', 'Rossi', TO_DATE('01/01/1990', 'DD/MM/YYYY'), NULL, NULL)
);
/

INSERT INTO CustomerTB VALUES (
    CustomerTY('00000000002', '3331234567', 'a@a.com', 'individual', 'Luigi', 'Verdi', TO_DATE('01/01/1990', 'DD/MM/YYYY'), NULL, NULL)
);
/

SELECT * FROM CustomerTB where VAT IN ('00000000001', '00000000002');
SELECT code, creationdate, deref(customer) FROM BusinessAccountTB where deref(customer).VAT IN ('00000000001', '00000000002');

INSERT INTO BusinessAccountTB VALUES (
    BusinessAccountTY('B000000002', TO_DATE('01/01/2021', 'DD/MM/YYYY'), (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = '00000000001'))
);
/

INSERT INTO BusinessAccountTB VALUES (
    BusinessAccountTY('B000000010', TO_DATE('01/01/2021', 'DD/MM/YYYY'), (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = '00000000001'))
);
/

SELECT code FROM BusinessAccountTB WHERE code IN ('B000000002', 'B000000010');
/

-- ! Test trigger ComputePerformanceScore
SELECT ID, numOrder, performanceScore FROM TeamTB;
/

INSERT INTO OrderTB VALUES (
    OrderTY('O000000001', TO_DATE('01/01/2011', 'DD/MM/YYYY'), 'online', 'regular', 10.0, (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'), (SELECT REF(t) FROM TeamTB t where t.ID = 'T000001'), EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000001')), TO_DATE('01/01/2021', 'DD/MM/YYYY'), FeedbackTY(5, 'Good'))
);
/

SELECT ID, numOrder, performanceScore FROM TeamTB WHERE ID = 'T000001';
/

-- ! Employee of a different team in the same order detected --> BRIGHTWAY_ADMIN.CHECKORDERINSERTORUPDATE
INSERT INTO OrderTB VALUES (
    OrderTY('O000000004', TO_DATE('01/01/2011', 'DD/MM/YYYY'), 'online', 'regular', 10.0, (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'), (SELECT REF(t) FROM TeamTB t where t.ID = 'T000003'), EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000001')), null, null)
);
/

INSERT INTO OrderTB VALUES (
    OrderTY('O000000004', TO_DATE('01/01/2011', 'DD/MM/YYYY'), 'online', 'regular', 10.0, (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'), (SELECT REF(t) FROM TeamTB t where t.ID = 'T000004'), EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000004')), null, null)
);
/

SELECT ID, numOrder, performanceScore FROM TeamTB WHERE ID IN ('T000003', 'T000004');
/

INSERT INTO OrderTB VALUES (
    OrderTY('O000000002', TO_DATE('01/01/2011', 'DD/MM/YYYY'), 'online', 'regular', 10.0, (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'), NULL, EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000002')), NULL, NULL)
);
/

INSERT INTO OrderTB VALUES (
    OrderTY('MOVEORDER', SYSDATE, 'online', 'regular', 10.0, 
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000001'),
    NULL, null, null)
);
/

SELECT ID, numOrder, performanceScore 
FROM TeamTB 
WHERE ID IN ('T000001', 'T000002');
/

UPDATE OrderTB 
SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000002')
WHERE ID = 'MOVEORDER';
/

SELECT ID, numOrder, performanceScore 
FROM TeamTB 
WHERE ID IN ('T000001', 'T000002');
/

UPDATE OrderTB
SET completionDate = placingDate + 2
WHERE ID = 'MOVEORDER';
/

UPDATE OrderTB
SET feedback = FeedbackTY(3, 'Excellent')
WHERE ID = 'MOVEORDER';
/

-- expected: t1 1 order, t2 1 order
SELECT ID, numOrder, performanceScore
FROM TeamTB
WHERE ID IN ('T000001', 'T000002');
/

-- ! Team cannot be changed after order completion --> BRIGHTWAY_ADMIN.CHECKORDERINSERTORUPDATE
UPDATE OrderTB
SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000001')
WHERE ID = 'MOVEORDER';
/

SELECT ID, numOrder, performanceScore
FROM TeamTB
WHERE ID IN ('T000001', 'T000002');
/


-- ! Feedback cannot be given without completion date --> BRIGHTWAY_ADMIN.CHECKORDERINSERTORUPDATE
INSERT INTO OrderTB VALUES (
    OrderTY('O000000003', TO_DATE('01/01/2011', 'DD/MM/YYYY'), 'online', 'regular', 10.0, (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'), NULL, EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000002')), NULL, FeedbackTY(5, 'Good'))
);
/

-- ! Cannot update employees of a completed order --> BRIGHTWAY_ADMIN.CHECKORDERINSERTORUPDATE
UPDATE OrderTB SET employees = EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000003')) WHERE ID = 'O000000001';
/

-------------------------

-- ! Test DeleteTeamAfterOperationalCenter
INSERT INTO OperationalCenterTB VALUES (
    OperationalCenterTY('TestCenter', AddressTY('Via Test', 1, 'Test City', 'TC', 'Test Region', 'Test Country'))
);
/
INSERT INTO TeamTB VALUES (
    TeamTY('T000005', 'TestTeam1', 0, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'TestCenter'))
);
/
-- Check initial state
SELECT * FROM TeamTB WHERE ID = 'T000005';
/
-- Delete operational center and verify team is also deleted
DELETE FROM OperationalCenterTB WHERE name = 'TestCenter';
/
-- No row should be returned
SELECT * FROM TeamTB WHERE ID = 'T000005';
/
-- ! Test UpdateEmployeeAfterTeam
INSERT INTO TeamTB VALUES (
    TeamTY('T000006', 'TestTeam2', 0, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);
/
INSERT INTO EmployeeTB VALUES (
    EmployeeTY('FC00000000000013', 'Test', 'Employee', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '1234567890', 'test@test.com', 
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000006'))
);
/
-- Check initial state
SELECT FC, DEREF(team).ID FROM EmployeeTB WHERE FC = 'FC00000000000013';
/
-- Delete team and verify employee's team reference is set to NULL
DELETE FROM TeamTB WHERE ID = 'T000006';
/
-- Team reference set to NULL
SELECT FC, team FROM EmployeeTB WHERE FC = 'FC00000000000013';
/
-- ! Test DeleteAccountAfterCustomer
INSERT INTO CustomerTB VALUES (
    CustomerTY('00000000003', '1234567890', 'test@test.com', 'individual', 'Test', 'Customer', 
    TO_DATE('01/01/1990', 'DD/MM/YYYY'), NULL, NULL)
);
/
-- Check initial state
SELECT code, DEREF(customer).VAT as VAT FROM BusinessAccountTB WHERE DEREF(customer).VAT = '00000000003';
/
-- Delete customer and verify business account is also deleted
DELETE FROM CustomerTB WHERE VAT = '00000000003';
/
SELECT code FROM BusinessAccountTB WHERE code IN (SELECT code FROM BusinessAccountTB WHERE DEREF(customer).VAT = '00000000003');
/

-- ! Test DeleteOrdersAfterTeam and PreventOrderDeletion
INSERT INTO TeamTB VALUES (
    TeamTY('T000007', 'TestTeam3', 0, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);
/
INSERT INTO OrderTB VALUES (
    OrderTY('O000000005', SYSDATE, 'online', 'regular', 10.0, 
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000007'),
    NULL, NULL, NULL)
);
/
-- Check initial state
SELECT ID, DEREF(team).ID FROM OrderTB WHERE ID = 'O000000005';
/
-- Delete team and verify order is deleted
DELETE FROM TeamTB WHERE ID = 'T000007';
/

SELECT ID FROM OrderTB WHERE ID = 'O000000005';
/

-- ! Test DeleteOrdersAfterAccount and PreventOrderDeletion
INSERT INTO OrderTB VALUES (
    OrderTY('O000000006', SYSDATE, 'online', 'regular', 10.0, 
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'),
    NULL, NULL, NULL, NULL)
);
/

-- ! Test EmptyEmployeeListAfterTeamUpdate
INSERT INTO TeamTB VALUES (
    TeamTY('T000008', 'TestTeam4', 0, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);
/
INSERT INTO TeamTB VALUES (
    TeamTY('T000009', 'TestTeam5', 0, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);
/
INSERT INTO EmployeeTB VALUES (
    EmployeeTY('FC00000000000014', 'Test', 'Employee2', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '1234567890', 'test2@test.com', 
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000008'))
);
/
INSERT INTO OrderTB VALUES (
    OrderTY('O000000007', SYSDATE, 'online', 'regular', 10.0, 
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000002'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000008'),
    EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000014')),
    NULL, NULL)
);
/

-- Check initial state
SELECT o.ID, DEREF(o.team).ID, e.column_value.FC 
FROM OrderTB o, TABLE(o.employees) e 
WHERE o.ID = 'O000000007';
/

-- Update team and verify employee list is emptied
UPDATE OrderTB SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000009')
WHERE ID = 'O000000007';
/

SELECT o.ID, DEREF(o.team).ID
FROM OrderTB o 
WHERE o.ID = 'O000000007';
/

-- Expected: no rows returned
SELECT o.ID, DEREF(o.team).ID, e.column_value.FC 
FROM OrderTB o, TABLE(o.employees) e 
WHERE o.ID = 'O000000007';
/

-- More test on deletion
INSERT INTO OperationalCenterTB VALUES (
    OperationalCenterTY('TestCenter2', AddressTY('Via Test', 100, 'Milano', 'MI', 'Lombardia', 'Italia'))
);
/

INSERT INTO TeamTB VALUES (
    TeamTY('T000010', 'TestTeam6', 0, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'TestCenter2'))
);
/

INSERT INTO EmployeeTB VALUES (
    EmployeeTY('FC00000000000015', 'Test', 'Employee1', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '1234567890', 'test1@test.com', 
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000010'))
);
/

INSERT INTO EmployeeTB VALUES (
    EmployeeTY('FC00000000000016', 'Test', 'Employee2', TO_DATE('01/01/1990', 'DD/MM/YYYY'), '1234567890', 'test2@test.com', 
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000010'))
);
/

INSERT INTO CustomerTB VALUES (
    CustomerTY('00000000004', '3331234567', 'test@test.com', 'individual', 'Test', 'Customer', 
    TO_DATE('01/01/1990', 'DD/MM/YYYY'), NULL, NULL)
);
/

INSERT INTO BusinessAccountTB VALUES (
    BusinessAccountTY('B000000003', TO_DATE('01/01/2023', 'DD/MM/YYYY'), 
    (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = '00000000004'))
);
/

-- Create orders with different combinations
-- 1. Complete order with all values
INSERT INTO OrderTB VALUES (
    OrderTY('ALLVALUES', SYSDATE, 'online', 'regular', 100.0,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000003'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000010'),
    EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000015')),
    SYSDATE + 1,
    FeedbackTY(5, 'Excellent service'))
);
/

-- 2. Order without completion date and feedback
INSERT INTO OrderTB VALUES (
    OrderTY('WITHOUTCOMPLETIONFEED', SYSDATE, 'phone', 'urgent', 150.0,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000003'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000010'),
    EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000016')),
    NULL,
    NULL)
);
/

-- 3. Order with team but no employees
INSERT INTO OrderTB VALUES (
    OrderTY('TEAMNOEMPLO', SYSDATE, 'email', 'bulk', 200.0,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000003'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000010'),
    NULL,
    NULL,
    NULL)
);
/

-- 4. Order with no team but with employee
INSERT INTO OrderTB VALUES (
    OrderTY('NOTEAMWITHEMPLO', SYSDATE, 'online', 'regular', 75.0,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000003'),
    NULL,
    EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000015')),
    NULL,
    NULL)
);
/

-- 5. Order with completion date but no feedback
INSERT INTO OrderTB VALUES (
    OrderTY('COMPLETIONNOFEEDBACK', SYSDATE, 'phone', 'urgent', 300.0,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000003'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000010'),
    EmployeeVA((SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000015')),
    SYSDATE + 2,
    NULL)
);
/

-- 6. Order with multiple employees
INSERT INTO OrderTB VALUES (
    OrderTY('MULTIPLE EMPLOYEES', SYSDATE, 'email', 'regular', 250.0,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000003'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T000010'),
    EmployeeVA(
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000015'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'FC00000000000016')
    ),
    NULL,
    NULL)
);
/

-- Verify the insertions
SELECT ID, numOrder, performanceScore FROM TeamTB;
SELECT ID, DEREF(team).ID, completionDate, o.feedback.score, DEREF(businessAccount)
FROM OrderTB o;

-- Check employee assignments
SELECT o.ID, e.column_value.FC 
FROM OrderTB o, TABLE(o.employees) e;

-- Now try to delete the team and verify the orders are deleted
DELETE FROM TeamTB WHERE ID = 'T000010';

-- Verify that no orders are deleted
SELECT ID, DEREF(team).ID, completionDate, o.feedback.score, DEREF(businessAccount)
FROM OrderTB o;

-- Check employee assignments
SELECT o.ID, e.column_value.FC
FROM OrderTB o, TABLE(o.employees) e;

-- now delete a business account
DELETE FROM BusinessAccountTB WHERE CODE = 'B000000003';

-- Verify that the six orders previously defined are deleted
SELECT ID, DEREF(team).ID, completionDate, o.feedback.score, DEREF(businessAccount)
FROM OrderTB o;

-- Try to delete all orders and verify that they are not deleted
-- ! Order deletion not allowed in this case --> BRIGHTWAY_ADMIN.PREVENTORDERDELETION
DELETE FROM OrderTB WHERE ID = 'O000000001';
DELETE FROM OrderTB WHERE ID = 'O000000002';
DELETE FROM OrderTB WHERE ID = 'O000000004';
DELETE FROM OrderTB WHERE ID = 'MOVEORDER';
DELETE FROM OrderTB WHERE ID = 'O000000005';
DELETE FROM OrderTB WHERE ID = 'O000000006';
DELETE FROM OrderTB WHERE ID = 'O000000007';

-- Test numOrder delete
SELECT ID, numOrder, performanceScore from TeamTB WHERE ID IN ('T000001', 'T000002');
SELECT ID, deref(team) from OrderTB WHERE ID = 'O000000001';
/

DELETE BusinessAccountTB WHERE CODE = 'B000000002';
/

-- expected: 2 rows
SELECT ID, deref(o.team) FROM OrderTB o WHERE ID = 'O000000001';
/

SELECT ID, numOrder, performanceScore from TeamTB WHERE ID IN ('T000001', 'T000002');
/


-- Create test data
INSERT INTO TeamTB VALUES (
    'TEAMTEST1', 'Test Team 1', 0, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1')
);
/
INSERT INTO TeamTB VALUES (
    TeamTY('TEAMTEST2', 'Test Team 2', 0, 1.0, (SELECT REF(o) FROM OperationalCenterTB o WHERE o.name = 'Center1'))
);
/
-- Expected: TEAMTEST1: 0, TEAMTEST2: 0 (initial state)
SELECT ID, numOrder,performanceScore FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/
-- Test 1: Insert order with team
INSERT INTO OrderTB VALUES (
    OrderTY('ORDERTEST1', SYSDATE, 'online', 'regular', 100.0,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000010'),
    (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'TEAMTEST1'),
    NULL, NULL, NULL)
);
/
-- Expected: TEAMTEST1: 1, TEAMTEST2: 0 (TEAMTEST1 increased by 1)
SELECT ID, numOrder,performanceScore FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/
-- Test 2: Update order - change team
UPDATE OrderTB SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'TEAMTEST2')
WHERE ID = 'ORDERTEST1';
/
-- Expected: TEAMTEST1: 0, TEAMTEST2: 1 (TEAMTEST1 decreased by 1, TEAMTEST2 increased by 1)
SELECT ID, numOrder,performanceScore FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/
-- Test 3: Update order - remove team 
UPDATE OrderTB SET team = NULL WHERE ID = 'ORDERTEST1';
/
-- Expected: TEAMTEST1: 0, TEAMTEST2: 0 (TEAMTEST2 decreased by 1)
SELECT ID, numOrder,performanceScore FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/
-- Test 4: Update order - assign team to order without team
UPDATE OrderTB SET team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'TEAMTEST1')
WHERE ID = 'ORDERTEST1';
/
-- Expected: TEAMTEST1: 1, TEAMTEST2: 0 (TEAMTEST1 increased by 1)
SELECT ID, numOrder,performanceScore FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/

-- Test 5: Insert order without team
INSERT INTO OrderTB VALUES (
    OrderTY('ORDERTEST2', SYSDATE, 'online', 'regular', 100.0,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE b.CODE = 'B000000010'),
    NULL, NULL, NULL, NULL)
);
/
-- Expected: TEAMTEST1: 1, TEAMTEST2: 0 (no change, order has no team)
SELECT ID, numOrder,performanceScore FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/
-- Test 6: Delete order with team (not allowed)
DELETE FROM OrderTB WHERE ID = 'ORDERTEST1';
/
-- Expected: TEAMTEST1: 1, TEAMTEST2: 0
SELECT ID, numOrder,performanceScore FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/
-- Test 7: Delete business account from order
DELETE FROM BusinessAccountTB WHERE CODE = 'B000000002';
/
-- Expected: TEAMTEST1: 0, TEAMTEST2: 0
SELECT ID, numOrder,performanceScore FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/
-- Cleanup test data
DELETE FROM TeamTB WHERE ID IN ('TEAMTEST1', 'TEAMTEST2');
/

COMMIT;
/
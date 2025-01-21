CREATE OR REPLACE TRIGGER CheckCompletionDate
BEFORE INSERT OR UPDATE ON OrderTB
FOR EACH ROW
BEGIN
    IF :NEW.completionDate < :NEW.placingDate THEN
        RAISE_APPLICATION_ERROR(-20000, 'Completion date cannot be before order date');
    END IF;

    IF :NEW.completionDate IS NULL THEN
        IF :NEW.feedback IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Feedback cannot be given without completion date');
        END IF;
    END IF;

    IF :NEW.feedback.score IS NOT NULL THEN
        IF :NEW.feedback.score < 1 OR :NEW.feedback.score > 5 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Feedback score must be between 1 and 5');
        END IF;
    END IF;

    -- TODO: capire se mettere, però solo per update su completiondate, altrimenti blocco i cambiamenti per aggiungere i feedback
    ---IF :OLD.completionDate IS NOT NULL THEN
        --RAISE_APPLICATION_ERROR(-20001, 'Order already completed');
    --END IF;
END;
/

CREATE OR REPLACE TRIGGER CheckCustomerType
BEFORE INSERT OR UPDATE ON CustomerTB
FOR EACH ROW
BEGIN
    IF :NEW.type = 'individual' THEN
        IF :NEW.companyName IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Individual customers cannot have a company name');
        END IF;
        IF :NEW.address IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Individual customers cannot have an address');
        END IF;
    ELSIF :NEW.type = 'business' THEN
        IF :NEW.name IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Business customers cannot have a name');
        END IF;
        IF :NEW.surname IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20005, 'Business customers cannot have a surname');
        END IF;
        IF :NEW.dob IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20006, 'Business customers cannot have a date of birth');
        END IF;
    END IF;
END;
/

-- CREATE OR REPLACE TRIGGER CheckOrderEmployee
-- BEFORE INSERT OR UPDATE ON OrderTB
-- FOR EACH ROW
-- DECLARE
--     employee_team TeamTY;
--     order_team TeamTY;
--     v_emp_name VARCHAR2(40);
-- BEGIN
--     IF :NEW.team IS NOT NULL THEN
--         FOR i IN 1..:NEW.employees.COUNT LOOP
--             SELECT DEREF(e.team) INTO employee_team 
--             FROM EmployeeTB e
--             WHERE REF(e) = :NEW.employees(i);

--             SELECT DEREF(:NEW.team) INTO order_team FROM DUAL;

--             IF employee_team.ID != order_team.ID THEN
--                 SELECT e.name || ' ' || e.surname INTO v_emp_name
--                 FROM EmployeeTB e
--                 WHERE REF(e) = :NEW.employees(i);
--                 RAISE_APPLICATION_ERROR(-20007, 'Employee ' || v_emp_name || ' is not in the same team of the order');
--             END IF;
--         END LOOP;
--     END IF;
-- END;
-- /

-- CREATE OR REPLACE TRIGGER CheckOrderEmployee
-- BEFORE INSERT OR UPDATE ON OrderTB
-- FOR EACH ROW
-- DECLARE
--     v_emp_name VARCHAR2(40);
-- BEGIN
--     IF :NEW.team IS NOT NULL AND :NEW.employees IS NOT NULL THEN
--         -- Verifica se almeno un employee non appartiene al team dell'ordine
--         BEGIN
--             SELECT e.name || ' ' || e.surname INTO v_emp_name
--             FROM TABLE(:NEW.employees) emp_ref
--             JOIN EmployeeTB e ON (emp_ref.column_value = REF(e))
--             WHERE e.team <> :NEW.team
--             FETCH FIRST 1 ROW ONLY;  -- Interrompe alla prima occorrenza
            
--             RAISE_APPLICATION_ERROR(-20007, 'Employee ' || v_emp_name || ' is not in the same team of the order');
--         EXCEPTION
--             WHEN NO_DATA_FOUND THEN
--                 NULL; -- Tutti gli employee sono nel team corretto
--         END;
--     END IF;
-- END;
-- /

CREATE OR REPLACE TRIGGER CheckOrderEmployee
BEFORE INSERT OR UPDATE ON OrderTB
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM TABLE(:NEW.employees) emp_ref
    JOIN EmployeeTB e ON (emp_ref.column_value = REF(e))
    WHERE e.team <> :NEW.team;

    IF cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Employee of different team in the same order detected');
    END IF;

    -- TODO: rivedere
    -- IF TEAM IS NULL AND WE ARE INSERTING AN EMPLOYEE THEN SET TEAM TO EMPLOYEE TEAM
    IF :NEW.team IS NULL AND :NEW.employees IS NOT NULL THEN
        SELECT e.team INTO :NEW.team
        FROM TABLE(:NEW.employees) emp_ref
        JOIN EmployeeTB e ON (emp_ref.column_value = REF(e))
        FETCH FIRST 1 ROW ONLY;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER UpdateNumOrdersAfterInsert
AFTER INSERT ON OrderTB
FOR EACH ROW
DECLARE
    v_team TeamTY;
BEGIN
    IF :NEW.team IS NOT NULL THEN
        SELECT DEREF(:NEW.team) INTO v_team FROM DUAL;
        UPDATE TeamTB
        SET numOrder = numOrder + 1
        WHERE ID = v_team.ID;
    END IF;
END;
/

-- CREATE OR REPLACE TRIGGER PreventEmpInsertBeforeTeam
-- AFTER INSERT OR UPDATE ON OrderTB
-- FOR EACH ROW
-- BEGIN
--     IF :NEW.team IS NULL AND :NEW.employees IS NOT NULL THEN
--         FOR i IN 1..:NEW.employees.COUNT LOOP
--             IF :NEW.employees(i) IS NOT NULL THEN
--                 RAISE_APPLICATION_ERROR(-20008, 'Employee cannot be inserted before the team');
--             END IF;
--         END LOOP;
--     END IF;
-- END;
-- /

-- TODO: attenzione rivedere
-- CREATE OR REPLACE TRIGGER UpdateNumOrdersAfterDelete
-- AFTER DELETE ON OrderTB
-- FOR EACH ROW
-- DECLARE
--     v_team TeamTY;
-- BEGIN
--     SELECT DEREF(:OLD.team) INTO v_team FROM DUAL;
--     UPDATE TeamTB
--     SET numOrder = numOrder - 1
--     WHERE ID = v_team.ID;
-- END;
-- /

CREATE OR REPLACE TRIGGER UpdateNumOrdersAfterUpdate
AFTER UPDATE ON OrderTB
FOR EACH ROW
DECLARE
    v_old_team TeamTY;
    v_new_team TeamTY;
BEGIN
    IF :OLD.team IS NOT NULL AND :NEW.team IS NOT NULL THEN
        SELECT DEREF(:OLD.team) INTO v_old_team FROM DUAL;
        SELECT DEREF(:NEW.team) INTO v_new_team FROM DUAL;
        
        IF v_old_team.ID != v_new_team.ID THEN
            UPDATE TeamTB
            SET numOrder = numOrder - 1
            WHERE ID = v_old_team.ID;

            UPDATE TeamTB
            SET numOrder = numOrder + 1
            WHERE ID = v_new_team.ID;
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER ComputeNumOrdersBeforeTeamInsert
BEFORE INSERT ON TeamTB
FOR EACH ROW
BEGIN
    :NEW.numOrder := 0;
    :NEW.performanceScore := 1;
END;
/

CREATE OR REPLACE TRIGGER CheckMaximumNumberEmployees
BEFORE INSERT OR UPDATE OF team ON EmployeeTB
FOR EACH ROW
DECLARE
    v_numEmployees NUMBER;
BEGIN
    IF :NEW.team IS NOT NULL THEN
        SELECT COUNT(*) INTO v_numEmployees
        FROM EmployeeTB
        WHERE team = :NEW.team;

        IF v_numEmployees > 7 THEN
            RAISE_APPLICATION_ERROR(-20009, 'Maximum number of employees reached');
        END IF;
    END IF;
END;
/

-- ! Mutating table
-- CREATE OR REPLACE TRIGGER DeleteEmptyTeam
-- AFTER DELETE ON EmployeeTB
-- FOR EACH ROW
-- DECLARE
--     v_team TeamTY;
--     v_numEmployees NUMBER;
-- BEGIN
--     SELECT DEREF(:OLD.team) INTO v_team FROM DUAL;
--     SELECT COUNT(*) INTO v_numEmployees
--     FROM EmployeeTB
--     WHERE team = :OLD.team;

--     IF v_numEmployees = 0 THEN
--         DELETE FROM TeamTB
--         WHERE ID = v_team.ID;
--     END IF;
-- END;
/

CREATE OR REPLACE TRIGGER CheckTeamBeforeCompletionDate
BEFORE INSERT OR UPDATE OF completionDate ON OrderTB
FOR EACH ROW
BEGIN
    IF :NEW.team IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Team must be assigned before completion date');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER CheckIfCompletedBeforeFeedback
BEFORE INSERT OR UPDATE OF feedback ON OrderTB
FOR EACH ROW
BEGIN
    IF :NEW.completionDate IS NULL AND :NEW.feedback IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Feedback cannot be given without completion date');
    END IF;
END;
/

-- TODO: FIX
CREATE OR REPLACE TRIGGER ComputePerformanceScoreAfterFeedbackInsert
AFTER INSERT OR UPDATE OF feedback ON OrderTB
FOR EACH ROW
DECLARE
    v_team TeamTY;
BEGIN
    IF :NEW.team IS NOT NULL AND :NEW.feedback IS NOT NULL THEN
        SELECT DEREF(:NEW.team) INTO v_team FROM DUAL;
        IF INSERTING THEN
            UPDATE TeamTB t
            SET t.performanceScore = ((t.performanceScore * t.numOrder) + :NEW.feedback.score) / (t.numOrder + 1)
            WHERE ID = v_team.ID;
        END IF;

        IF UPDATING THEN
            UPDATE TeamTB t
            SET t.performanceScore = ((t.performanceScore * t.numOrder) - :OLD.feedback.score + :NEW.feedback.score) / t.numOrder
            WHERE ID = v_team.ID;
        END IF;
    END IF;
END;
/

-- TODO: aggiustare
-- CREATE OR REPLACE TRIGGER AddAccount
-- AFTER INSERT ON CustomerTB
-- FOR EACH ROW
-- DECLARE
--     x Ref CustomerTY;
-- BEGIN
--     DBMS_OUTPUT.PUT_LINE(:NEW.VAT);
--     SELECT MAKE_REF(CustomerTB, :NEW.VAT) INTO x FROM DUAL;
--     INSERT INTO BusinessAccountTB VALUES (BusinessAccountTY(
--         'B' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(100000000, 999999999)), 'FM000000000'),
--         SYSDATE,
--         x
--     ));  
-- END;
-- /

-- TODO: aggiustare
-- CREATE OR REPLACE TRIGGER ClearEmployeeAfterTeamUpdate
-- BEFORE UPDATE OF team ON OrderTB
-- FOR EACH ROW
-- BEGIN
--     IF :NEW.team IS NOT NULL THEN
--         UPDATE OrderTB
--         SET employees = NULL
--         WHERE ID = :NEW.ID;
--     END IF;
-- END;
-- /

CREATE OR REPLACE TRIGGER CheckOperationalCenterBeforeDelete
BEFORE DELETE ON OperationalCenterTB
FOR EACH ROW
DECLARE
    v_numTeams NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_numTeams
    FROM TeamTB t
    WHERE DEREF(t.operationalCenter).name = :OLD.name;

    IF v_numTeams > 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Operational center has teams');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER CheckTeamBeforeDelete
BEFORE DELETE ON TeamTB
FOR EACH ROW
DECLARE
    v_numEmployee NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_numEmployee
    FROM EmployeeTB e
    WHERE DEREF(e.team).ID = :OLD.ID;

    IF v_numEmployee > 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Team has employees');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER CheckBusinessAccountBeforeDelete
BEFORE DELETE ON BusinessAccountTB
FOR EACH ROW
DECLARE
    x NUMBER;
BEGIN
    -- Check if dummy business account exists
    IF :OLD.CODE = 'B000000000' THEN
        RAISE_APPLICATION_ERROR(-20013, 'Cannot delete dummy business account');
    END IF;

    -- Check if dummy business account is in the business account table
    SELECT COUNT(*) INTO x FROM BusinessAccountTB WHERE CODE = 'B000000000';
    IF x = 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'Dummy business account not found');
    END IF;

    -- For every linked order, place a dummy business account
    UPDATE OrderTB O 
    SET businessAccount = (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B000000000')
    WHERE O.businessAccount = MAKE_REF(BusinessAccountTB, :OLD.CODE);
END;
/

CREATE OR REPLACE TRIGGER CheckCustomerBeforeDelete
BEFORE DELETE ON CustomerTB
FOR EACH ROW
DECLARE
    v_numBusinessAccounts NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_numBusinessAccounts
    FROM BusinessAccountTB ba
    WHERE DEREF(ba.customer).VAT = :OLD.VAT;

    IF v_numBusinessAccounts > 0 THEN
        RAISE_APPLICATION_ERROR(-20015, 'Customer has business accounts');
    END IF;
END;
/

-- CREATE OR REPLACE TRIGGER CheckEmployeeBeforeDelete
-- BEFORE DELETE ON EmployeeTB
-- FOR EACH ROW
-- DECLARE
--     v_old_emp REF EmployeeTY;
-- BEGIN
--     SELECT REF(e) INTO v_old_emp
--     FROM EmployeeTB e
--     WHERE e.ID = :OLD.ID;

--     UPDATE OrderTB O
--     SET employees = (
--         SELECT EmployeeVA(emp_ref.column_value)
--         FROM TABLE(O.employees) emp_ref
--         WHERE emp_ref.column_value != v_old_emp
--     )
--     WHERE v_old_emp IN (
--         SELECT column_value
--         FROM TABLE(O.employees)
--     );
-- END;
-- /
CREATE OR REPLACE TRIGGER CheckOrderInsertOrUpdate
BEFORE INSERT OR UPDATE ON OrderTB
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    -- * FUNZIONA
    IF :NEW.completionDate IS NOT NULL AND :NEW.placingDate IS NOT NULL AND
       :NEW.completionDate < :NEW.placingDate THEN
        RAISE_APPLICATION_ERROR(-20000, 'Completion date cannot be before order date');
    END IF;

    -- * FUNZIONA 
    IF :NEW.completionDate IS NULL THEN
        IF :NEW.feedback IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Feedback cannot be given without completion date');
        END IF;
    END IF;

    -- ! Posso mettere 5.4, viene salvato come 5 quindi non parte
    IF :NEW.feedback IS NOT NULL AND :NEW.feedback.score IS NOT NULL AND 
       (:NEW.feedback.score < 1 OR :NEW.feedback.score > 5) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Feedback score must be between 1 and 5');
    END IF;

    -- * FUNZIONA
    IF INSERTING THEN
        IF :NEW.team IS NULL AND :NEW.completionDate IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20010, 'Team must be assigned before completion date');
        END IF;
    END IF;

    -- * FUNZIONA
    IF UPDATING THEN
        IF :OLD.completionDate IS NOT NULL AND 
           ((:OLD.team IS NULL AND :NEW.team IS NOT NULL) OR
            (:OLD.team IS NOT NULL AND :NEW.team IS NULL) OR
            (:OLD.team IS NOT NULL AND :NEW.team IS NOT NULL AND :NEW.team <> :OLD.team)) THEN
            RAISE_APPLICATION_ERROR(-20011, 'Team cannot be changed after order completion');
        END IF;
    END IF;

    -- * FUNZIONA
    IF :NEW.employees IS NOT NULL AND :NEW.employees.COUNT > 0 AND :NEW.team IS NOT NULL THEN
        SELECT COUNT(*) INTO cnt FROM TABLE(:NEW.employees) emp_ref
        JOIN EmployeeTB e ON (emp_ref.column_value = REF(e))
        WHERE e.team <> :NEW.team;

        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Employee of a different team in the same order detected');
        END IF;
    END IF;

    -- TODO: no update of varray employee if order is completed
    -- IF :NEW.employees IS NOT NULL AND :NEW.employees.COUNT > 0 THEN
    --     IF :OLD.completionDate IS NOT NULL THEN
    --         RAISE_APPLICATION_ERROR(-20008, 'Employees cannot be changed after order completion');
    --     END IF;
    -- END IF;
    
    -- * FUNZIONA
    IF :NEW.team IS NULL AND :NEW.employees IS NOT NULL AND :NEW.employees.COUNT > 0 THEN
        SELECT e.team INTO :NEW.team
        FROM TABLE(:NEW.employees) emp_ref
        JOIN EmployeeTB e ON (emp_ref.column_value = REF(e))
        FETCH FIRST 1 ROW ONLY;
    END IF;

    -- * FUNZIONA
    IF :NEW.completionDate IS NULL AND :NEW.feedback IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Feedback must be given after completion date');
    END IF;
END;
/

-- * FUNZIONA
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

-- * FUNZIONA
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

-- * FUNZIONA
CREATE OR REPLACE TRIGGER UpdateNumOrdersAfterDelete
AFTER DELETE ON OrderTB
FOR EACH ROW
DECLARE
    v_team TeamTY;
BEGIN
    IF :NEW.team IS NOT NULL THEN
        SELECT DEREF(:OLD.team) INTO v_team FROM DUAL;
        UPDATE TeamTB
        SET numOrder = numOrder - 1
        WHERE ID = v_team.ID;
    END IF;
END;
/

-- * FUNZIONA
CREATE OR REPLACE TRIGGER UpdateNumOrdersAfterUpdate
AFTER UPDATE OF team ON OrderTB
FOR EACH ROW
DECLARE
    v_old_team TeamTY;
    v_new_team TeamTY;
BEGIN
    IF :OLD.team IS NULL AND :NEW.team IS NOT NULL THEN
        -- New team assigned
        SELECT DEREF(:NEW.team) INTO v_new_team FROM DUAL;
        UPDATE TeamTB
        SET numOrder = numOrder + 1
        WHERE ID = v_new_team.ID;
    ELSIF :OLD.team IS NOT NULL AND :NEW.team IS NOT NULL THEN
        -- Team changed
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
    ELSIF :OLD.team IS NOT NULL AND :NEW.team IS NULL THEN
        -- Team removed
        SELECT DEREF(:OLD.team) INTO v_old_team FROM DUAL;
        UPDATE TeamTB
        SET numOrder = numOrder - 1
        WHERE ID = v_old_team.ID;
    END IF;
END;
/

-- * FUNZIONA
CREATE OR REPLACE TRIGGER TeamInsertInitialization
BEFORE INSERT ON TeamTB
FOR EACH ROW
BEGIN
    :NEW.numOrder := 0;
    :NEW.performanceScore := 1;
END;
/

-- TODO: cambiarlo un po'
create or replace trigger check_team_num
for insert or update of team on EmployeeTB
compound trigger
    team_count number;
    team_ref REF TeamTY;
BEFORE EACH ROW IS
BEGIN
    team_ref := :New.team;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
    select count (*) into team_count from EmployeeTB e where e.team = team_ref;
    if (team_count > 8) then
         RAISE_APPLICATION_ERROR(-20001, 'Max number of employee reached');
    end if;
end after statement;
end;
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

        -- ! ROTTO ROTTISSIMO
        IF UPDATING THEN
            IF :OLD.feedback.score IS NULL THEN
                UPDATE TeamTB t
                SET t.performanceScore = ((t.performanceScore * t.numOrder) + :NEW.feedback.score) / (t.numOrder + 1)
                WHERE ID = v_team.ID;
            ELSE
                UPDATE TeamTB t
                SET t.performanceScore = ((t.performanceScore * t.numOrder) - :OLD.feedback.score + :NEW.feedback.score) / t.numOrder
                WHERE ID = v_team.ID;
            END IF;
        END IF;
    END IF;
END;
/

-- * FUNZIONA
create or replace trigger AddAccount
for insert on CustomerTB
compound trigger
    customer VARCHAR2(11);
BEFORE EACH ROW IS
BEGIN
    customer := :NEW.VAT;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
    insert into BusinessAccountTB values (
        'B' || TO_CHAR(DBMS_RANDOM.value(100000000, 999999999), 'FM000000000'),
        sysdate, 
        (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = customer)
    );
end after statement;
end;
/

-- ! Mutating
-- CREATE OR REPLACE TRIGGER CheckOperationalCenterBeforeDelete
-- FOR DELETE ON OperationalCenterTB
-- COMPOUND TRIGGER
--     v_center VARCHAR2(50);
-- BEFORE EACH ROW IS
-- BEGIN
--     v_center := :OLD.name;
-- END BEFORE EACH ROW;

-- AFTER STATEMENT IS
--     cnt NUMBER;
-- BEGIN
--     SELECT COUNT(*) INTO cnt 
--     FROM TeamTB t 
--     WHERE DEREF(t.operationalCenter).name = v_center;
    
--     IF cnt > 0 THEN
--         RAISE_APPLICATION_ERROR(-20009, 'Cannot delete operational center with active teams');
--     END IF;
-- END AFTER STATEMENT;
-- END;
-- /

-- ! Mutating
-- CREATE OR REPLACE TRIGGER CheckTeamBeforeDelete
-- for DELETE ON TeamTB
-- compound TRIGGER
--     v_team VARCHAR2(50);
--     cnt NUMBER;
-- BEFORE EACH ROW IS 
-- BEGIN
--     v_team := :OLD.ID;
-- END BEFORE EACH ROW;

-- AFTER STATEMENT IS
-- BEGIN
--     SELECT COUNT(*) INTO cnt 
--     FROM EmployeeTB e
--     WHERE e.team = (SELECT REF(t) FROM TeamTB t WHERE t.ID = v_team);
--     dbms_output.put_line('Old team: ' || v_team || ' Count: ' || cnt);
--     IF cnt > 0 THEN
--         RAISE_APPLICATION_ERROR(-20012, 'Cannot delete team with employees');
--     END IF;
-- END AFTER STATEMENT;
-- END;

-- CREATE OR REPLACE TRIGGER CheckTeamBeforeDelete
-- for DELETE ON TeamTB
-- compound TRIGGER
--     v_team VARCHAR2(50);
--     cnt NUMBER;
--     ref_team REF TeamTY;
-- BEFORE EACH ROW IS 
-- BEGIN
--     v_team := :OLD.ID;
-- END BEFORE EACH ROW;

-- AFTER STATEMENT IS
-- BEGIN
--     SELECT COUNT(*) INTO cnt 
--     FROM TeamTB t, EmployeeTB e 
--     WHERE t.ID = v_team 
--     AND REF(t) = e.team;

--     IF cnt > 0 THEN
--         RAISE_APPLICATION_ERROR(-20012, 'Cannot delete team with employees');
--     END IF;
-- END AFTER STATEMENT;
-- END;

--     -- For every linked order, deref the team
--     UPDATE OrderTB O
--     SET team = NULL
--     WHERE O.team = MAKE_REF(TeamTB, :OLD.ID);
-- END;
/

-- ? ELIMINO UN BUSINESS ACCOUNT == DUMMY BUSINESS SUGLI ORDINI
-- ! Mutating
-- CREATE OR REPLACE TRIGGER CheckBusinessAccountBeforeDelete
-- for DELETE ON BusinessAccountTB
-- compound TRIGGER
-- DECLARE
--     v_ba VARCHAR2(10);
--     x NUMBER;
-- BEFORE EACH ROW IS
-- BEGIN
--     v_oc := :OLD.CODE;
-- END BEFORE EACH ROW;

-- AFTER STATEMENT IS
--     -- Check if dummy business account exists
--     IF :OLD.CODE = 'B000000000' THEN
--         RAISE_APPLICATION_ERROR(-20013, 'Cannot delete dummy business account');
--     END IF;

--     -- Check if dummy business account is in the business account table
--     SELECT COUNT(*) INTO x FROM BusinessAccountTB WHERE CODE = 'B000000000';
--     IF x = 0 THEN
--         RAISE_APPLICATION_ERROR(-20014, 'Dummy business account not found');
--     END IF;

--     -- For every linked order, place a dummy business account
--     -- TODO: CONTROLLARE
--     UPDATE OrderTB O 
--     SET businessAccount = (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B000000000')
--     WHERE O.businessAccount = MAKE_REF(BusinessAccountTB, :OLD.CODE);
-- END AFTER STATEMENT;
-- END;
/

-- ! Mutating
-- CREATE OR REPLACE TRIGGER CheckCustomerBeforeDelete
-- BEFORE DELETE ON CustomerTB
-- FOR EACH ROW
-- DECLARE
--     v_numBusinessAccounts NUMBER;
-- BEGIN
--     SELECT COUNT(*) INTO v_numBusinessAccounts
--     FROM BusinessAccountTB ba
--     WHERE DEREF(ba.customer).VAT = :OLD.VAT;

--     IF v_numBusinessAccounts > 0 THEN
--         RAISE_APPLICATION_ERROR(-20015, 'Customer has business accounts');
--     END IF;
-- END;
-- /

-- ? ELIMINO UN EMPLOYEE == DEREF SU ORDERTB
-- TODO: TESTARE
-- CREATE OR REPLACE TRIGGER CheckEmployeeBeforeDelete
-- BEFORE DELETE ON EmployeeTB
-- FOR EACH ROW
-- DECLARE
--     v_old_emp REF EmployeeTY;
-- BEGIN
--     SELECT REF(e) INTO v_old_emp
--     FROM EmployeeTB e
--     WHERE e.FC = :OLD.FC;

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

-- * FUNZIONA
CREATE OR REPLACE TRIGGER DummyBusinessAccountCheck
BEFORE UPDATE OR DELETE ON BusinessAccountTB
FOR EACH ROW
BEGIN
    IF :OLD.CODE = 'B000000000' THEN
        RAISE_APPLICATION_ERROR(-20016, 'Cannot modify dummy business account');
    END IF;
END;
/

-- * FUNZIONA
CREATE OR REPLACE TRIGGER DummyCustomerAccountCheck
BEFORE UPDATE OR DELETE ON CustomerTB
FOR EACH ROW
BEGIN
    IF :OLD.VAT = '00000000000' THEN
        RAISE_APPLICATION_ERROR(-20017, 'Cannot modify dummy customer account');
    END IF;
END;
/

-- ! Testare meglio, l'else parte
-- CREATE OR REPLACE TRIGGER CheckOrderDeletion
-- BEFORE DELETE ON OrderTB
-- FOR EACH ROW
-- DECLARE
--     v_team TeamTY;
--     v_businessAccount BusinessAccountTY;
-- BEGIN
--     -- take the id of businessa ccount on old table
--     select DEREF(:OLD.businessAccount) INTO v_businessAccount FROM DUAL;

--     -- Case 1: Order has no team, dummy business account, and no employees
--     IF :OLD.team IS NULL AND 
--        v_businessAccount.CODE = 'B000000000' AND 
--        :OLD.employees IS NULL THEN
--         null; -- Do nothing, the delete can proceed

--     -- Case 2: Order is completed, has no feedback, no team, no employees and dummy business account  
--     ELSIF :OLD.completionDate IS NOT NULL AND
--           :OLD.feedback IS NULL AND
--           :OLD.team IS NULL AND 
--           :OLD.employees IS NULL AND
--           v_businessAccount.CODE = 'B000000000' THEN
--         null;
--         --DELETE FROM OrderTB WHERE ID = :OLD.ID;

--     -- All other cases - deletion not allowed
--     ELSE
--         RAISE_APPLICATION_ERROR(-20018, 'Cannot delete order. Order must have no team, no employees and use dummy business account');
--     END IF;
-- END;
-- /
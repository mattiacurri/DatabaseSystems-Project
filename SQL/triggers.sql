CONNECT brightway_admin/BRIGHTWAY_ADMIN;

CREATE OR REPLACE TRIGGER CheckOrderInsertOrUpdate
BEFORE INSERT OR UPDATE ON OrderTB
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    -- * FUNZIONA 
    IF :NEW.completionDate IS NULL THEN
        IF :NEW.feedback IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Feedback cannot be given without completion date');
        END IF;
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

    -- * FUNZIONA
    IF UPDATING THEN
        IF :OLD.completionDATE IS NOT NULL THEN
            IF :NEW.employees IS NOT NULL OR (:OLD.employees IS NOT NULL AND :NEW.employees IS NULL) THEN
                RAISE_APPLICATION_ERROR(-20008, 'Cannot update employees of a completed order');
            END IF;
        END IF;
    END IF;

    -- * FUNZIONA
    IF :NEW.team IS NULL AND :NEW.employees IS NOT NULL AND :NEW.employees.COUNT > 0 THEN
        SELECT e.team INTO :NEW.team
        FROM TABLE(:NEW.employees) emp_ref
        JOIN EmployeeTB e ON (emp_ref.column_value = REF(e))
        FETCH FIRST 1 ROW ONLY;
    END IF;
END;
/

-- -- * FUNZIONA
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

CREATE OR REPLACE TRIGGER UpdateNumOrders
AFTER INSERT OR UPDATE OR DELETE ON OrderTB
FOR EACH ROW
DECLARE
    v_old_team TeamTY;
    v_new_team TeamTY;
BEGIN
    IF INSERTING THEN
        IF :NEW.team IS NOT NULL THEN
            SELECT DEREF(:NEW.team) INTO v_new_team FROM DUAL;
            UPDATE TeamTB
            SET numOrder = numOrder + 1
            WHERE ID = v_new_team.ID;
        END IF;
    ELSIF DELETING THEN
        IF :OLD.team IS NOT NULL THEN
            SELECT DEREF(:OLD.team) INTO v_old_team FROM DUAL;
            UPDATE TeamTB
            SET numOrder = numOrder - 1
            WHERE ID = v_old_team.ID;
        END IF;
    ELSIF UPDATING AND :OLD.team != :NEW.team THEN
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
            
            UPDATE TeamTB
            SET numOrder = numOrder - 1
            WHERE ID = v_old_team.ID;

            UPDATE TeamTB
            SET numOrder = numOrder + 1
            WHERE ID = v_new_team.ID;
        ELSIF :OLD.team IS NOT NULL AND :NEW.team IS NULL THEN
            -- Team removed
            SELECT DEREF(:OLD.team) INTO v_old_team FROM DUAL;
            UPDATE TeamTB
            SET numOrder = numOrder - 1
            WHERE ID = v_old_team.ID;
        END IF;
    END IF;
END;
/

-- * FUNZIONA
CREATE OR REPLACE TRIGGER CheckTeamInsertInitialization
BEFORE INSERT ON TeamTB
FOR EACH ROW
BEGIN
    :NEW.numOrder := 0;
    :NEW.performanceScore := 1;
END;
/

-- * FUNZIONA
create or replace trigger CheckNumEmployeeInTeam
for insert or update of team on EmployeeTB
compound trigger
    cnt number;
    teamRef REF TeamTY;
BEFORE EACH ROW IS
BEGIN
    teamRef := :New.team;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
    select count (*) into cnt from EmployeeTB e where e.team = teamRef;
    if (cnt > 8) then
         RAISE_APPLICATION_ERROR(-20001, 'Max number of employee reached');
    end if;
end after statement;
end;
/

-- * FUNZIONA
CREATE OR REPLACE TRIGGER ComputePerformanceScore
AFTER INSERT OR UPDATE ON OrderTB
BEGIN
    -- Update performance scores for all teams that have orders with feedback
    UPDATE TeamTB t
    SET t.performanceScore = (
        SELECT ROUND(AVG(o.feedback.score), 2)
        FROM OrderTB o
        WHERE o.team = REF(t)
        AND o.feedback IS NOT NULL
    )
    WHERE EXISTS (
        SELECT 1
        FROM OrderTB o
        WHERE o.team = REF(t)
        AND o.feedback IS NOT NULL
    );
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

CREATE OR REPLACE TRIGGER DeleteTeamAfterOperationalCenter
AFTER DELETE ON OperationalCenterTB

BEGIN
    DELETE FROM TeamTB t
    WHERE DEREF(t.operationalCenter) IS NULL AND t.operationalCenter IS NOT NULL;
END;
/

CREATE OR REPLACE TRIGGER UpdateEmployeeAfterTeam
AFTER DELETE ON TeamTB

BEGIN
    UPDATE EmployeeTB e
    SET e.team = NULL
    WHERE DEREF(e.team) IS NULL AND e.team IS NOT NULL;

    UPDATE OrderTB o
    SET o.team = NULL
    WHERE DEREF(o.team) IS NULL AND o.team IS NOT NULL AND o.completionDate IS NULL;
END;
/

CREATE OR REPLACE TRIGGER DeleteAccountAfterCustomer
AFTER DELETE ON CustomerTB
BEGIN
    DELETE FROM BusinessAccountTB ba
    WHERE DEREF(ba.customer) IS NULL AND ba.customer IS NOT NULL;
END;
/

CREATE OR REPLACE TRIGGER DeleteOrdersAfterTeam
AFTER DELETE ON TeamTB
BEGIN
    -- delete order that have lost the references of the team and don't have a business account associated
    DELETE FROM OrderTB o
    WHERE DEREF(o.team) IS NULL AND o.team IS NOT NULL AND DEREF(o.businessAccount) IS NULL AND o.businessAccount IS NOT NULL;
END;
/

CREATE OR REPLACE TRIGGER DeleteOrdersAfterAccount
AFTER DELETE ON BusinessAccountTB
BEGIN
    DELETE FROM OrderTB o
    WHERE DEREF(o.businessAccount) IS NULL AND o.businessAccount IS NOT NULL AND o.feedback.score IS NULL;

    DELETE FROM OrderTB o
    WHERE DEREF(o.businessAccount) IS NULL AND o.businessAccount IS NOT NULL AND (o.team IS NOT NULL AND DEREF(o.team) IS NULL);
END;
/

CREATE OR REPLACE TRIGGER PreventOrderDeletion
BEFORE DELETE ON OrderTB
FOR EACH ROW
DECLARE
    v_team TeamTY;
    v_account BusinessAccountTY;
BEGIN
    -- Allow deletion only if either:
    -- 1. Order has lost team reference and business account reference
    -- 2. Order has lost business account reference and is not completed
    IF :OLD.team IS NOT NULL THEN
        SELECT DEREF(:OLD.team) INTO v_team FROM DUAL;
    END IF;
    IF :OLD.businessAccount IS NOT NULL THEN
        SELECT DEREF(:OLD.businessAccount) INTO v_account FROM DUAL;
    END IF;

    IF NOT (
        (:OLD.team IS NOT NULL AND v_team IS NULL AND 
         :OLD.businessAccount IS NOT NULL AND v_account IS NULL)
        OR
        (:OLD.businessAccount IS NOT NULL AND v_account IS NULL AND 
         :OLD.completionDate IS NULL)
    ) THEN
        RAISE_APPLICATION_ERROR(-20019, 'Order deletion not allowed in this case');
    END IF;
END;
/

-- Trigger that if team is updated in order, empty the employee list
CREATE OR REPLACE TRIGGER EmptyEmployeeListAfterTeamUpdate
BEFORE UPDATE OF team ON OrderTB
FOR EACH ROW
BEGIN
    IF :OLD.team IS NOT NULL AND :NEW.team IS NOT NULL AND :OLD.team != :NEW.team THEN
        :NEW.employees := NULL;
    END IF;
END;
/
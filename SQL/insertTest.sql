-- ? Prove Varie
INSERT INTO OperationalCenterTB VALUES ('OC1', AddressTY('Via Roma', 1, 'Roma', 'RM', 'Lazio', 'Italia'));
/
INSERT INTO TeamTB VALUES ('T123456', 'Team1', 0, 2, (SELECT REF(oc) FROM OperationalCenterTB oc WHERE oc.name = 'OC1'));
/
INSERT INTO TeamTB VALUES ('T123400', 'Team2', 99, 1, (SELECT REF(oc) FROM OperationalCenterTB oc WHERE oc.name = 'OC1'));
/
INSERT INTO EmployeeTB VALUES ('ABCDEFGHJKLMNOPQ', 'Mario', 'Rossi', TO_DATE('1990-01-01', 'YYYY-MM-DD'), '1234567890', 'A@A.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/
INSERT INTO EmployeeTB VALUES ('1BCDEFGHJKLMNOPQ', 'Luigi', 'Verdi', TO_DATE('1985-02-02', 'YYYY-MM-DD'), '2345678901', 'B@B.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/
INSERT INTO EmployeeTB VALUES ('2BCDEFGHJKLMNOPQ', 'Giovanni', 'Bianchi', TO_DATE('1980-03-03', 'YYYY-MM-DD'), '3456789012', 'C@C.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/
INSERT INTO EmployeeTB VALUES ('3BCDEFGHJKLMNOPQ', 'Paolo', 'Neri', TO_DATE('1975-04-04', 'YYYY-MM-DD'), '4567890123', 'D@D.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/
INSERT INTO EmployeeTB VALUES ('4BCDEFGHJKLMNOPQ', 'Francesco', 'Rossi', TO_DATE('1995-05-05', 'YYYY-MM-DD'), '5678901234', 'E@E.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/
INSERT INTO EmployeeTB VALUES ('5BCDEFGHJKLMNOPQ', 'Marco', 'Gialli', TO_DATE('1992-06-06', 'YYYY-MM-DD'), '6789012345', 'F@F.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/

INSERT INTO EmployeeTB VALUES ('6BCDEFGHJKLMNOPQ', 'Antonio', 'Blu', TO_DATE('1988-07-07', 'YYYY-MM-DD'), '7890123456', 'G@G.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/
INSERT INTO EmployeeTB VALUES ('6xxDEFGHJKLMNOPQ', 'Antonio', 'Bluino', TO_DATE('1988-07-07', 'YYYY-MM-DD'), '7890123456', 'G@G.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/
INSERT INTO EmployeeTB VALUES ('6xyDEFGHJKLMNOPQ', 'Antonio', 'Bluastro', TO_DATE('1988-07-07', 'YYYY-MM-DD'), '7890123456', 'G@G.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123456'));
/
INSERT INTO EmployeeTB VALUES ('7BCDEFGHJKLMNOPQ', 'Roberto', 'Viola', TO_DATE('1991-08-08', 'YYYY-MM-DD'), '8901234567', 'H@H.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123400'));
/
INSERT INTO EmployeeTB VALUES ('8BCDEFGHJKLMNOPQ', 'Luca', 'Marrone', TO_DATE('1993-09-09', 'YYYY-MM-DD'), '9012345678', 'I@I.COM', (SELECT REF(t) FROM TeamTB t WHERE t.ID = 'T123400'));
/
INSERT INTO CustomerTB VALUES ('12345678900', '1234567890', 'ciccio@gmail.com', 'individual', 'Ciccio', 'Pasticcio', TO_DATE('1990-01-01', 'YYYY-MM-DD'), NULL, NULL);
/
INSERT INTO CustomerTB VALUES ('12345678901', '1234567890', 'ciccio@gmail.com', 'individual', 'Ciccio', 'Pasticcio', TO_DATE('1990-01-01', 'YYYY-MM-DD'), NULL, NULL);
/
INSERT INTO CustomerTB VALUES ('12345678904', '1234567890', 'ciccio@gmail.com', 'individual', 'Ciccio', 'Pasticcio', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'Azienda Sbagiata', NULL);
/
INSERT INTO CustomerTB VALUES ('12345678988', '1234567890', 'ciccio@gmail.com', 'business', 'Nostradamus', NULL, NULL, 'Azienda Sbagiata', NULL);
/
INSERT INTO CustomerTB VALUES ('12345678921', '1234567890', 'ciccio@gmail.com', 'business', NULL, NULL, NULL, 'La Locanda', AddressTY('Via Roma', 1, 'Roma', 'RM', 'Lazio', 'Italia'));
/
INSERT INTO CustomerTB VALUES ('12345678902', '1234567890', 'lp@lp.com', 'business', NULL, NULL, NULL, 'La Pizzeria', AddressTY('Via Roma', 2, 'Roma', 'RM', 'Lazio', 'Italia'));
/

INSERT INTO BusinessAccountTB VALUES ('B123456789', TO_DATE('2021-01-01', 'YYYY-MM-DD'), (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = '12345678900'));
/
INSERT INTO BusinessAccountTB VALUES ('B987654321', TO_DATE('2022-01-01', 'YYYY-MM-DD'), (SELECT REF(c) FROM CustomerTB c WHERE c.VAT = '12345678901'));
/
INSERT INTO OrderTB VALUES ('O123456789', TO_DATE('2021-01-01', 'YYYY-MM-DD'), 'online', 'regular', 100, (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B123456789'), NULL, NULL, TO_DATE('2021-01-02', 'YYYY-MM-DD'), NULL);
/

INSERT INTO OrderTB VALUES ('O133456789', TO_DATE('2021-01-01', 'YYYY-MM-DD'), 'online', 'regular', 100, (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B123456789'), NULL, NULL, TO_DATE('2020-01-02', 'YYYY-MM-DD'), NULL);
/

INSERT INTO OrderTB VALUES (
    'O323499900', 
    TO_DATE('2021-01-01', 'YYYY-MM-DD'), 
    'email', 
    'bulk', 
    100, 
    (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
    NULL, 
    NULL, 
    TO_DATE('2022-01-02', 'YYYY-MM-DD'), 
    FeedbackTY(2, 'Bad job :(')
);
/
INSERT INTO OrderTB VALUES (
    'O123556701', 
    TO_DATE('2021-01-01', 'YYYY-MM-DD'), 
    'online', 
    'regular', 
    100, 
    (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
    (SELECT REF(ta) FROM TeamTB ta WHERE ta.ID = 'T123456'), 
    EmployeeVA(
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'ABCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '1BCDEFGHJKLMNOPQ')
    ), 
    TO_DATE('2022-01-02', 'YYYY-MM-DD'), 
    FeedbackTY(5, 'Good job')
);
/
INSERT INTO OrderTB VALUES (
    'O123556701', 
    TO_DATE('2021-01-01', 'YYYY-MM-DD'), 
    'online', 
    'regular', 
    100, 
    (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
    (SELECT REF(ta) FROM TeamTB ta WHERE ta.ID = 'T123400'), 
    EmployeeVA(
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'ABCDEFGHJKLMNOPQ')
    ), 
    TO_DATE('2022-01-02', 'YYYY-MM-DD'), 
    FeedbackTY(5, 'Good job')
);
/
INSERT INTO OrderTB VALUES (
    'O123556722', 
    TO_DATE('2011-01-01', 'YYYY-MM-DD'), 
    'online', 
    'bulk', 
    300, 
    (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
    (SELECT REF(ta) FROM TeamTB ta WHERE ta.ID = 'T123456'), 
    EmployeeVA(
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '2BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'ABCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '1BCDEFGHJKLMNOPQ')
    ), 
    TO_DATE('2023-01-02', 'YYYY-MM-DD'), 
    FeedbackTY(3, 'Nice')
);
/
INSERT INTO OrderTB VALUES (
    'O999456701', 
    TO_DATE('2021-01-01', 'YYYY-MM-DD'), 
    'online', 
    'regular', 
    100, 
    (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
    (SELECT REF(ta) FROM TeamTB ta WHERE ta.ID = 'T123456'), 
    EmployeeVA(
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'ABCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '1BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '2BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '3BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '7BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '4BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '5BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '6BCDEFGHJKLMNOPQ')
    ), 
    TO_DATE('2022-01-02', 'YYYY-MM-DD'), 
    FeedbackTY(5, 'Good job')
);
/
INSERT INTO OrderTB VALUES (
    'O888456712', 
    TO_DATE('2021-01-01', 'YYYY-MM-DD'), 
    'online', 
    'regular', 
    100.8, 
    (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
    (SELECT REF(ta) FROM TeamTB ta WHERE ta.ID = 'T123456'), 
    EmployeeVA(
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'ABCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '1BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '2BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '3BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '4BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '5BCDEFGHJKLMNOPQ'),
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '6BCDEFGHJKLMNOPQ')
    ), 
    TO_DATE('2022-01-02', 'YYYY-MM-DD'), 
    FeedbackTY(1, 'Good job')
);
/

INSERT INTO OrderTB VALUES (
    'O889556612', 
    TO_DATE('2021-01-01', 'YYYY-MM-DD'), 
    'online', 
    'regular', 
    255, 
    (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
    NULL,
    EmployeeVA(
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '7BCDEFGHJKLMNOPQ')
    ), 
    TO_DATE('2022-01-02', 'YYYY-MM-DD'), 
    FeedbackTY(2, 'Good job')
);
/

INSERT INTO OrderTB VALUES (
    'O889456712', 
    TO_DATE('2021-01-01', 'YYYY-MM-DD'), 
    'online', 
    'regular', 
    255, 
    (SELECT REF(ba) FROM BusinessAccountTB ba WHERE ba.CODE = 'B987654321'), 
    (SELECT REF(ta) FROM TeamTB ta WHERE ta.ID = 'T123400'), 
    EmployeeVA(
        (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '7BCDEFGHJKLMNOPQ')
    ), 
    TO_DATE('2022-01-02', 'YYYY-MM-DD'), 
    FeedbackTY(2, 'Good job')
);
/

-- Update O889456712 adding an employee of the team T123456
UPDATE OrderTB SET employees = EmployeeVA(
    (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = 'ABCDEFGHJKLMNOPQ'),
    (SELECT REF(e) FROM EmployeeTB e WHERE e.FC = '7BCDEFGHJKLMNOPQ')
) WHERE ID = 'O889456712';
/

-- -- change assign team of O889456712 from T123400 to T123456
UPDATE OrderTB SET team = (SELECT REF(ta) FROM TeamTB ta WHERE ta.ID = 'T123400') WHERE ID = 'O889456712';
/

SELECT COLUMN_VALUE
FROM OrderTB o, TABLE(o.employees)
WHERE ID = 'O888456712';
SELECT deref(COLUMN_VALUE)
FROM OrderTB o, TABLE(o.employees)
WHERE ID = 'O888456712';

-- DELETE 5BCDEFGHJKLMNOPQ
DELETE FROM EmployeeTB WHERE FC = '5BCDEFGHJKLMNOPQ';
/

-- SELECT FC, deref(team) as TEAM From EmployeeTB;
-- SELECT * FROM OperationalCenterTB;
-- SELECT * FROM CustomerTB;
-- SELECT CODE, creationDate, deref(customer) FROM BusinessAccountTB BA where BA.Customer.VAT = '12345678900';
-- SELECT 
--     ID, 
--     DEREF(team).ID AS team,
--     feedback
-- FROM OrderTB;
-- /
-- SELECT * FROM TeamTB;
-- /
SELECT COLUMN_VALUE
FROM OrderTB o, TABLE(o.employees)
WHERE ID = 'O888456712';
SELECT deref(COLUMN_VALUE)
FROM OrderTB o, TABLE(o.employees)
WHERE ID = 'O888456712';
/
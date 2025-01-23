-- SELECT * FROM CustomerTB;
-- SELECT CODE, deref(customer) FROM BusinessAccountTB;

-- SELECT ID FROM OrderTB;

-- SELECT * FROM TeamTB;

INSERT INTO OrderTB VALUES (
    OrderTY('O123456789', SYSDATE, 'online', 'regular', 100.00, 
    (SELECT REF(b) FROM BusinessAccountTB b WHERE ROWNUM = 1), 
    NULL, NULL, NULL, NULL)
);

INSERT INTO OrderTB VALUES (
    OrderTY('O123456790', SYSDATE, 'phone', 'urgent', 200.00,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE ROWNUM = 1), 
    NULL, NULL, NULL, NULL)
);

INSERT INTO OrderTB VALUES (
    OrderTY('O123456791', SYSDATE, 'email', 'bulk', 300.00,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE ROWNUM = 1), 
    NULL, NULL, NULL, NULL)
);

INSERT INTO OrderTB VALUES (
    OrderTY('O123456792', SYSDATE, 'online', 'regular', 150.00,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE ROWNUM = 1), 
    NULL, NULL, NULL, NULL)
);

INSERT INTO OrderTB VALUES (
    OrderTY('O123456793', SYSDATE, 'phone', 'urgent', 250.00,
    (SELECT REF(b) FROM BusinessAccountTB b WHERE ROWNUM = 1), 
    NULL, NULL, NULL, NULL)
);
/

SELECT ID, deref(team) FROM OrderTB WHERE ID IN ('O123456789', 'O123456790', 'O123456791', 'O123456792', 'O123456793');

commit work;
/
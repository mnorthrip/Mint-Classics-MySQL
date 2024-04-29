-- Product missing sales data.
SELECT p.warehouseCode, p.productCode, p.productName, p.productLine, quantityOrdered, p.quantityInStock
  FROM orderdetails o
 RIGHT JOIN products p
    ON o.productCode = p.productCode
 WHERE p.productCode = 'S18_3233' 
-- Product missing sales data.
SELECT warehouseCode, p.productCode, productName, productLine, quantityOrdered, quantityInStock
  FROM orderdetails o
 RIGHT JOIN products p
    ON o.productCode = p.productCode
 WHERE p.productCode = 'S18_3233' 

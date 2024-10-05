-- Query 1
-- Product orders and inventory.
SELECT warehouseCode, p.productCode, productName, productLine, SUM(quantityOrdered) AS totalOrders,
       ROUND((SUM(quantityOrdered) / (2 + (5/12))), 2) AS oneYearOrders, quantityInStock AS currentInventory, 
       ROUND(quantityInStock / (SUM(quantityOrdered) / (2 + (5/12))), 2) AS yearsInventoryLeft
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
 GROUP BY 1, 2
 ORDER BY 1, 4, 8 DESC;  
   
-- Query 2
-- Product line inventory. 
SELECT sub.warehouseCode, warehouseName, productLine,
       COUNT(CASE WHEN yearsInventoryLeft < 1 THEN 1 ELSE NULL END) AS 'inventory <1 yr',
       COUNT(CASE WHEN yearsInventoryLeft >= 1 AND yearsInventoryLeft < 5 THEN 1 ELSE NULL END) AS 'inventory <5 yr',
       COUNT(CASE WHEN yearsInventoryLeft >= 5 AND yearsInventoryLeft < 10 THEN 1 ELSE NULL END) AS 'inventory <10 yr',
       COUNT(CASE WHEN yearsInventoryLeft >= 10 THEN 1 ELSE NULL END) AS 'inventory >10 yr',
       ROUND(COUNT(CASE WHEN yearsInventoryLeft >= 10  THEN 1 ELSE NULL END) / COUNT(1), 2) 
       AS 'pctInventory >10 yr'
  FROM (SELECT warehouseCode, p.productCode, productName, productLine, SUM(quantityOrdered) AS totalOrders,
	       ROUND((SUM(quantityOrdered) / (2 + (5/12))), 2) AS oneYearOrders, quantityInStock AS currentInventory, 
	       ROUND(quantityInStock / (SUM(quantityOrdered) / (2 + (5/12))), 2) AS yearsInventoryLeft
	  FROM products p
	  JOIN orderdetails od
	    ON p.productCode = od.productCode
	 GROUP BY 1, 2
	 ORDER BY 1, 4, 8 DESC
       ) sub
  JOIN warehouses w
    ON sub.warehouseCode = w.warehouseCode
 GROUP BY 1, 3;

-- Query 3
-- Warehouse orders and inventory.
SELECT pr.warehouseCode, warehouseName, COUNT(pr.productCode) AS products, orders AS totalOrders, 
       ROUND((orders / (2 + (5/12))), 2) AS oneYearOrders, ROUND((orders / (2 + (5/12))) * 5, 2) AS fiveYearsOrders, 
       ROUND((orders / (2 + (5/12))) * 10, 2) AS tenYearsOrders, SUM(quantityInStock) AS currentInventory, 
       ROUND(SUM(quantityInStock) / (orders / (2 + (5/12))), 2) AS yearsInventoryLeft, 
       ROUND(SUM(pr.quantityInStock) / (warehousePctCap / 100), 0) AS warehouseCap
  FROM products pr
  JOIN (SELECT p.warehouseCode, SUM(quantityordered) AS orders
	  FROM orderdetails od
	  JOIN products p
	    ON od.productcode = p.productcode
	 GROUP BY p.warehouseCode
	 ORDER BY 1
       ) od
    ON od.warehouseCode = pr.warehouseCode
  JOIN warehouses w
    ON pr.warehouseCode = w.warehouseCode
 GROUP BY 1, 4
 ORDER BY 1;

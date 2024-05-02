/* Inventory Reorganization. */

-- Query 1
-- Warehouse capacity.
SELECT p.warehouseCode, warehouseName, COUNT(productCode) AS products, 
       SUM(quantityInStock) AS currentInventory, warehousePctCap,
       ROUND(SUM(quantityInStock) / (warehousePctCap / 100), 0) AS warehouseCap
  FROM products p
  JOIN warehouses w
    ON p.warehouseCode = w.warehouseCode
 GROUP BY 1;

-- Query 2
-- Warehouse product lines.
SELECT p.warehouseCode, warehouseName, COUNT(productCode) AS products, productLine, 
       SUM(quantityInStock) AS currentInventory, warehousePctCap, warehouseCap
  FROM products p
  JOIN warehouses w
    ON p.warehouseCode = w.warehouseCode
  JOIN (SELECT pr.warehouseCode, 
	       ROUND(SUM(quantityInStock) / (warehousePctCap / 100), 0) AS warehouseCap
	  FROM products pr
	  JOIN warehouses wa
	    ON pr.warehouseCode = wa.warehouseCode
	 GROUP BY 1
       ) sub
    ON p.warehouseCode = sub.warehouseCode
 GROUP BY 1, 4;
 
/* Inventory Reduction. */

-- Query 3
-- Product orders and inventory.
SELECT warehouseCode, p.productCode, productName, productLine, SUM(quantityOrdered) AS totalOrders,
       ROUND((SUM(quantityOrdered) / (2 + (5/12))), 2) AS oneYearOrders, quantityInStock AS currentInventory, 
       ROUND(quantityInStock / (SUM(quantityOrdered) / (2 + (5/12))), 2) AS yearsInventoryLeft,
       CASE WHEN (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) <= 1 THEN 'Restock'
	    WHEN (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) > 1 
		 AND (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) <= 5 THEN 'Stocked'
            WHEN (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) > 5 
		 AND (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) <= 10 THEN 'Overstocked'
            ELSE 'Severely Overstocked' END AS inventoryStatus
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
 GROUP BY 1, 2
 ORDER BY 1, 8 DESC;  
 
-- Query 4
-- Product line inventory. 
SELECT warehouseCode, productLine,
       COUNT(CASE WHEN inventoryStatus = 'Restock' THEN 1 ELSE NULL END) AS 'restock <1 yr',
       COUNT(CASE WHEN inventoryStatus = 'Stocked' THEN 1 ELSE NULL END) AS 'stocked <5 yr',
       COUNT(CASE WHEN inventoryStatus = 'Overstocked' THEN 1 ELSE NULL END) AS 'overstocked <10 yr',
       COUNT(CASE WHEN inventoryStatus = 'Severely Overstocked' THEN 1 ELSE NULL END) AS 'severelyOverstocked >10 yr',
       ROUND(COUNT(CASE WHEN inventoryStatus = 'Severely Overstocked' THEN 1 ELSE NULL END) / COUNT(1), 2) 
       AS pctSeverelyOverstocked
  FROM (SELECT warehouseCode, p.productCode, productName, productLine, SUM(quantityOrdered) AS totalOrders,
	       ROUND((SUM(quantityOrdered) / (2 + (5/12))), 2) AS oneYearOrders, quantityInStock AS currentInventory, 
	       ROUND(quantityInStock / (SUM(quantityOrdered) / (2 + (5/12))), 2) AS yearsInventoryLeft,
	       CASE WHEN (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) <= 1 THEN 'Restock'
		    WHEN (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) > 1 
		         AND (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) <= 5 THEN 'Stocked'
		    WHEN (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) > 5 
			 AND (quantityInStock / (SUM(quantityOrdered) / (2 + (5/12)))) <= 10 THEN 'Overstocked'
		    ELSE 'Severely Overstocked' END AS inventoryStatus
	 FROM products p
	 JOIN orderdetails od
	   ON p.productCode = od.productCode
	GROUP BY 1, 2
	ORDER BY 1, 8 DESC
       ) sub
 GROUP BY 1, 2;

-- Query 5
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
 
/* Miscellaneous */

-- Query 6
-- Product missing sales data.
SELECT warehouseCode, p.productCode, productName, productLine, quantityOrdered, quantityInStock
  FROM orderdetails o
 RIGHT JOIN products p
    ON o.productCode = p.productCode
 WHERE p.productCode = 'S18_3233' 

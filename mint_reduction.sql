-- Product orders, revenue, and inventory.
SELECT p.warehouseCode, p.productName, p.productLine, SUM(od.quantityOrdered) AS totalOrders,
	   ROUND((SUM(od.quantityOrdered) / (2 + (5/12)))) AS avgYearOrders,  
       ROUND((p.MSRP - p.buyPrice) * (SUM(od.quantityOrdered) / (2 + (5/12))), 2) AS avgYearRevenue, 
       p.quantityInStock AS inventory,
       ROUND(p.quantityInStock / (SUM(od.quantityOrdered) / (2 + (5/12))), 2) AS yearsInventoryLeft
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
 GROUP BY p.warehouseCode, p.productCode
 ORDER BY p.warehouseCode, p.productLine, yearsInventoryLeft DESC;  
 
-- Warehouse capacity.
SELECT p.warehouseCode, w.warehouseName, 
	   ROUND(SUM(p.quantityInStock) / (w.warehousePctCap / 100), 0) AS warehouseCap
  FROM products p
  JOIN warehouses w
	ON p.warehouseCode = w.warehouseCode
 GROUP BY p.warehouseCode;
-- Shortest Path Algorithm

-- Choose database name
USE schema1;

-- Create a temporary table to store the results
CREATE TEMPORARY TABLE ShortestPathResult AS
WITH RECURSIVE ShortestPath (SourceDeviceID, SourceDeviceName, TargetDeviceID, TargetDeviceName, TotalCost, IDpath, DeviceIDArray, IncludePath, DeviceNamePath) AS (
  SELECT p.SourceDeviceID,
         p.SourceDeviceName,
         p.TargetDeviceID,
         p.TargetDeviceName,
         p.EdgeCost + d1.Nodecost + d2.Nodecost,
         CAST(CONCAT(p.SourceDeviceID, '>', p.TargetDeviceID) AS CHAR(500)) AS IDpath,
         JSON_ARRAY(p.TargetDeviceID) AS DeviceIDArray,
         CAST(CAST(p.PathID AS CHAR) AS CHAR(500)) AS IncludePath,
         CAST(CONCAT(d1.DeviceName, '>', d2.DeviceName) AS CHAR(500)) AS DeviceNamePath
  FROM Paths p
  INNER JOIN Devices d1 ON d1.DeviceID = p.SourceDeviceID
  INNER JOIN Devices d2 ON d2.DeviceID = p.TargetDeviceID
  WHERE p.SourceDeviceName = 'Source_11'
        AND d1.InUseState = 0
        AND d1.FaultState = 0
        AND d2.InUseState = 0
        AND d2.FaultState = 0

  UNION

  SELECT sp.SourceDeviceID, sp.SourceDeviceName, p.TargetDeviceID, p.TargetDeviceName, sp.TotalCost + p.EdgeCost + d.Nodecost,
         CAST(CONCAT(sp.IDpath, '>', p.TargetDeviceID) AS CHAR(500)) AS IDpath,
         JSON_ARRAY_APPEND(sp.DeviceIDArray, '$', p.TargetDeviceID) AS DeviceIDArray,
         CAST(CONCAT(sp.IncludePath, '>', CAST(p.PathID AS CHAR)) AS CHAR(500)) AS IncludePath,
         CAST(CONCAT(sp.DeviceNamePath, '>', d.DeviceName) AS CHAR(500)) AS DeviceNamePath
  FROM ShortestPath sp
  INNER JOIN Paths p ON p.SourceDeviceID = sp.TargetDeviceID
  INNER JOIN Devices d ON d.DeviceID = p.TargetDeviceID
  WHERE d.InUseState = 0
    AND d.FaultState = 0
    AND INSTR(CONCAT('>', sp.IDpath, '>'), CONCAT('>', p.TargetDeviceID, '>')) <= 0
)
SELECT *
FROM ShortestPath;

-- Create a new table to save the paths for the first destination input 
CREATE TEMPORARY TABLE Table1 AS
SELECT *
FROM ShortestPathResult
WHERE TargetDeviceName = 'DEST1';


-- Create a new table to save the paths for the second destination input 
CREATE TEMPORARY TABLE Table2 AS
SELECT *
FROM ShortestPathResult
WHERE TargetDeviceName = 'DEST6';


-- Create a new table to store the combination of table1 and table2
CREATE TEMPORARY TABLE Table3 AS
SELECT
  tb1.SourceDeviceName AS SourceDeviceName,
  tb1.TargetDeviceName AS TargetDeviceName1,
  tb1.DeviceNamePath AS DeviceNamePath1,

  tb1.TotalCost AS SubPathCost1,

  tb2.TargetDeviceName AS TargetDeviceName2,
  tb2.DeviceNamePath AS DeviceNamePath2,

  tb2.TotalCost AS SubPathCost2,
  tb1.TotalCost + tb2.TotalCost AS OverallCost
FROM Table1 tb1, Table2 tb2;

-- Output the 5 shortest paths ranked by the total cost

SELECT *
FROM Table3
ORDER BY OverallCost ASC
LIMIT 5;


-- Delete ShortestPathResult table if it exists
DROP TEMPORARY TABLE IF EXISTS ShortestPathResult;
-- Delete table1 if it exists
DROP TEMPORARY TABLE IF EXISTS Table1;
-- Delete table2 if it exists
DROP TEMPORARY TABLE IF EXISTS Table2;
-- Delete table3 if it exists
DROP TEMPORARY TABLE IF EXISTS Table3;


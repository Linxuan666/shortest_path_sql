-- Switch to transportation database

-- database name

USE schema1;

-- Create a new device table

CREATE TABLE Devices (
    DeviceID INT PRIMARY KEY,
    DeviceName VARCHAR(255) NOT NULL,

    IsSource TINYINT NOT NULL,
    IsDestination TINYINT NOT NULL,
    
    InUseState TINYINT NOT NULL,
    FaultState TINYINT NOT NULL,

    NodeCost INT
);

-- create a new path table

CREATE TABLE Paths (
    PathID INT PRIMARY KEY,

    SourceDeviceID INT,
    TargetDeviceID INT,

    SourceDeviceName VARCHAR(255),
    TargetDeviceName VARCHAR(255),

    EdgeCost INT,
    FOREIGN KEY (SourceDeviceID) REFERENCES Devices(DeviceID),
    FOREIGN KEY (TargetDeviceID) REFERENCES Devices(DeviceID)

);

-- Function: Insert new devices 
INSERT INTO Devices
VALUES (115, 'NEWDEVICE', 0, 0, 0, 0, 1);


-- Function: Remove devices
DELETE FROM Devices
WHERE DeviceID = 115; -- Remove device with ID 1

-- Update devices
-- Example: Update device at the selected DeviceID 
UPDATE Devices 
SET DeviceName = 'NEWDEVICE2', InUseState = 1, FaultState = 1 
WHERE DeviceID = 115; 



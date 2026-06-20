CREATE DATABASE FoodserviceDB;

USE FoodserviceDB;

CREATE TABLE Restaurants (
    Restaurant_ID INT PRIMARY KEY,
    Name VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Zip_Code VARCHAR(20),
    Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6),
    Alcohol_Service VARCHAR(50),
    Smoking_Allowed VARCHAR(50),
    Price VARCHAR(50),
    Franchise VARCHAR(20),
    Area VARCHAR(50),
    Parking VARCHAR(50)
);

CREATE TABLE Consumers (
    Consumer_ID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6),
    Smoker VARCHAR(20),
    Drink_Level VARCHAR(50),
    Transportation_Method VARCHAR(100),
    Marital_Status VARCHAR(50),
    Children VARCHAR(50),
    Age INT,
    Occupation VARCHAR(100),
    Budget VARCHAR(50)
);

CREATE TABLE Ratings (
    Consumer_ID VARCHAR(10),
    Restaurant_ID INT,
    Overall_Rating INT,
    Food_Rating INT,
    Service_Rating INT,

    PRIMARY KEY (Consumer_ID, Restaurant_ID),

    FOREIGN KEY (Consumer_ID)
        REFERENCES Consumers(Consumer_ID),

    FOREIGN KEY (Restaurant_ID)
        REFERENCES Restaurants (Restaurant_ID)
);

CREATE TABLE Restaurant_Cuisines (
    Restaurant_ID INT,
    Cuisine VARCHAR(100),

    PRIMARY KEY (Restaurant_ID, Cuisine),

    FOREIGN KEY (Restaurant_ID)
        REFERENCES Restaurants (Restaurant_ID)
);

INSERT INTO Restaurants
SELECT *
FROM Restaurant_Import;


INSERT INTO Consumers
SELECT * 
FROM Consumers_Import;

INSERT INTO Ratings
SELECT * 
FROM Ratings_Import;

INSERT INTO Restaurant_Cuisines
SELECT * 
FROM Restaurant_Cuisines_Import;




-- all restaurants with a Medium range price with open area,  serving Mexican food. 


SELECT 
    r.Restaurant_ID,
    r.Name,
    r.Price,
    r.Area,
    rc.Cuisine
FROM Restaurants r
JOIN Restaurant_Cuisines rc
ON r.Restaurant_ID = rc.Restaurant_ID
WHERE Price = 'Medium'
AND Area = 'Open'
AND rc.Cuisine = 'Mexican';


-- Write a query that returns the total number of restaurants who have the overall rating  as 1 and are serving Mexican food.
-- Compare the results with the total number of  restaurants who have the overall rating as 1 serving Italian food]]#

SELECT
    COUNT(DISTINCT
        CASE
            WHEN rc.Cuisine = 'Mexican'
            THEN r.Restaurant_ID
        END
    ) AS Number_Of_Mexican_1Star_Restaurants,

    COUNT(DISTINCT
        CASE
            WHEN rc.Cuisine = 'Italian'
            THEN r.Restaurant_ID
        END
    ) AS Number_Of_Italian_1Star_Restaurants

FROM Restaurants r
JOIN Ratings ra
    ON r.Restaurant_ID = ra.Restaurant_ID
JOIN Restaurant_Cuisines rc
    ON r.Restaurant_ID = rc.Restaurant_ID
WHERE ra.Overall_Rating = 1;



-- Calculate the average age of consumers who have given a 0 rating to the 'Service_rating'  column. 



SELECT 
    ROUND(AVG(c.Age),0) Avg_Age
FROM 
Consumers c
JOIN Ratings r
    ON c.Consumer_ID = r.Consumer_ID
WHERE r.Service_Rating = 0;



-- Write a query that returns the restaurants ranked by the youngest consumer. 
-- You  should include the restaurant name and food rating that is given by that customer to  the restaurant in your result. 
-- Sort the results based on food rating from high to low. 

SELECT 
    DENSE_RANK() OVER(ORDER BY Food_Rating DESC) AS Restaurant_Rank,
    r.Name,
    ra.Food_Rating
    FROM Restaurants r
JOIN Ratings ra
    ON r.Restaurant_ID = ra.Restaurant_ID
JOIN Consumers c
    ON ra.Consumer_ID = c.Consumer_ID
WHERE c.Age IN
            (SELECT MIN(Age)
            FROM Consumers)
ORDER BY ra.Food_Rating DESC;

-- Write a stored procedure for the query given as: 
-- Update the Service_rating of all restaurants to '2' if they have parking available, either  as 'yes' or 'public' 


CREATE PROCEDURE Update_Service_Ratings_When_Parking_Available
AS
BEGIN
    UPDATE Ratings
    SET Service_Rating = 2
    WHERE Restaurant_ID IN
    (
        SELECT Restaurant_ID
        FROM Restaurants
        WHERE Parking IN ('Yes', 'Public')
    );
END;

EXEC Update_Service_Ratings_When_Parking_Available;


-- Write four queries of your own & make use of all of the following at least  once: 
-- Nested queries-EXISTS 
-- Nested queries-IN 
-- System functions 
-- Use of GROUP BY, HAVING and ORDER BY clauses 

-- Restaurants With Above Average Food Rating (Nested Query - IN)



SELECT
    Name
FROM Restaurants
WHERE Restaurant_ID IN
(
    SELECT Restaurant_ID
    FROM Ratings
    GROUP BY Restaurant_ID
    HAVING AVG(Food_Rating) >
    (
        SELECT AVG(Food_Rating)
        FROM Ratings
    )
);

-- Restaurants That Have Been Rated (Nested Query - EXISTS)

SELECT
    r.Restaurant_ID,
    r.Name
FROM Restaurants r
WHERE EXISTS
(
    SELECT 1
    FROM Ratings ra
    WHERE ra.Restaurant_ID = r.Restaurant_ID
);

-- Average Consumer Age By Budget Category (System Function + GROUP BY + ORDER BY)

SELECT
    Budget,
    ROUND(AVG(Age),0) AS Average_Age
FROM Consumers
GROUP BY Budget
ORDER BY Average_Age DESC;

-- Cuisine Types With More Than 10 Restaurants (GROUP BY + HAVING + ORDER BY)
SELECT
    Cuisine,
    COUNT(DISTINCT Restaurant_ID) AS Number_Of_Restaurants
FROM Restaurant_Cuisines
GROUP BY Cuisine
HAVING COUNT(DISTINCT Restaurant_ID) > 10
ORDER BY Number_Of_Restaurants DESC;
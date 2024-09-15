CREATE DATABASE music_store;
USE music_store;


-- Question Set - 1 EASY
-- 1. Who is the Senior Most employee based on levels?
SELECT Employee_ID, CONCAT(first_name, " ", last_name) AS Full_Name, 
Title, Levels, Email, City, State FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most Invoices?
SELECT billing_country AS Country, count(invoice_id) AS Total_Invoice_Count 
FROM Invoice GROUP BY Billing_country
ORDER BY Total_Invoice_Count DESC
LIMIT 5;
-- Output shows top 5 Countries with Most Invoices

-- 3. What are the top 3 values of total price in the invoice table?
SELECT Invoice_Id, Customer_Id, Billing_Country, ROUND(Total) FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4. Which city has the best customers based on sum of invoice totals.
SELECT Billing_City AS City, ROUND(SUM(total)) AS Total_Revenue FROM invoice GROUP BY billing_city
ORDER BY Total_Revenue DESC
LIMIT 5;

-- 5. Who is the best customer based on the most money spent.
SELECT Customer.Customer_ID, 
CONCAT(first_name, " ", last_name) AS Full_Name, 
City, 
ROUND(SUM(total), 2) AS Total_Amount_Spent
FROM Customer LEFT JOIN Invoice ON Customer.Customer_id = Invoice.Customer_id
GROUP BY Customer_id
ORDER BY SUM(total) DESC
LIMIT 1;
    
    
    
    
    
-- Question Set - 2 MODERATE
-- 1. Return Email, Full Name and Genre of all Rock Music Listeners. Sort the Table by Email column Alphabatically.
SELECT CONCAT(first_name, " ", last_name) AS Full_Name, 
Email, Track.Track_ID, Genre.Name,
COUNT(genre.name) AS Genre 
FROM Customer 
LEFT JOIN Invoice ON Customer.Customer_ID = Invoice.Customer_ID
LEFT JOIN Invoice_Line ON Invoice.Invoice_ID = Invoice_Line.Invoice_ID
LEFT JOIN Track ON Invoice_Line.Track_ID = Track.Track_ID
LEFT JOIN Genre ON Track.Genre_ID = Genre.Genre_ID
GROUP BY CONCAT(first_name, " ", last_name)
HAVING Genre.Name= "Rock"
ORDER BY Email
limit 10;


/* 2. Find Top 10 Artists who have written the Most Rock Songs in the Dataset. 
	  Return Artist ID, Artist Name and Total Track Count.
*/
SELECT Artist.Artist_ID, Artist.Name AS Name, 
COUNT(Track.Track_ID) AS Count_of_Tracks
FROM Artist
JOIN Album
ON Artist.Artist_ID = Album.Artist_ID
JOIN Track
ON Album.Album_ID = Track.Album_ID
JOIN Genre
ON Track.Genre_ID = Genre.Genre_ID
WHERE Genre.Name = "Rock"
GROUP BY Artist.Artist_ID
ORDER BY COUNT(Track.Track_ID) DESC
LIMIT 10;

/* 3. Find Top 10 Track Names that hava a song length longer than the average song length.
	  Return the Song Name and Duration in Minutes for each Track. Sort by Song lenght in Descending order.
*/
-- 1 Minute = 60 Seconds
-- 1 Second = 1000 Milliseconds

SELECT ROW_NUMBER() OVER(ORDER BY Milliseconds DESC) AS "S.No.", 
Name AS Song_Name, 
(Milliseconds/60000) AS Duration_in_Minutes 
FROM Track
WHERE Milliseconds > (SELECT AVG(Milliseconds) FROM Track)
LIMIT 10;





/* Question Set - 3 ADVANCE
   1. Find the Top selling Artist and the Customer who has spent the most for that Artist. 
*/
WITH Best_Selling_Artist AS (
SELECT A.Artist_ID, A.Name , 
ROUND(SUM(IL.Unit_Price * IL.Quantity),2) AS Total
FROM Artist AS A
JOIN Album AS AL
ON A.Artist_ID = AL.Artist_ID
JOIN Track AS T
ON AL.Album_ID = T.Album_ID
JOIN Invoice_Line AS IL
ON T.Track_ID = IL.Track_ID
GROUP BY Name
ORDER BY Total DESC
LIMIT 1
)
SELECT CONCAT(C.First_Name, " ", C.Last_Name) AS Name, 
SUM(IL.Unit_Price * IL.Quantity) as Total, BSA.Name AS Artist_Name
FROM Artist AS A
JOIN Album AS AL
ON A.Artist_ID = AL.Artist_ID
JOIN Track AS T
ON AL.Album_ID = T.Album_ID
JOIN Invoice_Line AS IL
ON T.Track_ID = IL.Track_ID
JOIN Invoice AS I
ON IL.Invoice_ID = I.Invoice_ID
JOIN Customer AS C
ON I.Customer_ID = C.Customer_ID
JOIN Best_Selling_Artist AS BSA
ON A.Artist_ID = BSA.Artist_ID
GROUP BY C.Customer_ID
ORDER BY Total DESC
LIMIT 10;


SELECT COUNT(DISTINCT COUNTRY) FROM CUSTOMER;

-- 2. Return the Most Popular Music Genre for each Country based on the highest count of purchases.
WITH Most_Popular_Genre AS (
SELECT C.Country, COUNT(IL.Quantity) AS Total_Purchases, G.Name,
RANK() OVER(PARTITION BY C.Country ORDER BY COUNT(IL.Quantity) DESC) AS Ranking
FROM Customer AS C
JOIN Invoice AS I
ON C.Customer_ID = I.Customer_ID
JOIN Invoice_Line as IL
ON I.Invoice_ID = IL.Invoice_ID
JOIN Track AS T
ON IL.Track_ID = T.Track_ID
JOIN Genre AS G
ON T.Genre_ID = G.Genre_ID
GROUP BY C.Country, G.Genre_ID
)
SELECT * FROM Most_Popular_Genre WHERE Ranking=1
LIMIT 10;

-- From the above query's result we found out that the Genre "Rock" is the Most Popular Genre in All the Countries but Argentina.


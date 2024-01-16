create database Music_Store;

use Music_Store;


/*Q1: Who is the senior most employee based on job title?*/

select first_name, last_name, title from employee
order by levels desc
limit 1;


/*Q2: Which countries have the most Invoices?*/

select billing_country, count(billing_country) as Country from invoice
group by billing_country
order by Country desc
limit 1;


/*Q3: What are the top 3 values of the total invoice?*/

select invoice_id, round(total,0) as Total from invoice
order by Total desc
limit 3;


/*Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city where we made the most money.*/

select billing_city, round(sum(total),2) as Total from invoice
group by billing_city
order by Total desc
limit 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name, c.last_name, round(sum(i.total),2) as Total from 
invoice i inner join customer c using(customer_id)
group by c.customer_id
order by Total desc limit 5;


/* Q6: Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select Distinct c.customer_id, c.first_name, c.last_name, c.email, g.name from 
customer c INNER JOIN invoice i using(customer_id)
INNER JOIN invoice_line il using(invoice_id)
INNER JOIN track t using(track_id)
INNER JOIN genre g using(genre_id)
where g.name = "Rock"
order by c.email asc;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select a.name, count(t.track_id) as Number_of_Songs from
artist a INNER JOIN album2 al using(artist_id)
INNER JOIN track t using(album_id)
INNER JOIN genre g using(genre_id)
where g.name = "Rock"
group by a.artist_id
order by Number_of_songs desc limit 10;


select * from track;


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds from track
where milliseconds > (select round(avg(milliseconds),2) as Avg_length from track)
order by milliseconds desc;



/* Q9: Find how much amount spent by each customer on artists. Write a query to return the customer name, artist name, and total spent */

with best_artist as
(select a.artist_id, a.name, round(sum(il.unit_price*il.quantity),2) as Amount_Spent from 
artist a inner join album2 al using(artist_id)
inner join track t using(album_id)
inner join invoice_line il using(track_id) 
group by a.artist_id
order by 3 desc)

select c.customer_id, c.first_name, c.last_name, bs.name, round(sum(il.unit_price*il.quantity),2) as Spending from
customer c inner join invoice i using(customer_id)
inner join invoice_line il using(invoice_id)
inner join track t using(track_id)
inner join album2 al using(album_id)
inner join best_artist bs using(artist_id)
group by 1,2,3,4
order by 5 desc;



/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as
(select c.country, g.genre_id, g.name, count(il.quantity) as Purchase, 
row_number() over(partition by c.country order by count(il.quantity) desc) as Row_no
from invoice_line il inner join invoice i using(invoice_id)
inner join customer c using(customer_id)
inner join track t using(track_id)
inner join genre g using(genre_id)
group by 1,2,3
order by 1 asc, 4 desc)

select * from popular_genre 
where row_no <= 1;



/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,round(SUM(total),2) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY round(SUM(total),2) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1


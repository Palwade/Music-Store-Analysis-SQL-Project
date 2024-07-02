Q1 : Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1	

Q2:Which countries have the most Invoices?
select count(*) as c,billing_country
from invoice
group by billing_country
order by c desc

--Q3 : what are top 3 values of total invoice

select total from invoice
order by total desc
limit 3

--Q4 which city has the best customers?We would like to throw a promotional music festival in the city
--we made th most money. Write query that returnes one city that has the highest sum of invoices totals.
--Return both the city name and sum of all invoices totals

select sum(total) as invoice_total,billing_city from invoice
group by billing_city
order by invoice_total desc

--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer 
--   Write a query that returnes the person who has spent the most money
	
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id	
order by total desc
limit 1

--Question Set 2- Modrate
Q1 :Write query to return the email,first name,last name & genre of all rock music listeners.Return your list ordered alphabetically
by email starting with A

select distinct first_name,last_name, email from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;

Q2: lets invite the artist who have written the most rock music in our dataset. write a query that returns the artist name and total track
count of the top 10 rock bands

select artist.artist_id,artist.name,count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

Q3 : Return all the track names that have song length longer than the average song length. Return the name and millseconds for each 
track.Order by the song length with the longest songs listed first

select name,milliseconds
from Track
Where milliseconds > (
	select AVG(milliseconds) as avg_track_length from track)
	Order by milliseconds Desc;
)

--Advance
Q1--:Find how much amount spent by each customer on artist? Write a query to return customer name,artist name and total spent

WITH best_selling_artist AS (
    SELECT 
        artist.artist_id AS artist_id,
        artist.name AS artist_name,
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM 
        invoice_line
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        album ON album.album_id = track.album_id
    JOIN 
        artist ON artist.artist_id = album.artist_id
    GROUP BY 
        artist.artist_id, artist.name
    ORDER BY 
        total_sales DESC
    LIMIT 1
)
SELECT 
    c.customer_id, 
    c.first_name,
    c.last_name,
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    invoice i
JOIN 
    customer c ON c.customer_id = i.customer_id
JOIN 
    invoice_line il ON il.invoice_id = i.invoice_id
JOIN 
    track t ON t.track_id = il.track_id
JOIN 
    album alb ON alb.album_id = t.album_id
JOIN 
    best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 
    amount_spent DESC;


Q 3--2 we want to find out the most popular music Genere for each country.
we determine the most popular genre as the genre with the highest amount of purchases.Write a query 
that returns each country along with top genre For countries where the maximum number of purches is shared
return all Generes.

WITH popular_genre AS (
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name,
        genre.genre_id,
        ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM 
        invoice_line
    JOIN 
        invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        genre ON genre.genre_id = track.genre_id
    GROUP BY 
        customer.country, genre.name, genre.genre_id
    ORDER BY 
        customer.country ASC, purchases DESC
)
SELECT 
    *
FROM 
    popular_genre
WHERE 
    RowNo <= 1;










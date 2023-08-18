--Who is the Senior most employee based on the job title.
select * from employee where hire_date=(select min(hire_date) from employee);

--Which countries have the most Invoices?
select billing_country from invoice group by billing_country having count(*)=(select max(counting) from 
(select count(*) as counting from invoice group by billing_country)a);

--What are top 3 values of total invoice?
select top 3 total from invoice order by total desc;

/*
Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
*/
select top 1 billing_city, sum(total) as total_invoice from invoice group by billing_city order by total_invoice desc;

--Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
select top 1 customer.customer_id,customer.first_name,customer.last_name, sum(total) as total from customer join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name order by total desc;

--Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select distinct c.email, c.first_name, c.last_name
from Customer c join invoice i on c.customer_id=i.customer_id join invoice_line i1 on i.invoice_id=i1.invoice_id join track t on i1.track_id=t.track_id join genre g on t.genre_id=g.genre_id
where g.name='Rock' order by c.email;

--Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
select Top 10 a.name as 'Artist Name', count(*) as 'Total Track'
from artist a join album ab on a.artist_id=ab.artist_id join track t on ab.album_id=t.album_id join genre g on t.genre_id=g.genre_id
where g.name like 'Rock' group by a.name order by [Total Track] desc;

--Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select t.name,t.milliseconds from track t where milliseconds>
(select avg(milliseconds) from track) order by milliseconds desc;

--Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
with CTE as
(select a.name as 'artist name', a.artist_id, sum(il.quantity*il.unit_price) as 'total amount'
from artist a join album al on a.artist_id=al.artist_id join track t on al.album_id=t.album_id join invoice_line il on t.track_id=il.track_id
group by a.name,a.artist_id)
select distinct c.first_name+' '+c.last_name as 'Customer name', CTE.[artist name], CTE.[total amount]
from customer c join invoice_line il on il.invoice_id=il.invoice_id join track t on il.track_id=t.track_id join album a on t.album_id=a.album_id
join CTE on a.artist_id=CTE.artist_id order by [total amount] desc;

/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre.
For countries where the maximum number of purchases is shared return all Genres
*/
with CTE as
(select c.country, count(il.quantity) as 'total units', g.name as 'genre', row_number() over (partition by c.country order by count(il.quantity) desc) as rw_no
from customer c join invoice i on c.customer_id=i.customer_id join invoice_line il on i.invoice_id=il.invoice_id join track t on il.track_id=t.track_id join genre g on t.genre_id=g.genre_id
group by c.country,g.name)
select CTE.country,CTE.[total units],CTE.genre from CTE where country = (select c1.country from CTE c1 where c1.[total units]=(select max(c2.[total units]) from CTE c2))
union
select CTE.country,CTE.[total units],CTE.genre from CTE where rw_no =1 and country not in (select c1.country from CTE c1 where c1.[total units]=(select max(c2.[total units]) from CTE c2))
order by country

/*
Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent.
For countries where the top amount spent is shared, provide all customers who spent this amount
*/
with CTE as 
(select c.first_name+' '+c.last_name as 'Customer_name', c.country, sum(i.total) as total_amount, rank() over(partition by country order by sum(total) desc) as ranking
from customer c join invoice i on c.customer_id=i.customer_id
group by c.first_name,c.last_name,c.country)
select Customer_name,country,total_amount from CTE where country in 
(select country from CTE where total_amount =(select max(total_amount) from CTE))
union
select Customer_name,country,total_amount from CTE where ranking=1 and country not in (select country from CTE where total_amount =(select max(total_amount) from CTE))
order by total_amount desc






























































































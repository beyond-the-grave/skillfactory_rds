    /*------------------------- TABLE_1 -------------------------
      -- ХАРАКТЕРИСТИКА САМОЛЕТА --------------------------------  */

with table_1 as (
    SELECT f.flight_id,air.model,air.range ---- AIRCRAFT MODEL & FLIGHT RANGE
    FROM dst_project.flights f
        join dst_project.aircrafts air on air.aircraft_code = f.aircraft_code
    GROUP BY
        f.flight_id,air.model,air.range),
    
    /*------------------------- TABLE_2 -------------------------
      -- СУММА КУПЛЕННЫХ БИЛЕТОВ --------------------------------  */
        
    table_2 as (
    SELECT 
    f.flight_id, sum(b.total_amount) as book_amount ---- TOTAL AMOUNT PER FLIGHT
    FROM dst_project.flights f
        join dst_project.ticket_flights tf on tf.flight_id = f.flight_id
        join dst_project.tickets tick on tick.ticket_no = tf.ticket_no
        join dst_project.bookings b on b.book_ref = tick.book_ref
    GROUP BY
        f.flight_id),
    
    /*------------------------- TABLE_3 -------------------------
      -- КОЛИЧЕСТВО МЕСТ В САМОЛЕТЕ -----------------------------  */
    
    table_3 as (
    SELECT 
    f.flight_id, count(s.seat_no) as total_seat ---- TOTAL SEAT ON USED AIRPLANE 
    FROM dst_project.flights f
        join dst_project.seats s on s.aircraft_code = f.aircraft_code
    GROUP BY
        f.flight_id),
    
    /*------------------------- TABLE_4 -------------------------
      -- КОЛИЧЕСТВО ИСПОЛЬЗОВАННЫХ МЕСТ В САМОЛЕТЕ --------------  */
        
    table_4 as (
    SELECT 
    f.flight_id, count(bord.seat_no) as used_seat ---- USED SEAT PER FLIGHT
    FROM dst_project.flights f
        join dst_project.boarding_passes bord on bord.flight_id = f.flight_id
    GROUP BY
        f.flight_id),
        
        
    /*------------------------- TABLE_5 -------------------------
      -- ВРЕМЯ ПОЛЕТА ИЗ АНАПЫ ДО КОНЕЧНОГО АЭРОПОРТА -----------  */
    
    table_5 AS (
    SELECT
        f.flight_id,
        EXTRACT(EPOCH FROM (f.scheduled_arrival - f.scheduled_departure)) / 60 AS flight_duration ---- FLIGHT DURATION PER FLIGHT
    FROM
        dst_project.flights f
    GROUP BY
        f.flight_id)
        
    
    ------------------------- JOIN -------------------------
    
select f.flight_id,f.arrival_airport,
        table_1.model,table_1.range,
        table_2.book_amount,
        table_3.total_seat,
        table_4.used_seat,
        (table_3.total_seat - table_4.used_seat) as seat_diff,
        table_5.flight_duration
    from dst_project.flights f
    left join table_1 on f.flight_id = table_1.flight_id
    left join table_2 on f.flight_id = table_2.flight_id
    left join table_3 on f.flight_id = table_3.flight_id
    left join table_4 on f.flight_id = table_4.flight_id
    left join table_5 on f.flight_id = table_5.flight_id
WHERE departure_airport = 'AAQ'
  AND (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
  AND status not in ('Cancelled')
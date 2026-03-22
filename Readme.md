# dbops-project


```sql
CREATE DATABASE store;
CREATE ROLE tester LOGIN PASSWORD 'BlHfck9Q&F^!np75';
GRANT CONNECT ON DATABASE store TO tester;
/c store
GRANT USAGE ON SCHEMA public TO tester;
GRANT CREATE ON SCHEMA public TO tester;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO tester;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO tester;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO tester;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO tester;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO tester;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO tester;
```

**Без оптимизации**
```sql
SELECT SUM(op.quantity) AS quantity
    ,o.date_created AS date
FROM
    orders o
JOIN
    order_product op ON op.order_id = o.id
WHERE
    o.date_created > NOW() - INTERVAL '7 DAY' AND o.status = 'shipped'
GROUP BY
    o.date_created;
```
```
                                                                             QUERY PLAN                                                                              
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize GroupAggregate  (cost=271276.08..271299.13 rows=91 width=12) (actual time=2149.312..2153.973 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=271276.08..271297.31 rows=182 width=12) (actual time=2149.286..2153.945 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=270276.05..270276.28 rows=91 width=12) (actual time=2121.209..2121.212 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=270272.18..270273.09 rows=91 width=12) (actual time=2121.190..2121.194 rows=7 loops=3)
                     Group Key: o.date_created
                     Batches: 1  Memory Usage: 24kB
                     Worker 0:  Batches: 1  Memory Usage: 24kB
                     Worker 1:  Batches: 1  Memory Usage: 24kB
                     ->  Parallel Hash Join  (cost=148330.58..269751.67 rows=104103 width=8) (actual time=754.911..2102.340 rows=84600 loops=3)
                           Hash Cond: (op.order_id = o.id)
                           ->  Parallel Seq Scan on order_product op  (cost=0.00..105362.15 rows=4166715 width=12) (actual time=0.011..363.932 rows=3333333 loops=3)
                           ->  Parallel Hash  (cost=147029.29..147029.29 rows=104103 width=12) (actual time=753.699..753.700 rows=84600 loops=3)
                                 Buckets: 262144  Batches: 1  Memory Usage: 13984kB
                                 ->  Parallel Seq Scan on orders o  (cost=0.00..147029.29 rows=104103 width=12) (actual time=13.248..714.010 rows=84600 loops=3)
                                       Filter: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                       Rows Removed by Filter: 3248733
 Planning Time: 0.125 ms
 JIT:
   Functions: 54
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 2.140 ms, Inlining 0.000 ms, Optimization 3.137 ms, Emission 36.631 ms, Total 41.909 ms
 Execution Time: 2154.837 ms
(29 rows)
```
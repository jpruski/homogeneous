CREATE TYPE basis AS OBJECT (id NUMBER, a NUMBER, b NUMBER, c NUMBER); -- a > b > c
CREATE TYPE dependant AS OBJECT (id NUMBER, fk NUMBER, a NUMBER, b NUMBER, c NUMBER);
CREATE TABLE point OF basis;
-- add points here
CREATE TABLE corner OF basis;
insert all
    into corner values(1,1,0,0)
    into corner values(2,0,1,0)
    into corner values(3,0,0,1)
select * from dual;
CREATE TABLE triangle OF dependant;
CREATE TABLE circumcenters OF dependant;
insert into triangle
    with
        p as (select id, A+B+C as W, A, B, C from point),
        w2 as (select id, w*w as w2 from p),
        delta as (
            select
                p.id,
                p.A-(corner.A*p.W) as a,
                p.B-(corner.B*p.W) as b,
                p.C-(corner.C*p.W) as c
            from p cross join corner),
        lengths as (
            select
                id,
                (0  - delta.b*delta.c
                    - delta.c*delta.a
                    - delta.a*delta.b) as length
            from delta),
        upper_lower as (
            select id, max(length) as upper, min(length) as lower
            from lengths group by id),
        labeled as (
            select lengths.id, lengths.length as middle, upper_lower.upper, upper_lower.lower
            from lengths join upper_lower on lengths.id=upper_lower.id
            where
                lengths.length <> upper_lower.upper
                    and
                lengths.length <> upper_lower.lower),
        intermediate as (
            select 1 as id, id as fk, upper as b, middle as c from labeled
                union
            select 2 as id, id as fk, lower as b, upper as c from labeled
                union
            select 3 as id, id as fk, middle as b, lower as c from labeled)
        select intermediate.id, fk, w2 as a, b, c from intermediate inner join w2 on intermediate.fk=w2.id;
insert into circumcenters select
    id, fk,
    triangle.a*(triangle.b+triangle.c-triangle.a) as a,
    triangle.b*(triangle.c+triangle.a-triangle.b) as b,
    triangle.c*(triangle.a+triangle.b-triangle.c) as c
from triangle;
commit;
/

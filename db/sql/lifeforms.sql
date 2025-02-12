-- Prints all lifeforms along with parentage info
select l.class_name
    , l.name
    , l.energy
    , l.size, l.obj_data
    , l.generation
    , lp.name as parent
    , x
    , y
from lifeforms l
left outer join lifeforms lp on lp.id = l.parent_id
order by name asc;
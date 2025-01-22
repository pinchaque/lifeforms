select l.class_name
    , l.name
    , l.energy
    , l.size, l.obj_data, 
    lp.name as parent
from lifeforms l
left outer join lifeforms lp on lp.id = l.parent_id
order by name asc;
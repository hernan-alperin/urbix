--- 2015-06-02
/* remove
        type        | code |    short_desc     |                                                                  description    
 VARIABLE_IN_ACCESS |   11 | IN ACCESO         | OUT ACCESO ESCALERA MECANICA PB
 VARIABLE_IN_ACCESS |   13 | IN ACCESO         | OUT ACCESO PUNTERA URIBURU LACOSTE N1
from ums_code
*/

delete from ums_code
where type = 'VARIABLE_IN_ACCESS'
and description in ('OUT ACCESO ESCALERA MECANICA PB','OUT ACCESO PUNTERA URIBURU LACOSTE N1')
;

--- pausa

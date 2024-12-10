%let pgm=utl-flag-observations-with-same-id-date-but-different-result-sas-sql-r-python-multi-language;

%stop_solution;

Flag observations with same id/date but different result sas sql r python multi language


     SOLUTIONS

         1 sas sql
         2 sas dow loop
         3 r sql
         4 pyhton sql

The ops solution givem does not flag both observations in the dup group(id,dt) with different results.

github
https://tinyurl.com/4k63c69y
https://github.com/rogerjdeangelis/utl-flag-observations-with-same-id-date-but-different-result-sas-sql-r-python-multi-language

sas community
https://tinyurl.com/4dyuuyhv
https://stackoverflow.com/questions/79248160/flag-observations-with-same-id-date-but-different-result

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/**************************************************************************************************************************/
/*                                        |                                           |                                   */
/*         INPUT                          |            PROCESS                        |            OUTPUT                 */
/*                                        |                                           |                                   */
/*                                        |                                           |                                   */
/*  ID     DT      RESULT                 | Flag observations with the same ID        | ID      DT    RESULT FLAG         */
/*                                        | and Date but different results.           |                                   */
/*  1  2024-04-27     1  Same             |                                           | 1   2024-04-27    1   0  No dif   */
/*  1  2024-04-27     1  Same             | The inner nested select outputs           | 1   2024-04-27    1   0           */
/*                                        | the dup groups (id, dt) with              |                                   */
/*  1  2024-04-30     2  Same             | different results                         | 1   2024-04-30    2   0  No Dif   */
/*  1  2024-04-30     2  Same             |                                           | 1   2024-04-30    2   0           */
/*                                        |     DT         FLAG                       |                                   */
/*  2  2024-05-05     1  Flag same        |                                           | 2   2024-05-05    1   1  Has Dif  */
/*  2  2024-05-05     2  id and date      | 2024-05-05       1                        | 2   2024-05-05    2   1  =======  */
/*                       but dif results  | 2024-07-07       1                        |                                   */
/*                                        |                                           | 3   2024-06-06    1   0  No Dif   */
/*  3  2024-06-06     1  Same             | The we left join to original              | 3   2024-06-06    1   0           */
/*  3  2024-06-06     1  Same             | data and it adds the flag                 |                                   */
/*                                        | to the correct dup groups                 | 4   2024-07-07    1   1  Has Did  */
/*  4  2024-07-07     1  Flag same        | wth diff results                          | 4   2024-07-07    2   1  ======== */
/*  4  2024-07-07     2  id and date      |                                           |                                   */
/*                       but dif results  |                                           | 4   2024-07-17    2   0  No Diff  */
/*                                        | 1 SAS SOLUTON                             | 4   2024-07-17    2   0           */
/*  4  2024-07-17     2  Same             | =============                             |                                   */
/*  4  2024-07-17     2  Same             |                                           |                                   */
/*                                        | select                                    |                                   */
/*                                        |     l.ID                                  |                                   */
/*                                        |    ,l.DT                                  |                                   */
/*                                        |    ,l.RESULT                              |                                   */
/*                                        |    ,(r.flag=1) as flag                    |                                   */
/*                                        | from                                      |                                   */
/*                                        |   sd1.have as l left join                 |                                   */
/*                                        |     (select                               |                                   */
/*                                        |        id                                 |                                   */
/*                                        |       ,dt                                 |                                   */
/*                                        |       ,1 as flag                          |                                   */
/*                                        |     from                                  |                                   */
/*                                        |       sd1.have                            |                                   */
/*                                        |     group                                 |                                   */
/*                                        |       by id, dt                           |                                   */
/*                                        |     having                                |                                   */
/*                                        |       count(distinct result) > 1) as r    |                                   */
/*                                        | on                                        |                                   */
/*                                        |        l.id = r.id                        |                                   */
/*                                        |    and l.dt = r.dt                        |                                   */
/*                                        |    and l.result = r.result                |                                   */
/*                                        |                                           |                                   */
/*                                        |                                           |                                   */
/*                                        |                                           |                                   */
/*                                        | 2  SAD DOW LOOPING (note dif outside if)  |                                   */
/*                                        | ==================                        |                                   */
/*                                        |                                           |                                   */
/*                                        | data want;                                |                                   */
/*                                        |  retain tot 0;                            |                                   */
/*                                        |  do until(last.dt);                       |                                   */
/*                                        |    set sd1.have;                          |                                   */
/*                                        |    by id dt;                              |                                   */
/*                                        |    diff=dif(result);                      |                                   */
/*                                        |    if first.dt then tot=0;                |                                   */
/*                                        |    else tot = sum(tot, (abs(diff ne 0))); |                                   */
/*                                        |    if last.dt and tot>0 then do;          |                                   */
/*                                        |      savdt=dt;                            |                                   */
/*                                        |      savid=id;                            |                                   */
/*                                        |    end;                                   |                                   */
/*                                        |  end;                                     |                                   */
/*                                        |  do until(last.dt);                       |                                   */
/*                                        |    set sd1.have;                          |                                   */
/*                                        |    by id dt;                              |                                   */
/*                                        |    if savdt=dt and savid=id then flag=1;  |                                   */
/*                                        |    else flag=0;                           |                                   */
/*                                        |    keep id dt result flag;                |                                   */
/*                                        |    output;                                |                                   */
/*                                        |  end;                                     |                                   */
/*                                        | run;quit;                                 |                                   */
/*                                        |                                           |                                   */
/*                                        |                                           |                                   */
/*                                        | 3 R & PYTHON SQL (SAME CODE)              |                                   */
/*                                        | ============================              |                                   */
/*                                        |                                           |                                   */
/*                                        | with                                      |                                   */
/*                                        |    dif as (                               |                                   */
/*                                        | select                                    |                                   */
/*                                        |    id                                     |                                   */
/*                                        |   ,dt                                     |                                   */
/*                                        |   ,result                                 |                                   */
/*                                        |   ,(count(distinct result) > 1) as flag   |                                   */
/*                                        | from                                      |                                   */
/*                                        |   have                                    |                                   */
/*                                        | group                                     |                                   */
/*                                        |   by id, dt                               |                                   */
/*                                        | having                                    |                                   */
/*                                        |   count(distinct result) > 1 )            |                                   */
/*                                        | select                                    |                                   */
/*                                        |     l.ID                                  |                                   */
/*                                        |    ,l.DT                                  |                                   */
/*                                        |    ,l.RESULT                              |                                   */
/*                                        |    ,coalesce(r.flag,0) as flag            |                                   */
/*                                        | from                                      |                                   */
/*                                        |   have as l left join dif as r            |                                   */
/*                                        | on                                        |                                   */
/*                                        |        l.id = r.id                        |                                   */
/*                                        |    and l.dt = r.dt                        |                                   */
/*                                        |                                           |                                   */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/
options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  input ID$ Dt $10. result;
cards4;
1 2024-04-27 1
1 2024-04-27 1
1 2024-04-30 2
1 2024-04-30 2
2 2024-05-05 1
2 2024-05-05 2
3 2024-06-06 1
3 2024-06-06 1
4 2024-07-07 1
4 2024-07-07 2
4 2024-07-17 2
4 2024-07-17 2
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*   ID        DT        RESULT                                                                                           */
/*                                                                                                                        */
/*   1     2024-04-27       1                                                                                             */
/*   1     2024-04-27       1                                                                                             */
/*   1     2024-04-30       2                                                                                             */
/*   1     2024-04-30       2                                                                                             */
/*   2     2024-05-05       1                                                                                             */
/*   2     2024-05-05       2                                                                                             */
/*   3     2024-06-06       1                                                                                             */
/*   3     2024-06-06       1                                                                                             */
/*   4     2024-07-07       1                                                                                             */
/*   4     2024-07-07       2                                                                                             */
/*   4     2024-07-17       2                                                                                             */
/*   4     2024-07-17       2                                                                                             */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                             _
/ |  ___  __ _ ___   ___  __ _| |
| | / __|/ _` / __| / __|/ _` | |
| | \__ \ (_| \__ \ \__ \ (_| | |
|_| |___/\__,_|___/ |___/\__, |_|
                            |_|
*/

proc sql;
  create
     table want as
  select
      l.ID
     ,l.DT
     ,l.RESULT
     ,(r.flag=1) as flag
  from
    sd1.have as l left join
      (select
         id
        ,dt
        ,1 as flag
      from
        sd1.have
      group
        by id, dt
      having
        count(distinct result) > 1) as r
  on
         l.id = r.id
     and l.dt = r.dt
     and l.result = r.result

;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*   ID        DT        RESULT    FLAG                                                                                   */
/*                                                                                                                        */
/*   1     2024-04-27       1        0                                                                                    */
/*   1     2024-04-27       1        0                                                                                    */
/*   1     2024-04-30       2        0                                                                                    */
/*   1     2024-04-30       2        0                                                                                    */
/*   2     2024-05-05       1        1                                                                                    */
/*   2     2024-05-05       2        1                                                                                    */
/*   3     2024-06-06       1        0                                                                                    */
/*   3     2024-06-06       1        0                                                                                    */
/*   4     2024-07-07       1        1                                                                                    */
/*   4     2024-07-07       2        1                                                                                    */
/*   4     2024-07-17       2        0                                                                                    */
/*   4     2024-07-17       2        0                                                                                    */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                        _
|___ \   ___  __ _ ___    __| | _____      __
  __) | / __|/ _` / __|  / _` |/ _ \ \ /\ / /
 / __/  \__ \ (_| \__ \ | (_| | (_) \ V  V /
|_____| |___/\__,_|___/  \__,_|\___/ \_/\_/

*/

/*----
  First loop identifiesl the du groups with diff results.
  The second creates the flag when matching the dup group
----*/

data want;
 retain tot 0;
 do until(last.dt);
   set sd1.have;
   by id dt;
   diff=dif(result);
   if first.dt then tot=0;
   else tot = sum(tot, (abs(diff ne 0)));
   if last.dt and tot>0 then do;
     savdt=dt;
     savid=id;
   end;
 end;
 do until(last.dt);
   set sd1.have;
   by id dt;
   if savdt=dt and savid=id then flag=1;
   else flag=0;
   keep id dt result flag;
   output;
 end;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  ID        DT        RESULT    FLAG                                                                                    */
/*                                                                                                                        */
/*  1     2024-04-27       1        0                                                                                     */
/*  1     2024-04-27       1        0                                                                                     */
/*  1     2024-04-30       2        0                                                                                     */
/*  1     2024-04-30       2        0                                                                                     */
/*  2     2024-05-05       1        1                                                                                     */
/*  2     2024-05-05       2        1                                                                                     */
/*  3     2024-06-06       1        0                                                                                     */
/*  3     2024-06-06       1        0                                                                                     */
/*  4     2024-07-07       1        1                                                                                     */
/*  4     2024-07-07       2        1                                                                                     */
/*  4     2024-07-17       2        0                                                                                     */
/*  4     2024-07-17       2        0                                                                                     */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____                    _
|___ /   _ __   ___  __ _| |
  |_ \  | `__| / __|/ _` | |
 ___) | | |    \__ \ (_| | |
|____/  |_|    |___/\__, |_|
                       |_|
*/

/*----
  Basically the same as sas sql.
  The use of with instead od nesting
  has the advantage of using the
  with claus with multiple
  down stream select
----*/

proc datasets lib=sd1 nolist nodetails;
 delete want;
run;quit;

%utl_rbeginx;
parmcards4;
library(sqldf)
library(haven)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
print(have)
want<-sqldf('
  with
     dif as (
  select
     id
    ,dt
    ,result
    ,(count(distinct result) > 1) as flag
  from
    have
  group
    by id, dt
  having
    count(distinct result) > 1 )
  select
      l.ID
     ,l.DT
     ,l.RESULT
     ,coalesce(r.flag,0) as flag
  from
    have as l left join dif as r
  on
         l.id = r.id
     and l.dt = r.dt
  ')
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;

/**************************************************************************************************************************/
/*                                |                                                                                       */
/* R                              | SAS                                                                                   */
/*                                |                                                                                       */
/*   ID         DT RESULT FLAG    | ROWNAMES    ID        DT        RESULT    FLAG                                        */
/*                                |                                                                                       */
/*    1 2024-04-27      1    0    |     1       1     2024-04-27       1        0                                         */
/*    1 2024-04-27      1    0    |     2       1     2024-04-27       1        0                                         */
/*    1 2024-04-30      2    0    |     3       1     2024-04-30       2        0                                         */
/*    1 2024-04-30      2    0    |     4       1     2024-04-30       2        0                                         */
/*    2 2024-05-05      1    1    |     5       2     2024-05-05       1        1                                         */
/*    2 2024-05-05      2    1    |     6       2     2024-05-05       2        1                                         */
/*    3 2024-06-06      1    0    |     7       3     2024-06-06       1        0                                         */
/*    3 2024-06-06      1    0    |     8       3     2024-06-06       1        0                                         */
/*    4 2024-07-07      1    1    |     9       4     2024-07-07       1        1                                         */
/*    4 2024-07-07      2    1    |    10       4     2024-07-07       2        1                                         */
/*    4 2024-07-17      2    0    |    11       4     2024-07-17       2        0                                         */
/*    4 2024-07-17      2    0    |    12       4     2024-07-17       2        0                                         */
/*                                |                                                                                       */
/**************************************************************************************************************************/

/*  _                 _   _                             _
| || |    _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
| || |_  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
|__   _| | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
   |_|   | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
         |_|    |___/                                |_|
*/

/*----
  Exactly the same code ad R
  Just paste it in
----*/

proc datasets lib=sd1 nolist nodetails;
 delete pywant;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
have,meta = ps.read_sas7bdat('d:/sd1/have.sas7bdat');
want=pdsql('''
  with
     dif as (
  select
     id
    ,dt
    ,result
    ,(count(distinct result) > 1) as flag
  from
    have
  group
    by id, dt
  having
    count(distinct result) > 1 )
  select
      l.ID
     ,l.DT
     ,l.RESULT
     ,coalesce(r.flag,0) as flag
  from
    have as l left join dif as r
  on
         l.id = r.id
     and l.dt = r.dt
   ''');
print(want);
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx;

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/*                                         |                                                                              */
/*  PYTHON                                 | SAS                                                                          */
/*                                         |                                                                              */
/*     ID          DT  RESULT  FLAG        | ID        DT        RESULT    FLAG                                           */
/*                                         |                                                                              */
/*  0   1  2024-04-27     1.0     0        | 1     2024-04-27       1        0                                            */
/*  1   1  2024-04-27     1.0     0        | 1     2024-04-27       1        0                                            */
/*  2   1  2024-04-30     2.0     0        | 1     2024-04-30       2        0                                            */
/*  3   1  2024-04-30     2.0     0        | 1     2024-04-30       2        0                                            */
/*  4   2  2024-05-05     1.0     1        | 2     2024-05-05       1        1                                            */
/*  5   2  2024-05-05     2.0     1        | 2     2024-05-05       2        1                                            */
/*  6   3  2024-06-06     1.0     0        | 3     2024-06-06       1        0                                            */
/*  7   3  2024-06-06     1.0     0        | 3     2024-06-06       1        0                                            */
/*  8   4  2024-07-07     1.0     1        | 4     2024-07-07       1        1                                            */
/*  9   4  2024-07-07     2.0     1        | 4     2024-07-07       2        1                                            */
/*  10  4  2024-07-17     2.0     0        | 4     2024-07-17       2        0                                            */
/*  11  4  2024-07-17     2.0     0        | 4     2024-07-17       2        0                                            */
/*                                         |                                                                              */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/

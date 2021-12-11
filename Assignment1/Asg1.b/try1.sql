#################### query 1 ####################################################3

question 1 - Find the total number of components in G. Output column: count


################# view1 ####################


create view mfl as                
select userid1,userid2
from friendlist
union
select userid2,userid1
from friendlist;

################# view2 ####################

create view amfl as                 
with recursive grp (userid1,userid2) as
(
select userid1,userid2
from mfl
union
select grp.userid1,mfl.userid2
from grp,mfl
where grp.userid2=mfl.userid1
)
select * from grp
where userid1 < userid2;

##########3#########33 view6 #################3


create view countelement as
select count(distinct(userid1)) as count
from mfl;



################# ans1 ####################


with t1
as
(
select userid2 
from amfl
except
select userid1
from amfl
),
t2 as
(
select count(*) as cnt1
from
(
select count(*)
from amfl,t1
where
amfl.userid2=t1.userid2
group by amfl.userid2
) as r1),
t3 as
(
select count(*) as cnt2
from
(
select userid
from userdetails
except
select userid1
from mfl 
) as r2
)
select (cnt1+cnt2) as count
from t2,t3;

 count 
-------
     3
(1 row)


#################### query 2 ####################################################3



question 2- Give the number of users in each component of G. Order by ascending order of number of users. Since
output will be a single column, ties don’t matter. Output column: count


with t1
as
(
select userid2 
from amfl
except
select userid1
from amfl
),
t2 as
(
select count(*)+1 as count
from amfl,t1
where
amfl.userid2=t1.userid2
group by amfl.userid2
),
t3 as
(
select count(*) as count
from
(
select userid
from userdetails
except
select userid1
from mfl
) as r1
group by userid
),
t4 as
(
select count
from t2
union 
select count
from t3
)
select count
from t4
order by count;


count 
-------
     1
     4
     5
(3 rows)


#################### query 3 ####################################################3



question 3 -  Give the user id of the user that has blocked the most number of people in the same component. In case
of ties, list all of them and order by ascending order of user id. We DO NOT mean "component-wise
maximas", instead, we "global maximas". To clarify the query further, define b(a) = |{u : (a, u) ∈ block
or (u, a) ∈ block and C(a) = C(u)}|, where C(a) denotes component of node a and |.| denotes
cardinality of the set. Define B = {b(a) : a ∈ userdetails.userid}. You need to list all the users
u such that b(u) = max(B). Since count will be the same for all, you just need to order according to
userid. Output columns: userid, count

################# view3 ####################

create view amfl1 as                 
with recursive grp (userid1,userid2) as
(
select userid1,userid2
from mfl
union
select grp.userid1,mfl.userid2
from grp,mfl
where grp.userid2=mfl.userid1
)
select * from grp
where userid1 != userid2;


################# view4 ####################

create view bl as                
select userid1,userid2
from block
union
select userid2,userid1
from block;

################# ans3 ####################

with t1(userid,count) as
(
select b1.userid1,count(*) as count
from bl as b1
where b1.userid2 in
(
select userid2
from amfl1
where 
amfl1.userid1=b1.userid1
)
group by b1.userid1
order by count desc
),
t2 as
(
select max(t1.count) as count
from t1 
)
select t1.userid as userid,
t1.count as count 
from
t1,t2
where 
t1.count=t2.count; 


 userid | count 
--------+-------
      2 |     2
(1 row)


#################### query 4 ####################################################3


question 4- Given two user ids userid1 and userid2, find the length of shortest path from userid1 to userid2
in the graph G. If they are not in the same component, output −1. If both are already friends, output
1. If the shortest path goes like: userid1 → a 1 → a 2 → · · · → a n → userid2, output n + 1. Output
column: length. Take userid1 = 1558, userid2 = 2826.




with recursive reqtab(userid1,userid2,length)
as
(
 select userid1,userid2,1 as length
 from mfl
 union all
 select mfl.userid1,reqtab.userid2,reqtab.length+1
 from mfl,reqtab
 where
 mfl.userid2=reqtab.userid1
 and mfl.userid1 <> reqtab.userid2
 and reqtab.length < (select count from countelement)
)
select min(length) as length from reqtab
where
userid2=2
and userid1=5
and length is not null
having count(*) !=0
union
select -1 as length
from
(
select count(*) as count
from amfl
where userid1=2 and userid2=5
) as t3
where count=0;



#################### query 5 ####################################################


question -5- Just like Facebook, in our platform too, you can’t send someone a friend request if you’ve blocked
them. Find the maximum number of friend requests user1 can send to users belonging to the same
component as him/her. Output column: count. Take user1 = 704

select count(*) as count
from
(
select userid2 
from amfl1
where userid1=8 
except
select userid2
from
(
select userid2
from bl
where userid1=8
union
select userid2
from mfl
where userid1=8
)
as t1
) as t2;


 count 
-------
     1
(1 row)


#################### query 6 ####################################################


question -6- We define "potential number of friends of a person A" as people who live in the same city as person
A, are not in the same component as A, who aren’t friends with A, and aren’t blocked by A. Give the
user ids of top 10 people with most number of potential friends. Sort in descending order of potential
friends and resolve all ties by ascending order of user ids. Output column: userid


########### view 5 ####################

create view nscomp as 
select us1.userid as userid1,
us2.userid as userid2
from userdetails as us1,
userdetails as us2
where 
us1.userid != us2.userid
except
select userid1,userid2
from amfl1;

########### ans 6 ####################


with t1 as
(
select userid1,userid2
from nscomp
except
select userid1,userid2
from bl
order by userid1,userid2
),
t2 as
(
select t1.userid1 as userid1,
t1.userid2 as userid2,
userdetails.place as place1
from t1,userdetails
where  t1.userid1=userdetails.userid
)
select t2.userid1 as userid1
from t2,userdetails
where userdetails.userid=t2.userid2
and t2.place1=userdetails.place
group by t2.userid1
order by count(*) desc,userid1
limit 10;

 userid1 
---------
       5
       8
       9
(3 rows)


#################### query 7 ####################################################



question - 7-  Saul might know a guy, who knows a guy, who knows another guy, but he might not be the person with
highest number of third degree connections. Person A’s third degree connections are people connected
to him with shortest path length of 3 in graph G. Give the user ids of top 10 users with the most
number of third degree connections. Sort in descending order of connections and resolve all ties by
ascending order of user ids. Output column: userid

with recursive reqtab(userid1,userid2,length)
as
(
 select userid1,userid2,1 as length
 from mfl
 union all
 select mfl.userid1,reqtab.userid2,reqtab.length+1
 from mfl,reqtab
 where
 mfl.userid2=reqtab.userid1
 and mfl.userid1 <> reqtab.userid2
 and reqtab.length < (select count from countelement)
),
t1 as
(
select userid1,userid2,min(length) as length
from reqtab
where length <= 3
group by userid1,userid2
order by userid1,userid2
)
select userid from
(
select userid1 as userid,count(*) as count
from t1
where length=3
group by userid1
order by count(*) desc,userid1
limit 10
) as t2;



#################### query 8 ####################################################

Question - 8 - Given 3 userids A, B and C, give the number of paths that exist between A and C that also pass
through B. Note that A → a 1 → B → a 2 → C and A → a 1 → B → a 3 → C constitute two distinct
paths in graph G, that is, in path from A to C (via B), if even a single node is different (may be in
A→B part or in B→C part), then it counts as a different path. All the vertices in the path A → C
should be distinct, that is, a path like A → · · · a 1 → · · · B → · · · a 1 → · · · C is not valid. Return -1 if
they don’t belong to the same component. Output column: count. Take A = 3552, B = 321,
C = 1436





with recursive reqtab(userid1,userid2,pathlist)
as
(
 select userid1,userid2,Array[userid1,userid2] as pathlist
 from mfl
 union all
 select reqtab.userid1,mfl.userid2,reqtab.pathlist||mfl.userid2 as pathlist
 from mfl,reqtab
 where
 reqtab.userid2=mfl.userid1
 and reqtab.userid1 != mfl.userid2
 and not mfl.userid2 = any(reqtab.pathlist)
 and array_length(pathlist,1) <= (select count from countelement)
)
select count(*) as count
from reqtab
where pathlist[1]=2
and pathlist[array_length(pathlist,1)]=5
and 1 = any(reqtab.pathlist)
having count(*) !=0
union
select -1 as count
from 
(
select count(*) as count
from
(
select userid1,userid2
from amfl1
where 
userid1=2 and userid2=1
union
select userid1,userid2
from amfl1
where 
userid1=1 and userid2=5
union
select userid1,userid2
from amfl1
where 
userid1=2 and userid2=5
) as t1
) as t2 where count <3 ;

 count 
-------
     2
(1 row)


#################### query 9 ####################################################


Question -9 - Find the number of paths in Graph G from user A to B such that adjacent people in the path aren’t
from the same city. Return -1 if they don’t belong to the same component, else return number of paths.
Output column: count. Take A = 3552, B = 321

##########3#########33 view9 #################3 

create view mflplace as
with t1 as
(
select mfl.userid1 as userid1,
mfl.userid2 as userid2,
userdetails.place as place1
from
mfl,userdetails
where
userdetails.userid=mfl.userid1
)
select t1.userid1 as userid1,
t1.userid2 as userid2,
t1.place1 as place1,
userdetails.place as place2
from 
t1,userdetails
where
t1.userid2=userdetails.userid
order by userid1,userid2;


##########3#########33 view10 #################


create view mflplace1 as
with t1 as
(
select mfl.userid1 as userid1,
mfl.userid2 as userid2,
userdetails.place as place1
from
mfl,userdetails
where
userdetails.userid=mfl.userid1
)
select t1.userid1 as userid1,
t1.userid2 as userid2,
t1.place1 as place1,
userdetails.place as place2
from 
t1,userdetails
where
t1.userid2=userdetails.userid
and t1.place1 != userdetails.place
order by userid1,userid2;


##########3#########33 ans 9 #################


with recursive reqtab (userid1,userid2,userlist,placelist)
as
(
select userid1,userid2,Array[userid1,userid2] as userlist,
Array[place1,place2] as placelist
from mflplace1
union all
select reqtab.userid1 as userid1,
mflplace1.userid2 as userid2,
reqtab.userlist||mflplace1.userid2 as userlist,
reqtab.placelist||mflplace1.place2 as placelist
from 
reqtab,mflplace1
where
reqtab.userid2=mflplace1.userid1
and not mflplace1.userid2 = any(reqtab.userlist)
and reqtab.placelist[array_length(reqtab.placelist,1)] != mflplace1.place2
and array_length(userlist,1) <= (select count from countelement)
and array_length(placelist,1) <= (select count from countelement)
)
select count(*) as count from reqtab
where userid1=2 
and userid2=5;

 count 
-------
     1
(1 row)


#################### query 10 ####################################################


question -10- Find the number of paths in Graph G from user A to B, (A, B) ∈
/ block, such that any person in the
path shouldn’t be blocked by any other person in that path. Return -1 if they don’t belong to the same
component, else return number of paths. Output column: count. Take A = 3552, B = 321

############# view 11 ###################

create view userbl as 
with t1
as
(
select bl.userid1 as userid,
array_agg(bl.userid2) as blocklist
from
userdetails,bl
where
userdetails.userid=bl.userid1
group by bl.userid1
order by bl.userid1
)
select userid,Array[]::integer[] as blocklist
from
(
select userid  
from userdetails
except
select userid
from t1
) as t2
union 
select userid,blocklist 
from t1
order by userid;


############# view 12 ###################


create view mflblock as
with t1 
as
(
select mfl.userid1 as userid1,
mfl.userid2 as userid2,
userbl.blocklist as blocklist1
from
mfl,userbl
where
mfl.userid1=userbl.userid
order by mfl.userid1
)
select t1.userid1 as userid1,
t1.userid2 as userid2,
t1.blocklist1 as blocklist1,
userbl.blocklist as blocklist2
from
t1,userbl
where t1.userid2=userbl.userid
order by userid1,userid2;

############# ans 10 ###################



with recursive reqtab(userid1,userid2,userlist,blocklist1,blocklist2) as
(
select userid1,userid2,Array[userid1,userid2] as userlist,
blocklist1,blocklist2
from mflblock
union all
select reqtab.userid1,mflblock.userid2,
reqtab.userlist||mflblock.userid2 as userlist,
reqtab.blocklist1 as blocklist1,
mflblock.blocklist2 as blocklist2
from reqtab,mflblock
where
reqtab.userid2=mflblock.userid1
and not mflblock.userid2 = any(reqtab.userlist)
and (reqtab.userlist && mflblock.blocklist2)=false
and array_length(reqtab.userlist,1) <= (select count from countelement) 
)
select case
when
(select count(*) as count
from amfl1
where userid1=2 and userid2=5)=0
then -1
else
(
select count(*) as count
from reqtab
where userid1 =2
and userid2 =5
)
end;



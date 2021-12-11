Query 1 - List all the names and count of badges that have be given to atleast 10,000 people, sorted in descending
order of their counts. Break ties by ascending order of badge name. Columns: name, number

# have to edit

select badges.name,count(users.Id) as number
from badges,users
where badges.UserId = users.Id
group by name having count(users.Id)>=10000
order by count(Users.Id) desc,name asc;

Timing - 749.110 ms

Output -

 name       | count  
------------------+--------
 Student          | 134134
 Scholar          | 106360
 Teacher          | 101241
 Editor           |  96917
 Popular Question |  92927
 Supporter        |  87208
 Nice Answer      |  75667
 Commentator      |  48618
 Tumbleweed       |  39991
 Yearling         |  36176
 Autobiographer   |  33498
 Critic           |  33256
 Notable Question |  30300
 Nice Question    |  20750
 Enlightened      |  16518
 Organizer        |  15055
 Good Answer      |  12554
 Enthusiast       |  10614
(18 rows)


################################# Query2 ###########################333

Query 2 - List the top 5 users (userid and displayname) with the maximum number of comments across all posts.
Resolve ties by alphabetic ordering of username. Columns: userid, displayname



select users.Id as userid,users.displayname as displayname
from users,comments
where users.Id = comments.UserId
group by users.Id,users.displayname
order by count(*) desc,users.displayname asc
limit 5;


   id   |  displayname  
--------+---------------
  22656 | Jon Skeet
 187606 | Pekka 웃
  10661 | S.Lott
  76337 | John Saunders
  13249 | Nick Craver
(5 rows)


Time: 6486.748 ms (00:06.487)


######################## Query 3 #######################################################3

Query 3 - List users that earned maximum badges in each month of 2010. Break ties using lexicographic ordering
of user names. There should be exactly 12 rows in output, one for each month. Order by ascending
month. (Here month will be a number between 1-12) Columns: month,userid.

with cntbadges as 
(
select badges.UserId,users.displayname,extract(month from date) as month1,count(*) as count1 
from badges,users
where badges.UserId = users.Id and extract(year from date)=2010
group by badges.UserId,month1,users.displayname
order by month1 asc,count1 desc,users.displayname asc
),
maxbadges as 
(
select month1,max(count1) from cntbadges
group by month1 
order by month1 asc
)
select cntbadges.month1 as month,cntbadges.userid as userid from maxbadges,cntbadges 
where cntbadges.month1 = maxbadges.month1
and cntbadges.count1 = maxbadges.max;

Rows - 12

Time: 3827.252 ms (00:03.827)


############################## 	Query 4 #####################################

Query 4 :- List post ids whose title contain more than 100 characters. Output (post id and number of characters)
in decreasing order of this number, while breaking ties using post ids in ascending order. Columns:
postid, charcount

select posts.id as postid, length(title) as charcount
from posts
where length(title) > 100
order by charcount desc,posts.id asc;

Time: 5054.569 ms (00:05.055)


Rows - 9935

############################## 	Query 5 #####################################


Query 5 :- List the first 5 column names of the posts table that occur in ascending order. Columns: postcolumn

select postcolumn 
from 
(
SELECT column_name as postcolumn 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'posts'
limit 5
) as coltable
order by postcolumn asc;


    postcolumn    
------------------
 acceptedanswerid
 answercount
 closeddate
 commentcount
 id
(5 rows)

Time: 195.145 ms


############################## 	Query 6 #####################################

Query 6 - Give the title of the top 5 posts which have the maximum number of linked posts (Assume only related
post Id and not Id). Break ties by alphabetic ordering of titles. Order by descending order of number
of links. Columns: title, count


select posts.title as title,tabobt.count1 as count 
from posts,
(select postid,count(*) as count1 from postlinks
group by postid
order by count1 desc) as tabobt
where posts.id = tabobt.postid
order by tabobt.count1 desc,posts.title asc
limit 5;



                                       title                                       | count1 
-----------------------------------------------------------------------------------+--------
 Hidden Features of C#?                                                            |     24
 Yeah.. I know.. I'm a simpleton.. So what's a Singleton?                          |     14
 What are your favorite extension methods for C#? (codeplex.com/extensionoverflow) |     13
 Database development mistakes made by application developers                      |     12
 What''s your most controversial programming opinion?                               |     12
(5 rows)

Time: 3459.360 ms (00:03.459)


############################## 	Query 7 #####################################


Query 7 - Which user names have created more than one post in any 24-hour interval? List user names in
lexicographic order. Here, 24-hour interval means the timestamp value differs by not more than 24-
hours Columns: displayname




with mposts as 
(
select id,
owneruserid,
creationdate
from posts
),
postusers as
(
select distinct(mpt1.owneruserid) as owner
from 
mposts as mpt1,mposts as mpt2
where mpt1.owneruserid=mpt2.owneruserid
and age(mpt1.creationdate,mpt2.creationdate) <='24 hours'
and mpt1.creationdate > mpt2.creationdate
),
requser as
(
select distinct(id) as reqid
from users,postusers
where id=owner
)
select displayname
from users,requser
where 
id=reqid
order by displayname

time - 368030.532 ms (06:08.031)

Rows - 67951


############################## 	Query 8 #####################################

Query 8 - List top 3 user names that have offered the most bounty amount (concerns only with bounty start and
not bounty close). Break ties using lexicographic ordering of user names. Columns: displayname



select users.displayname as displayname from users,
(
select userid,sum(bountyamount) as sumbt
from votes
where userid is not null and bountyamount is not null and votetypeid = 8
group by userid
) as votbounty
where votbounty.userid = users.id 
order by votbounty.sumbt desc,users.displayname asc
limit 3;


 displayname 
-------------
 leora
 Community
 Pekka 웃
(3 rows)

Time: 7489.790 ms (00:07.490)


############################## 	Query 9 #####################################

with badgeuser as
(
select userid,count(*) as bgcnt 
from badges
group by userid
having count(*) >=10
),
postuser as (select lasteditoruserid,count(*) as cntr
from posts,badgeuser
where lasteditoruserid = badgeuser.userid              
group by lasteditoruserid
order by cntr desc
limit 5)
select displayname              
from users,postuser where users.id = postuser.lasteditoruserid
order by postuser.cntr desc,displayname asc;


   displayname   
-----------------
 Peter Mortensen
 skaffman
 John Saunders
 marc_s
 Joel Coehoorn
(5 rows)

Time: 2468.977 ms (00:02.469)





############################## 	Query 10 #####################################

Query 10 - List the user for every month of every year with maximum absolute difference between questions asked
and questions answered in that month. Break ties with lexicographic ordering of user name. Output
(user id) for each month. Columns: year, month, userid


with quser as
(
select extract(year from creationdate) as yr,
extract(month from creationdate) as mth,
owneruserid,
count(*) as qcnt
from posts
where posttypeid=1
group by mth,yr,owneruserid
),
auser as
(
select extract(year from creationdate) as yr,
extract(month from creationdate) as mth,
owneruserid,
count(*) as acnt
from posts
where posttypeid=2
group by mth,yr,owneruserid
),
reqtab as
(
select quser.yr as qyr,
quser.mth as qmth,
quser.owneruserid as quid,
quser.qcnt as qcnt,
auser.yr as ayr,
auser.mth as amth,
auser.owneruserid as auid,
auser.acnt as acnt
from 
quser FULL OUTER JOIN auser
on 
(quser.yr = auser.yr
and quser.mth = auser.mth
and quser.owneruserid=auser.owneruserid
)
),
maintab as
(
select 
case when qyr is not null then qyr
     when ayr is not null then ayr
          end as year,
case when qmth is not null then qmth
     when amth is not null then amth
          end as month,
case when quid is not null then quid
     when auid is not null then auid
          end as userid,
case when acnt is not null then acnt
          else 0
          end as answercnt,
case when qcnt is not null then qcnt
          else 0
          end as questioncnt
from reqtab
),
abmain as
(
select year,month,userid,
abs(answercnt-questioncnt) as cnt
from maintab
),
abmain1 as
(
select year,month,userid,cnt,
displayname from
abmain,users
where  userid=id
),
bestab as
(
select year,month,max(cnt) as maxcnt
from abmain1
group by year,month
),
mnth as
(
select abmain1.year as year,
abmain1.month as month,
abmain1.userid as userid,
abmain1.displayname
from bestab,abmain1
where abmain1.year = bestab.year
and abmain1.month = bestab.month
and abmain1.cnt = bestab.maxcnt
order by year,month,displayname
)
select year,month,userid
from
(
select *,ROW_NUMBER() OVER (PARTITION BY
          year,month order by displayname asc) as Row_ID from mnth
) as lastab
where Row_ID < 2 order by year,month




year | month | userid 
------+-------+--------
 2008 |     7 |      8
 2008 |     8 |    905
 2008 |     9 |   1196
 2008 |    10 |  22656
 2008 |    11 |  22656
 2008 |    12 |  22656
 2009 |     1 |  22656
 2009 |     2 |  22656
 2009 |     3 |  22656
 2009 |     4 |  22656
 2009 |     5 |  23354
 2009 |     6 |  22656
 2009 |     7 |  76337
 2009 |     8 | 154152
 2009 |     9 |  22656
 2009 |    10 |  22656
 2009 |    11 | 157882
 2009 |    12 | 157882
 2010 |     1 |  20862
 2010 |     2 |  20862
 2010 |     3 |  13249


Time: 7341.946 ms (00:07.342)





############################## 	Query 11 #####################################


Query 11 - List the average view count for questions per tag. Display the tag name and the average view count.
Sort by tag name in ascending alphabetic order. Columns: tags, viewcount

select tags,avg(viewcount) as viewcount
from posts
where posttypeid=1 
group by tags
order by tags asc

Time: 3840.828 ms (00:03.841)


(319717 rows)




############################## 	Query 12 #####################################

Query 12 - List the top 10 tags with most unanswered questions. Break ties with tag-post count and if still ties
exist, use lexicographic ordering of tag name. Columns: tags, number


select tags,count(*) as number
from posts 
where posts.posttypeid=1
and answercount=0
group by tags
order by number desc,tags asc
limit 10;

      tags       | number 
-----------------+--------
 <android>       |     93
 <iphone>        |     37
 <asp.net>       |     17
 <c#>            |     15
 <javascript>    |     10
 <jquery>        |     10
 <nhibernate>    |      9
 <ruby-on-rails> |      8
 <c#><wpf>       |      7
 <git>           |      7
(10 rows)

Time: 359.083 ms

############################## 	Query 13 #####################################


13. List users (user names) that wrote more than one answer for a single post within 24 hours (Creation-
Date) (time of last answer - first answer <= 24 hours), with one of the answers being an accepted
answer. Columns: displayname


with answer as
(
select pt1.id as ans1,
pt2.id as ans2,
pt1.owneruserid as writer1,
pt1.parentid as qtn,
pt1.creationdate as canst1,
pt2.creationdate as canst2
from 
posts as pt1,posts as pt2
where 
pt1.posttypeid=2
and pt2.posttypeid=2
and pt1.parentid=pt2.parentid
and pt1.owneruserid=pt2.owneruserid
and age(pt1.creationdate,pt2.creationdate) <='24 hours'
and age(pt1.creationdate,pt2.creationdate) >'0 day 00:00:00.00'
),
qanswer as
(
select writer1,
id as qtnid,
ans1,ans2
from answer,posts
where 
id=qtn
and (acceptedanswerid=ans1 or acceptedanswerid=ans2)
),
writuser as
(
select distinct(writer1) as writid
from qanswer
)
select displayname
from
writuser,users
where id=writid

Rows - 1452

Time: 6574.777 ms (00:06.575)


############################## 	Query 14 #####################################

Query 14 - List the Top 10 users, who have earned maximum badges, sorted in descending order of total badges.
Columns: userid, totalbadges.


select userid,count(*) as totalbadges
 from badges
 group by userid 
 order by totalbadges desc
 limit 10;

 userid | totalbadges 
--------+-------------
  22656 |        2821
  23354 |         916
  23283 |         707
    893 |         654
  33708 |         631
  18393 |         614
  34509 |         537
  95810 |         533
   1968 |         525
  14860 |         521
(10 rows)

Time: 1318.833 ms (00:01.319)


############################## 	Query 15 #####################################

Query 15 - Which day of the week has the most unanswered questions with atleast 10 views posted on it?
Columns: day -> text

select to_char(CreationDate,'day') as day
from posts
where posttypeid=1
and answercount=0
and viewcount>=10
group by day
order by count(*) desc
limit 1;


    day    
-----------
 wednesday
(1 row)

Time: 282.011 ms



############################## 	Query 16 #####################################

Query 16 - Which posts have the highest votes (Upvote or downvote) to views ratio (With atleast 1 view)? List
the top 10, along with the ratio. Order by decreasing ratio. Columns: postid, ratio. Here ratio will
be a floating point number, so please round to 2 decimal places at all places of calculation.


with votpost as
(
select postid,count(*) as votecount
from votes 
where votetypeid =2 or votetypeid = 3
group by postid
)
select id as postid,(votpost.votecount::NUMERIC/viewcount) as ratio
from posts,votpost
 where viewcount >=1
and votpost.postid = posts.id
order by ratio desc,postid asc
limit 10;


 postid  |         ratio          
---------+------------------------
 1335319 | 0.13513513513513513514
 3876965 | 0.13043478260869565217
 3410556 | 0.12903225806451612903
 4180108 | 0.10769230769230769231
 3581805 | 0.10714285714285714286
 4049797 | 0.10714285714285714286
 4540986 | 0.10344827586206896552
 4318811 | 0.10256410256410256410
 2898172 | 0.10101010101010101010
 2517206 | 0.09090909090909090909
(10 rows)

Time: 12287.001 ms (00:12.287)


##############################  Query 17 #####################################


Query - 17 - Give the username of the top 3 people who have received the max total comments score on a single post
across all comments made by them. Break ties in ascending alphabetical order of names. Columns:
displayname


with commentuser as
(
select userid,postid,sum(score) as sumn
from comments
group by userid,postid
)
select displayname 
from users,commentuser
where users.id=commentuser.userid
order by commentuser.sumn desc,displayname asc
limit 3;


      displayname       
------------------------
 Khodor
 SadSido
 Mr. Shiny and New 安宇
(3 rows)

Time: 10573.820 ms (00:10.574)


##############################  Query 18 #####################################


Query - 18 - Which old users (user account was created in 2008 and atleast 10 accepted answers) are not active any
more (no login in 2010)? List (user name, number of accepted answers) in decreasing order of number
of accepted answers. Break ties with lexicographic ordering of user names. Columns: displayname,
number

 with tpuser as
 (
 select id as tuserid,displayname as tdisname
 from users
 where id is not null
 and extract(year from CreationDate)=2008
 and ( extract(year from lastaccessdate)=2008
 or extract(year from lastaccessdate)=2009 )
 and lastaccessdate >= CreationDate
 ),
 qtnpost as
 (
 select id as qid,acceptedanswerid as acansid
 from posts 
 where id is not null
 and posttypeid=1
 and answercount > 0
 ),
 qansuser as
 (
 select qid,id as ansid,owneruserid
 from posts,qtnpost
 where id is not null
 and acansid = id
 and posttypeid=2
 and parentid=qid
 ),
 qweruser as
 (
 select owneruserid,count(*) as cntr
 from qansuser
 group by owneruserid
 having count(*)>=10
 )
 select tdisname as displayname,qweruser.cntr as number
 from qweruser,tpuser
 where qweruser.owneruserid=tpuser.tuserid
 order by qweruser.cntr desc,tdisname asc;


 displayname | number 
-------------+--------
 Dave        |     29
 jezell      |     11
(2 rows)

Time: 2335.726 ms (00:02.336)


##############################  Query 19 #####################################


List the post (postid) that has maximum effective upvotes but is still unanswered. Effective upvotes =
Total upvotes - Total downvotes. Columns: postid, effectiveupvotes Hint: Upvotes correspond to
voteTypeId of 2 and Downvotes correspond to a voteTypeId of 3. Please ignore all other voteTypeIds


with question as
(
select id 
from posts
where id is not null
and answercount=0
and posttypeid=1
),
upqn as
(
select postid,count(*) as upcntr
from votes 
where postid in (select question.id from question)
and votetypeid=2
group by postid
),
downqn as
(
select postid,count(*) as dncntr
from votes 
where postid in (select question.id from question)
and votetypeid=3
group by postid
),
bothab as
(
select upqn.postid as upid,
downqn.postid as dnid,
upqn.upcntr as upcnt,
downqn.dncntr as dncnt
from 
upqn FULL OUTER JOIN downqn 
on downqn.postid=upqn.postid
),
maintab as
(
select 
case when upid is not null then upid
     when dnid is not null then dnid
     end as qid,
case when upcnt is not null then upcnt 
     else 0
     end as upvote,
case when dncnt is not null then dncnt
     else 0
     end as downvote
from bothab
)
select maintab.qid as postid,
(upvote-downvote) as effectiveupvotes
from maintab
order by effectiveupvotes desc
limit 1;

 postid | effectiveupvotes 
--------+------------------
 454303 |               63
(1 row)

Time: 3569.988 ms (00:03.570)


##############################  Query 20 #####################################


Query 20 - List users that have at least 100 badges such that they have at least one post with a view count higher
than their profile view count (post may be question or answer only). Output in decreasing order of the
difference of views. Break ties with lexicographic ordering of user name. Columns: userid, viewdiff

with badguser as
(
select userid,count(*) as cnt
from badges
group by userid
having count(*)>=100
),
postuser as
(
select id,owneruserid,viewcount as postviewcount
from posts
where (posttypeid=1 or posttypeid=2)
and viewcount>=1
and id is not null
and owneruserid in (select badguser.userid from badguser)
)
select users.id as userid,(postuser.postviewcount-views) as viewdiff
from postuser,users
where users.id=postuser.owneruserid
and postuser.postviewcount > views
order by viewdiff desc,displayname asc;

Rows - 4738

Time: 1658.160 ms (00:01.658)


##############################  Query 21 #####################################


Query 21 -  Find the number of average replies per question by expert askers >1000 reputation) and also the average
of new askers (<100 reputation) Columns: askertype, replies. Here askertype can be expert or
new. The output will have two rows, one for expert askers and one for new askers.


with expert as
 (
 select id 
 from users
 where reputation > 1000
 ),
 reptoexpert as
 (
 select ('expert') as askertype,round(avg(answercount)::NUMERIC,2) as replies
 from posts
 where owneruserid in (select id from expert)
 and posttypeid=1
 ),
 new as
 (
 select id 
 from users
 where reputation < 100
 ),
 repltonew as
 (
 select ('new') as askertype,round(avg(answercount)::NUMERIC,2) as replies
 from posts
 where owneruserid in (select id from new)
 and posttypeid=1
 )
 select * from repltonew 
 union
 select * from reptoexpert;


 askertype | replies 
-----------+-------
 expert    |  3.12
 new       |  2.20
(2 rows)

Time: 1670.603 ms (00:01.671)


##############################  Query 22 #####################################


Query 22 - Find the number of lurkers (ie number of users who have never asked or answered or replied) who have
had an account for atleast 6 months. Columns: lurkercount.

 with usertime as
 (
 select id,age(lastaccessdate,creationdate) as timedif
 from users
 where  age(lastaccessdate,creationdate) >=interval '6 months'
 ),
 requser as
 (
 select id,timedif
 from usertime
 except
 select id,timedif
 from usertime
 where (extract(month from timedif)= 5
 and extract(year from timedif)=0)
 ),
 maintab as
 (
 select id
 from requser
 except
 select owneruserid
 from posts
 )
 select count(*) as lukercount
 from maintab

 lukercount 
------------
      65693
(1 row)

Time: 1477.727 ms (00:01.478)

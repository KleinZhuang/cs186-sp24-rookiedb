-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
SELECT MAX(era)
FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
SELECT namefirst, namelast, birthyear
from people
where weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
SELECT namefirst, namelast, birthyear
from people
where namefirst like '% %'
order by namefirst asc, namelast asc
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
SELECT birthyear, avg(height) avgheight, count(1) count from people group by birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
SELECT birthyear, avg(height) avgheight, count(1) count from people group by birthyear having avg(height) > 70
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
SELECT namefirst,
       namelast,
       playerid,
       yearid
FROM (SELECT *
      FROM halloffame t1
               LEFT JOIN people t2 ON t1.playerID = t2.playerID
      WHERE inducted = 'Y'
      ORDER BY yearid DESC, playerID ASC)
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
SELECT namefirst, namelast, playerid, schoolID, yearid
from (SELECT *
      FROM (SELECT *
            FROM halloffame t1
                     LEFT JOIN people t2 ON t1.playerID = t2.playerID
            WHERE inducted = 'Y'
            ORDER BY yearid DESC, playerID ASC) t3

               INNER JOIN (SELECT playerID, schools.schoolID
                           FROM collegeplaying
                                    LEFT JOIN schools on collegeplaying.schoolID = schools.schoolID
                           WHERE state = 'CA') t4
                          on t3.playerid = t4.playerID)
ORDER BY yearID DESC, schoolID, playerID
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
SELECT playerid, namefirst, namelast, schoolID
from (SELECT *
      FROM (SELECT *
            FROM halloffame t1
                     LEFT JOIN people t2 ON t1.playerID = t2.playerID
            WHERE inducted = 'Y') t3

               LEFT JOIN (SELECT playerID, schools.schoolID
                          FROM collegeplaying
                                   LEFT JOIN schools on collegeplaying.schoolID = schools.schoolID) t4
                         on t3.playerid = t4.playerID)
ORDER BY playerID DESC, schoolID
;

-- Question 3i
-- SLG = (1B + 2x2B + 3x3B + 4xHR) / AB
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
SELECT t1.playerID, people.nameFirst, people.nameLast, t1.yearID, slg
from (SELECT yearID,
             playerID,
             teamID,
             CAST(((`H` - `2B` - `3B` - `HR`) + 2 * `2B` + 3 * `3B` + 4 * `HR`) AS REAL) / (`AB`) AS slg
      from batting
      WHERE AB > 50
      GROUP BY yearID, playerID, teamID
      ORDER BY slg DESC) t1
         LEFT JOIN people on t1.playerID = people.playerID LIMIT 10;
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
SELECT t1.playerID,
       people.nameFirst,
       people.nameLast,
       lslg
FROM (SELECT yearID,
             playerID,
             teamID,
             CAST(((sum(`H`) - sum(`2B`) - sum(`3B`) - sum(`HR`)) + 2 * sum(`2B`) + 3 * sum(`3B`) +
                   4 * sum(`HR`)) AS REAL) / sum((`AB`)) AS lslg
      FROM batting
      GROUP BY playerID
      HAVING sum(`AB`) >= 50
      ORDER BY lslg DESC) t1
         LEFT JOIN people ON t1.playerID = people.playerID LIMIT 10;
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
SELECT people.nameFirst,
       people.nameLast,
       lslg
FROM (SELECT yearID,
             playerID,
             teamID,
             CAST(((sum(`H`) - sum(`2B`) - sum(`3B`) - sum(`HR`)) + 2 * sum(`2B`) + 3 * sum(`3B`) +
                   4 * sum(`HR`)) AS REAL) / sum(`AB`) AS lslg
      FROM batting
      GROUP BY playerID
      HAVING sum(`AB`) >= 50
         and lslg > (SELECT CAST(((sum(`H`) - sum(`2B`) - sum(`3B`) - sum(`HR`)) + 2 * sum(`2B`) + 3 * sum(`3B`) +
                                  4 * sum(`HR`)) AS REAL) / sum(`AB`) AS lslg
                     from batting
                     WHERE playerID = 'mayswi01')) t1
         LEFT JOIN people ON t1.playerID = people.playerID
ORDER BY nameFirst, nameLast
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
SELECT yearID, min(salary) min, max(salary) max, AVG(salary) avg from salaries GROUP BY yearID ORDER BY yearID
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
SELECT binid,
       low,
       high,
       CASE

           WHEN binid = 9 THEN
               (SELECT COUNT(1)
        count
        FROM
        salaries t4
        WHERE
        yearID = '2016'
        AND t4.salary >= t3.low
        AND t4.salary <= t3.high
        ) ELSE (
        SELECT
        COUNT ( 1 ) count
        FROM
        salaries t4
        WHERE
        yearID = '2016'
        AND t4.salary >= t3.low
        AND t4.salary < t3.high
        )
END
AS count
FROM
	(
	SELECT
		( ROW_NUMBER( ) OVER ( ORDER BY ( SELECT NULL ) ) ) - 1 AS binid,
		t2.min + ( ROW_NUMBER( ) OVER ( ORDER BY ( SELECT NULL ) ) - 1 ) * ( ( t2.max - t2.min ) / 10 ) AS low,
		t2.min + ( ROW_NUMBER( ) OVER ( ORDER BY ( SELECT NULL ) ) ) * ( ( t2.max - t2.min ) / 10 ) AS high
	FROM
		(
		SELECT
			0 UNION ALL
		SELECT
			1 UNION ALL
		SELECT
			2 UNION ALL
		SELECT
			3 UNION ALL
		SELECT
			4 UNION ALL
		SELECT
			5 UNION ALL
		SELECT
			6 UNION ALL
		SELECT
			7 UNION ALL
		SELECT
			8 UNION ALL
		SELECT
			9
		) subquery,
	( SELECT min( salary ) min, max( salary ) max FROM salaries WHERE yearID = '2016' ) t2
	) t3
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
SELECT t1.yearID, t1.min - t2.min as mindiff, t1.max - t2.max as maxdiff, t1.avg - t2.avg as avgdiff
from (SELECT yearID,
             min(salary) min,
	MAX(salary) max,
	AVG(salary) avg,
	(yearID - 1) preYear
      FROM
          salaries
      GROUP BY
          yearID
      ORDER BY
          yearID) t1
         INNER JOIN (SELECT yearID,
                            min(salary) min,
	MAX(salary) max,
	AVG(salary) avg
                     FROM
                         salaries
                     GROUP BY
                         yearID
                     ORDER BY
                         yearID) t2 on t1.preYear = t2.yearID
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
SELECT t1.playerID, t2.nameFirst, t2.nameLast, t1.salary, t1.yearID from(
 SELECT
     playerid,
     yearID, salary
 FROM
     salaries
 WHERE
         yearid = 2000
   AND salary IN ( SELECT MAX( salary ) FROM salaries WHERE yearID = 2000 )

 UNION ALL

 SELECT
     playerid,
     yearID, salary
 FROM
     salaries
 WHERE
         yearid = 2001
   AND salary IN ( SELECT MAX( salary ) FROM salaries WHERE yearID = 2001 ) ) t1 LEFT JOIN people t2 on t1.playerid = t2.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
SELECT
    teamID, max(salary) - min(salary) diffAvg
FROM
    salaries
WHERE
        yearID = 2016
  AND playerID IN ( SELECT playerID FROM allstarfull WHERE yearID = 2016)
GROUP BY
    teamID
;


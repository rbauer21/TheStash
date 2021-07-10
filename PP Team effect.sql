

--All players viewed by PowerPlayPercent, eliminating low point scoring players and Goalies to get a better picture of the higher end players
--Looking for other trends in Power Play stats
Select Rk, Name, Team, Age, Pos, GP, P, PP, PPG, PPA, PPP,  Round(((PPP/P)* 100),2,2) as PowerPlayPercent
From stats2020_2021
Where Not Pos = 'G'
And P > 5
order by PowerPlayPercent Desc

--Looking to identify power play specialist forwards who gain a large portion of their points during power play time
--Useful for identifying players with higher than average production as a result of power play inflation
Select Rk, Name, Team, Age, Pos, GP, P, PP, PPG, PPA, PPP,  Round(((PPP/P)* 100),2,2) as PowerPlayPercent
From stats2020_2021
Where P > 5 
And Pos like 'F'
order by PowerPlayPercent Desc

--Identifying defencemen who can effectively coordinate a power play at the higher end over powerplay percent
--Identifies defencemen with good point production at even strengh when viewed from the lower end of PP time
Select Rk, Name, Team, Age, Pos, GP, P, PP, PPG, PPA, PPP, Round(((PPP/P)* 100),2,2) as PowerPlayPercent
From stats2020_2021
Where PPP > 5 
And Pos like 'D'
order by PowerPlayPercent Desc;

--The Edmonton Oilers have the top 2 point scorers in the nhl during the 2020 2021 season
--They also hold a considerable lead in powerplay points

Select Rk, Name, Team, Age, Pos, GP, P, PP, PPG, PPA, PPP, Round(((PPP/P)* 100),2,2) as PowerPlayPercent
From stats2020_2021
Where Not Pos = 'G'
And Team = 'EDM'
And P > 1
order by PowerPlayPercent desc

--The Colorado Avalanche represent a team with a strong powerplay that does not necessarily inflate the totals of auxilury players on the unit

Select Rk, Name, Team, Age, Pos, GP, P, PP, PPG, PPA, PPP, Round(((PPP/P)* 100),2,2) as PowerPlayPercent
From stats2020_2021
Where Not Pos = 'G'
And Team = 'COL'
And P > 1
order by PowerPlayPercent desc
;

Select Name, Team, Age, Pos, GP, P, PP, PPG, PPA, PPP
From stats2019_2020 
Where Not Pos = 'G'
and P > 5
Order by Team	

Select Name, Team, Age, Pos, GP, P, PP, PPG, PPA, PPP
From stats2020_2021 
Where Not Pos = 'G'
and P > 5
Order by Team
;
--Using CTE to look at team stats over 2 years using finalized playoff rosters
--Looking at Total Powerplay goals compared to Total team goals

--Can use this data as a view aswell by uncommenting this line below
--Create View PowerPlayGoalsByTeam as
With TeamStats2021(Team, Yr, TeamGoals, TeamPPG)
as 
(
	Select distinct Team, Yr = ' 20/21', (Sum(G) OVER (Partition by Team)) as TeamGoals, (Sum(PPG) OVER (Partition by Team)) as TeamPPG
	From HockeyStats..stats2020_2021
	Where P is NOT NULL
), TeamStats1920 as
	(Select distinct Team, Yr = ' 19/20', (Sum(G) OVER (Partition by Team)) as TeamGoals, (Sum(PPG) OVER (Partition by Team)) as TeamPPG
	From HockeyStats..stats2019_2020
	Where P is NOT NULL
)

Select TeamStats1920.Team + Yr as Team , TeamStats1920.TeamGoals, TeamStats1920.TeamPPG, (TeamStats1920.TeamGoals - TeamStats1920.TeamPPG) as PPDiff
From TeamStats1920 
Union ALL
Select TeamStats2021.Team +  Yr as Team, TeamStats2021.TeamGoals, TeamStats2021.TeamPPG, (TeamStats2021.TeamGoals - TeamStats2021.TeamPPG) as PPDiff
From TeamStats2021 
Order By TeamPPG desc


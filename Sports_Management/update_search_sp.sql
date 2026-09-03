USE [SportsModuleDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_SearchMembers]
    @SearchTerm NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@SearchTerm, '') = ''
    BEGIN
        SELECT TOP 100
            MemberID,
            MemberNo AS MembershipNo,
            MemberName AS FullName,
            MemberNo + ' - ' + MemberName AS MemberDisplay,
            Status,
            Mobile AS ContactNo
        FROM MemberShip.dbo.MemberProfile
        ORDER BY MemberName;
    END
    ELSE
    BEGIN
        SELECT TOP 200
            MemberID,
            MembershipNo,
            FullName,
            MemberDisplay,
            Status,
            ContactNo
        FROM
        (
            -- Main Members
            SELECT
                MemberID,
                MemberNo AS MembershipNo,
                MemberName AS FullName,
                MemberNo + ' - ' + MemberName AS MemberDisplay,
                MemberName AS OrderName,
                1 AS Priority,
                Status,
                Mobile AS ContactNo
            FROM MemberShip.dbo.MemberProfile
            WHERE (
                    MemberNo LIKE '%' + @SearchTerm + '%'
                 OR MemberName LIKE '%' + @SearchTerm + '%'
              )

            UNION ALL

            -- Spouses
            SELECT
                mp.MemberID,
                ms.MembershipNo,
                ms.SpouseName AS FullName,
                ms.MembershipNo + ' - ' + ms.SpouseName +
                ' (Spouse of ' + mp.MemberName + ')' AS MemberDisplay,
                mp.MemberName AS OrderName,
                2 AS Priority,
                CASE WHEN ms.RecordStatus = 'Active' THEN mp.Status ELSE 'Inactive' END AS Status,
                ISNULL(ms.SpousePhone, mp.Mobile) AS ContactNo
            FROM MemberShip.dbo.MemberSpouses ms
            INNER JOIN MemberShip.dbo.MemberProfile mp
                ON ms.MemberID = mp.MemberID
            WHERE (
                    ms.MembershipNo LIKE '%' + @SearchTerm + '%'
                 OR ms.SpouseName LIKE '%' + @SearchTerm + '%'
              )

            UNION ALL

            -- Children
            SELECT
                mp.MemberID,
                mc.MembershipNo,
                mc.ChildName AS FullName,
                mc.MembershipNo + ' - ' + mc.ChildName +
                ' (' + ISNULL(mc.Relationship, 'Dependent') + ' of ' + mp.MemberName + ')' AS MemberDisplay,
                mp.MemberName AS OrderName,
                3 AS Priority,
                CASE WHEN mc.RecordStatus = 'Active' THEN mp.Status ELSE 'Inactive' END AS Status,
                ISNULL(mc.ChildPhone, mp.Mobile) AS ContactNo
            FROM MemberShip.dbo.MemberChildren mc
            INNER JOIN MemberShip.dbo.MemberProfile mp
                ON mc.MemberID = mp.MemberID
            WHERE (
                    mc.MembershipNo LIKE '%' + @SearchTerm + '%'
                 OR mc.ChildName LIKE '%' + @SearchTerm + '%'
              )
        ) AS Combined
        ORDER BY Priority, OrderName;
    END
END
GO

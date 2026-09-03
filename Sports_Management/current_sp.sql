Text                                                                                                                                                                                                                                                           
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_SearchMembers]
                                                                                                                                                                                                                    
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
                                                                                                                                                                                                                          
            MemberNo + ' - ' + MemberName AS MemberDisplay
                                                                                                                                                                                                   
        FROM MemberShip.dbo.MemberProfile
                                                                                                                                                                                                                    
        WHERE IsActive = '1'
                                                                                                                                                                                                                                 
        ORDER BY MemberName;
                                                                                                                                                                                                                                 
    END
                                                                                                                                                                                                                                                      
    ELSE
                                                                                                                                                                                                                                                     
    BEGIN
                                                                                                                                                                                                                                                    
        SELECT TOP 200
                                                                                                                                                                                                                                       
            MemberID,
                                                                                                                                                                                                                                        
            MembershipNo,
                                                                                                                                                                                                                                    
            FullName,
                                                                                                                                                                                                                                        
            MemberDisplay
                                                                                                                                                                                                                                    
        FROM
                                                                                                                                                                                                                                                 
        (
                                                                                                                                                                                                                                                    
            -- Main Members
                                                                                                                                                                                                                                  
            SELECT
                                                                                                                                                                                                                                           
                MemberID,
                                                                                                                                                                                                                                    
                MemberNo AS MembershipNo,
                                                                                                                                                                                                                    
                MemberName AS FullName,
                                                                                                                                                                                                                      
                MemberNo + ' - ' + MemberName AS MemberDisplay,
                                                                                                                                                                                              
                MemberName AS OrderName,
                                                                                                                                                                                                                     
                1 AS Priority
                                                                                                                                                                                                                                
            FROM MemberShip.dbo.MemberProfile
                                                                                                                                                                                                                
            WHERE IsActive = '1'
                                                                                                                                                                                                                             
              AND (
                                                                                                                                                                                                                                          
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
                                                                                                                                                                                                                  
                2 AS Priority
                                                                                                                                                                                                                                
            FROM MemberShip.dbo.MemberSpouses ms
                                                                                                                                                                                                             
            INNER JOIN MemberShip.dbo.MemberProfile mp
                                                                                                                                                                                                       
                ON ms.MemberID = mp.MemberID
                                                                                                                                                                                                                 
            WHERE mp.IsActive = '1'
                                                                                                                                                                                                                          
              AND ms.RecordStatus = 'Active'
                                                                                                                                                                                                                 
              AND (
                                                                                                                                                                                                                                          
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
                                                                                                                                                                                                     
                ' (' + mc.Relationship + ' of ' + mp.MemberName + ')' AS MemberDisplay,
                                                                                                                                                                      
                mp.MemberName AS OrderName,
                                                                                                                                                                                                                  
                3 AS Priority
                                                                                                                                                                                                                                
            FROM MemberShip.dbo.MemberChildren mc
                                                                                                                                                                                                            
            INNER JOIN MemberShip.dbo.MemberProfile mp
                                                                                                                                                                                                       
                ON mc.MemberID = mp.MemberID
                                                                                                                                                                                                                 
            WHERE mp.IsActive = '1'
                                                                                                                                                                                                                          
              AND mc.RecordStatus = 'Active'
                                                                                                                                                                                                                 
              AND (
                                                                                                                                                                                                                                          
                    mc.MembershipNo LIKE '%' + @SearchTerm + '%'
                                                                                                                                                                                             
                 OR mc.ChildName LIKE '%' + @SearchTerm + '%'
                                                                                                                                                                                                
              )
                                                                                                                                                                                                                                              
        ) AS Combined
                                                                                                                                                                                                                                        
        ORDER BY Priority, OrderName;
                                                                                                                                                                                                                        
    END
                                                                                                                                                                                                                                                      
END
                                                                                                                                                                                                                                                          

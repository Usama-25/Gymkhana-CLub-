USE GymkhanaLibraryDB;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DefineCategory
    @CatID        SMALLINT      = NULL,
    @CatCode      VARCHAR(8),
    @CatName      NVARCHAR(80),
    @ParentCatID  SMALLINT      = NULL,
    @IsActive     BIT           = 1,
    @DdcPrefix    VARCHAR(10)   = NULL,
    @Msg          NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @CatCode = LTRIM(RTRIM(UPPER(@CatCode)));
    SET @CatName = LTRIM(RTRIM(@CatName));
    SET @DdcPrefix = LTRIM(RTRIM(@DdcPrefix));

    IF @DdcPrefix = '' SET @DdcPrefix = NULL;

    IF @CatCode = '' OR @CatName = ''
    BEGIN
        SET @Msg = 'Category/Subject Code and Name are required.';
        RETURN;
    END

    IF @ParentCatID = 0 SET @ParentCatID = NULL;

    IF @CatID IS NULL OR @CatID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM Categories WHERE CatCode = @CatCode)
        BEGIN
            SET @Msg = 'Category/Subject code "' + @CatCode + '" already exists.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Categories WHERE CatName = @CatName)
        BEGIN
            SET @Msg = 'Category/Subject name "' + @CatName + '" already exists.';
            RETURN;
        END

        INSERT INTO Categories (CatCode, CatName, ParentCatID, IsActive, DdcPrefix)
        VALUES (@CatCode, @CatName, @ParentCatID, @IsActive, @DdcPrefix);

        SET @Msg = 'Subject added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Categories WHERE CatID = @CatID)
        BEGIN
            SET @Msg = 'Category/Subject not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Categories WHERE CatCode = @CatCode AND CatID <> @CatID)
        BEGIN
            SET @Msg = 'Another category/subject with code "' + @CatCode + '" already exists.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Categories WHERE CatName = @CatName AND CatID <> @CatID)
        BEGIN
            SET @Msg = 'Another category/subject with name "' + @CatName + '" already exists.';
            RETURN;
        END

        UPDATE Categories
        SET CatCode     = @CatCode,
            CatName     = @CatName,
            ParentCatID = @ParentCatID,
            IsActive    = @IsActive,
            DdcPrefix   = @DdcPrefix
        WHERE CatID     = @CatID;

        SET @Msg = 'Subject updated successfully.';
    END
END;
GO

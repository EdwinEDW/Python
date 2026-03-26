--TRUNCATE TABLE DATAFRAMEBIENESTAR;
use EXAMENANALISTAJR;
CREATE TABLE DATAFRAMEBIENESTAR (
    entidad NVARCHAR(255),
    clues NVARCHAR(255),
    cpm FLOAT,
    grupo NVARCHAR(MAX),
    clave_cnis NVARCHAR(255),
    clave_kit_nucleos INT,
    clave_kit_movil INT,
    clave_kit_cessa INT,
    clave_kit_hospital INT,
    clave_kit_hospital_basico_comunitario INT,
    clave_kit_hospital_ped INT,
    clave_kit_hospital_materno INT,
    clave_kit_hospital_psiquiatrico INT,
    clave_kit_uneme_pn INT,
    archivo_origen NVARCHAR(255)
);
USE EXAMENANALISTAJR;
GO
USE EXAMENANALISTAJR;
GO
/*               IF OBJECT_ID('dbo.fn_LimpiezaAutomatica', 'FN') IS NOT NULL
                 DROP FUNCTION dbo.fn_LimpiezaAutomatica;
                 GO
*/
CREATE OR ALTER FUNCTION dbo.fn_LimpiezaAutomatica (@texto NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @texto IS NULL RETURN NULL;
    DECLARE @resultado NVARCHAR(MAX) = '';
    DECLARE @indice INT = 1;
    DECLARE @caracter NCHAR(1);
    SET @texto = UPPER(REPLACE(REPLACE(@texto, CHAR(10), ' '), CHAR(13), ' '));
    WHILE @indice <= LEN(@texto)
    BEGIN
        SET @caracter = SUBSTRING(@texto, @indice, 1);
        IF @caracter LIKE '[A-Z ]' 
            SET @resultado = @resultado + @caracter;
        SET @indice = @indice + 1;
    END
    WHILE CHARINDEX('  ', @resultado) > 0
        SET @resultado = REPLACE(@resultado, '  ', ' ');
    RETURN LTRIM(RTRIM(@resultado));
END;
GO
UPDATE DATAFRAMEBIENESTAR
SET 
    entidad = dbo.fn_LimpiezaAutomatica(entidad),
    clues = dbo.fn_LimpiezaAutomatica(clues),
    clave_cnis = UPPER(LTRIM(RTRIM(clave_cnis)));
GO
/*
--El Contador de los mal escritos
SELECT COUNT(DISTINCT entidad) AS Total_Estados_Final
FROM DATAFRAMEBIENESTAR;
-- Lista de los mal escritos
SELECT DISTINCT entidad 
FROM DATAFRAMEBIENESTAR 
ORDER BY entidad;
*/
select * from DATAFRAMEBIENESTAR
---------------------------------------------------------------------------
ALTER TABLE DATAFRAMEBIENESTAR 
ADD categoria_insumo NVARCHAR(50);
GO
select categoria_insumo from DATAFRAMEBIENESTAR
-----------
UPDATE DATAFRAMEBIENESTAR
SET categoria_insumo = CASE 
    WHEN LEFT(clave_cnis, 3) IN ('010', '020', '030', '040') THEN 'Medicamentos'
    WHEN LEFT(clave_cnis, 3) = '060' THEN 'Material de Curación'    
    ELSE 'Otros'
END;
GO
select * from DATAFRAMEBIENESTAR;
select categoria_insumo from DATAFRAMEBIENESTAR;
-------------------
-------------------------------------------
-------------------------------------------
/*Con los datos obtenidos, realiza una tabla resumen en la que identifiques los siguientes datos por entidad federativa:
para cada clave en cada unidad médica (CLUES).*/
-------------------------------------------
-------------------------------------------
SELECT 
    categoria_insumo AS Categoria,
    SUM(TRY_CAST(cpm AS DECIMAL(18,2))) AS Gasto_Total
INTO Datos_Grafica_Pastel
FROM DATAFRAMEBIENESTAR
GROUP BY categoria_insumo;
GO

-- Verifica que salgan datos aquí abajo:
SELECT * FROM Datos_Grafica_Pastel;


SELECT * FROM Resumen_Bienestar_Final ORDER BY Entidad_Federativa;
-------------------
-------------------------------------------
-------------------------------------------
/*	Tabla Resumen de Gasto: Muestra el gasto total de insumos desglosado por su categoría.*/
-------------------------------------------
--Creación 
SELECT 
    ISNULL(categoria_insumo, 'SIN CLASIFICAR') AS Categoria,
    COUNT(DISTINCT clave_cnis) AS Total_Claves,
    SUM(TRY_CAST(cpm AS DECIMAL(18,2))) AS Gasto_Total_Numerico
INTO Resumen_Gasto_Final
FROM DATAFRAMEBIENESTAR
GROUP BY categoria_insumo;
GO
--  Consulta
SELECT 
    Categoria,
    Total_Claves,
    FORMAT(Gasto_Total_Numerico, 'C', 'es-MX') AS [Gasto Total (Pesos)]
FROM Resumen_Gasto_Final
ORDER BY Gasto_Total_Numerico DESC;

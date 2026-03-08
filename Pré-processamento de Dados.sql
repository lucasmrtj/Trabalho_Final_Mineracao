SELECT 
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT CNPJ_FUNDO) AS total_fundos_distintos,
    MIN(DT_COMPTC) AS data_inicio,
    MAX(DT_COMPTC) AS data_fim,
    SUM(CASE WHEN VL_QUOTA IS NULL THEN 1 ELSE 0 END) AS cotas_nulas
FROM financial_fraud.bronze.informe_diario_2023;

WITH Filtragem_Fundos AS (
    -- Filtra apenas fundos relevantes: Patrimônio > 10 milhões e mais de 50 cotistas
    SELECT CNPJ_FUNDO
    FROM financial_fraud.bronze.informe_diario_2023
    GROUP BY CNPJ_FUNDO
    HAVING AVG(VL_PATRIM_LIQ) > 10000000 
       AND AVG(NR_COTST) > 50
),
Calculo_Retorno_Diario AS (
    -- Calcula a cota do dia anterior para achar a variação percentual
    SELECT 
        t.CNPJ_FUNDO,
        t.DT_COMPTC,
        t.VL_QUOTA,
        LAG(t.VL_QUOTA) OVER (PARTITION BY t.CNPJ_FUNDO ORDER BY t.DT_COMPTC) as quota_anterior
    FROM financial_fraud.bronze.informe_diario_2023 t
    INNER JOIN Filtragem_Fundos f ON t.CNPJ_FUNDO = f.CNPJ_FUNDO
),
Matriz_Base AS (
    -- Extrai o retorno diário
    SELECT 
        CNPJ_FUNDO,
        (VL_QUOTA - quota_anterior) / NULLIF(quota_anterior, 0) AS retorno_diario
    FROM Calculo_Retorno_Diario
    WHERE quota_anterior IS NOT NULL
)
-- Agrega tudo na matriz final que será usada no Machine Learning
SELECT 
    CNPJ_FUNDO,
    COUNT(retorno_diario) AS dias_operados,
    AVG(retorno_diario) AS retorno_medio_diario,
    STDDEV(retorno_diario) AS volatilidade_risco
FROM Matriz_Base
GROUP BY CNPJ_FUNDO
HAVING COUNT(retorno_diario) > 80; -- Garante que o fundo operou em quase todo o período
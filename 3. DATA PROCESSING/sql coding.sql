
SELECT * FROM `workspace`.`fnb`.`sales_edited`;

 SELECT 
 TO_DATE(Date) As `Transaction Date`,
 DAYNAME(Date) AS `Day Of Week`,
 MONTHNAME(Date) AS `Month Of Transaction`,
 YEAR(Date) AS `Year Of Transaction`
 
 FROM `workspace`.`fnb`.`sales_edited`;

WITH Elasticity AS
(
    SELECT
        *,
        
        `Unit Price` AS `Current Price`,

        LAG(`Unit Price`) OVER(
            ORDER BY Date
        ) AS `Previous Price`,

        LAG(`Quantity Sold`) OVER(
            ORDER BY Date
        ) AS `Previous Quantity`

    FROM `workspace`.`fnb`.`sales_edited`
),

`PED Calculation` AS
(
    SELECT
        *,

        ROUND(
            ABS(
                TRY_DIVIDE(
                    TRY_DIVIDE(
                        `Quantity Sold` - `Previous Quantity`,
                        `Previous Quantity`
                    ),
                    TRY_DIVIDE(
                        `Current Price` - `Previous Price`,
                        `Previous Price`
                    )
                )
            ),
            2
        ) AS `Price Elasticity`

    FROM Elasticity
)

SELECT
    Date,
    DAYNAME(Date) AS `Day Of Week`,
    MONTHNAME(Date) AS `Month Of Transaction`,
    YEAR(Date) AS `Year Of Transaction`,
    Sales,
    `Cost Of Sales`,
    `Quantity Sold`,
    `Gross Profit`,
    `Daily Profit`,
    `Cost of Unit Price`,
    `Unit Price`,
    `Gross Profit Percentage`,
    `Daily Gross Profit Per Unit`,
    Promo_Price,
    Promotion_flag,
    

    `Price Elasticity`,

    CASE 
     WHEN `Gross Profit`=0 THEN 'No Profit'
     WHEN `Gross Profit`>0 THEN 'Profitable'
     WHEN `Gross Profit`<0 THEN 'Unprofitable'
    END AS Profitability,

    CASE
        WHEN `Previous Price` IS NULL 
             OR `Previous Quantity` IS NULL 
             THEN 'Undefined'

        WHEN `Price Elasticity` = 0 
             THEN 'Perfectly Inelastic'

        WHEN `Price Elasticity` < 1 
             THEN 'Inelastic Demand'

        WHEN `Price Elasticity` = 1 
             THEN 'Unit Elastic Demand'

        WHEN `Price Elasticity` > 1 
             THEN 'Elastic Demand'

        ELSE 'Undefined'

    END AS  `Price Elasticity Category`

FROM `PED Calculation`;

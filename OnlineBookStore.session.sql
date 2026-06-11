SELECT * FROM factsales;

COPY factsales
TO '/Users/vestas/Desktop/factsales.csv'
WITH CSV HEADER;

COPY dimcustomer TO '/Users/vestas/Desktop/dimcustomer.csv' WITH CSV HEADER;
COPY dimbook TO '/Users/vestas/Desktop/dimbook.csv' WITH CSV HEADER;
COPY dimdate TO '/Users/vestas/Desktop/dimdate.csv' WITH CSV HEADER;
COPY factpayments TO '/Users/vestas/Desktop/factpayments.csv' WITH CSV HEADER;
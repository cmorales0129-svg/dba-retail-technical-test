CREATE OR REPLACE VIEW retail.vw_clientes_enmascarados AS
SELECT
    cliente_id,
    nombres,
    apellidos,
    ciudad,
    LEFT(numero_documento, 3) || '******' || RIGHT(numero_documento, 2) AS documento_mask,
    LEFT(email, 2) || '*****@' || SPLIT_PART(email, '@', 2) AS email_mask,
    '***' || RIGHT(telefono, 4) AS telefono_mask
FROM retail.clientes;

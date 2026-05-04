-- ========================================================
-- BLOQUE DE LÓGICA: AUTOMATIZACIÓN E INTEGRIDAD (FINAL)
-- ========================================================

-- ========================================================
-- A. CÁLCULO AUTOMÁTICO DE SUBTOTAL
-- ========================================================
CREATE OR REPLACE FUNCTION fn_calcular_subtotal()
RETURNS TRIGGER AS $$
BEGIN
    NEW.subtotal := NEW.cantidad * NEW.precio_unitario;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_subtotal
BEFORE INSERT OR UPDATE ON ventas_detalle
FOR EACH ROW EXECUTE FUNCTION fn_calcular_subtotal();


-- ========================================================
-- B. GESTIÓN DE STOCK DE SABORES (ROBUSTO + CONCURRENCIA)
-- ========================================================
CREATE OR REPLACE FUNCTION fn_gestion_stock_sabores()
RETURNS TRIGGER AS $$
DECLARE
    v_stock_actual NUMERIC;
BEGIN
    -- INSERT: Descontar stock
    IF TG_OP = 'INSERT' THEN
        SELECT stock_gramos INTO v_stock_actual 
        FROM sabores WHERE id_sabor = NEW.id_sabor FOR UPDATE;

        IF v_stock_actual < NEW.gramos_descontados THEN
            RAISE EXCEPTION 'Stock insuficiente para sabor ID %', NEW.id_sabor;
        END IF;

        UPDATE sabores SET stock_gramos = stock_gramos - NEW.gramos_descontados 
        WHERE id_sabor = NEW.id_sabor;

    -- DELETE: Reponer stock
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE sabores SET stock_gramos = stock_gramos + OLD.gramos_descontados 
        WHERE id_sabor = OLD.id_sabor;

    -- UPDATE: Ajustar diferencias
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.id_sabor <> NEW.id_sabor THEN
            -- Devolver al viejo, descontar al nuevo
            UPDATE sabores SET stock_gramos = stock_gramos + OLD.gramos_descontados WHERE id_sabor = OLD.id_sabor;
            
            SELECT stock_gramos INTO v_stock_actual FROM sabores WHERE id_sabor = NEW.id_sabor FOR UPDATE;
            IF v_stock_actual < NEW.gramos_descontados THEN
                RAISE EXCEPTION 'Stock insuficiente para nuevo sabor ID %', NEW.id_sabor;
            END IF;
            UPDATE sabores SET stock_gramos = stock_gramos - NEW.gramos_descontados WHERE id_sabor = NEW.id_sabor;
        ELSE
            -- Mismo sabor, ajustar diferencia
            SELECT stock_gramos INTO v_stock_actual FROM sabores WHERE id_sabor = NEW.id_sabor FOR UPDATE;
            IF v_stock_actual + OLD.gramos_descontados < NEW.gramos_descontados THEN
                RAISE EXCEPTION 'Stock insuficiente para ajuste en sabor ID %', NEW.id_sabor;
            END IF;
            UPDATE sabores SET stock_gramos = stock_gramos + OLD.gramos_descontados - NEW.gramos_descontados 
            WHERE id_sabor = NEW.id_sabor;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_stock_sabores
AFTER INSERT OR UPDATE OR DELETE ON detalle_sabores
FOR EACH ROW EXECUTE FUNCTION fn_gestion_stock_sabores();


-- ========================================================
-- C. GESTIÓN DE PUNTOS POR COMPRA
-- ========================================================
CREATE OR REPLACE FUNCTION fn_gestion_puntos_fidelidad()
RETURNS TRIGGER AS $$
DECLARE
    v_id_cliente INT;
    v_puntos_old INT;
    v_puntos_new INT;
BEGIN
    SELECT id_cliente INTO v_id_cliente FROM ventas_cabecera 
    WHERE id_venta = COALESCE(NEW.id_venta, OLD.id_venta);

    IF v_id_cliente IS NULL THEN RETURN NULL; END IF;

    IF TG_OP = 'INSERT' THEN
        SELECT puntos_otorgados * NEW.cantidad INTO v_puntos_new FROM productos WHERE id_producto = NEW.id_producto;
        UPDATE clientes SET puntos_acumulados = puntos_acumulados + v_puntos_new WHERE id_cliente = v_id_cliente;

    ELSIF TG_OP = 'DELETE' THEN
        SELECT puntos_otorgados * OLD.cantidad INTO v_puntos_old FROM productos WHERE id_producto = OLD.id_producto;
        UPDATE clientes SET puntos_acumulados = GREATEST(puntos_acumulados - v_puntos_old, 0) WHERE id_cliente = v_id_cliente;

    ELSIF TG_OP = 'UPDATE' THEN
        SELECT puntos_otorgados * OLD.cantidad INTO v_puntos_old FROM productos WHERE id_producto = OLD.id_producto;
        SELECT puntos_otorgados * NEW.cantidad INTO v_puntos_new FROM productos WHERE id_producto = NEW.id_producto;
        UPDATE clientes SET puntos_acumulados = GREATEST(puntos_acumulados - v_puntos_old + v_puntos_new, 0) WHERE id_cliente = v_id_cliente;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_puntos_detalle
AFTER INSERT OR UPDATE OR DELETE ON ventas_detalle
FOR EACH ROW EXECUTE FUNCTION fn_gestion_puntos_fidelidad();


-- ========================================================
-- D. ACTUALIZACIÓN DE TOTALES EN CABECERA
-- ========================================================
CREATE OR REPLACE FUNCTION fn_actualizar_totales_venta()
RETURNS TRIGGER AS $$
BEGIN
    WITH total AS (
        SELECT COALESCE(SUM(subtotal), 0) AS suma 
        FROM ventas_detalle 
        WHERE id_venta = COALESCE(NEW.id_venta, OLD.id_venta)
    )
    UPDATE ventas_cabecera vc
    SET monto_base = total.suma,
        total_final = total.suma + COALESCE(vc.comision_app, 0) + COALESCE(vc.costo_envio, 0)
    FROM total 
    WHERE vc.id_venta = COALESCE(NEW.id_venta, OLD.id_venta);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_totales_venta
AFTER INSERT OR UPDATE OR DELETE ON ventas_detalle
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_totales_venta();


-- ========================================================
-- E. GESTIÓN DE CANJES (RESTA DE PUNTOS AL CLIENTE)
-- ========================================================
CREATE OR REPLACE FUNCTION fn_procesar_canje_puntos()
RETURNS TRIGGER AS $$
DECLARE
    v_puntos_actuales INT;
BEGIN
    -- Bloquear fila del cliente para evitar doble canje simultáneo
    SELECT puntos_acumulados INTO v_puntos_actuales 
    FROM clientes WHERE id_cliente = NEW.id_cliente FOR UPDATE;

    IF v_puntos_actuales < NEW.puntos_utilizados THEN
        RAISE EXCEPTION 'El cliente no tiene puntos suficientes para este canje. Posee %, requiere %', 
        v_puntos_actuales, NEW.puntos_utilizados;
    END IF;

    -- Restar puntos
    UPDATE clientes 
    SET puntos_acumulados = puntos_acumulados - NEW.puntos_utilizados 
    WHERE id_cliente = NEW.id_cliente;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_registrar_canje
BEFORE INSERT ON canjes_registro
FOR EACH ROW EXECUTE FUNCTION fn_procesar_canje_puntos();
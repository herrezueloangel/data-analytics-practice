-- ==========================================
-- SQL Practice Queries
-- Database: Library Management
-- Topics:
-- - Subqueries
-- - Aggregations
-- - Joins
-- ==========================================

-- 1)Quin és el nom de l'empleat (o dels empleats) i la seva posició, amb el mínim any de contractació?

SELECT empleado_id, nombre, apellido, posicion, año_contratacion
FROM empleados
WHERE año_contratacion = (
	SELECT MIN(año_contratacion)
	FROM empleados);
    
-- 2) Mostra el nom de la categoria i el nom del llibre (o llibres), dels llibres amb l'any de publicació més recent de cada categoria.

-- Solution 1:
SELECT c.categoria_id, c.nombre, l.titulo, l.año_publicacion
FROM categorias c
JOIN libros l ON l.categoria_id = c.categoria_id
WHERE l.año_publicacion = (
	SELECT MAX(l2.año_publicacion) 
	FROM libros l2
    WHERE l2.categoria_id = l.categoria_id
    )
ORDER BY año_publicacion DESC;

-- Solution 2:

SELECT c.nombre AS categoria, l.titulo, l.año_publicacion
FROM categorias c
JOIN libros l ON c.categoria_id = l.categoria_id
JOIN (
    SELECT categoria_id, MAX(año_publicacion) AS max_año
    FROM libros
    GROUP BY categoria_id
) t ON l.categoria_id = t.categoria_id
   AND l.año_publicacion = t.max_año
ORDER BY año_publicacion DESC;

-- 3) Mostra els llibres que tenen més còpies que la mitjana del nombre de còpies dels llibres de la seva categoria.

-- Solution 1:

SELECT l.libro_id, l.titulo
FROM libros l 
WHERE l.cantidad_copias > (
	SELECT ROUND(AVG(l2.cantidad_copias),2) AS media_copias
	FROM libros l2
	WHERE l2.categoria_id = l.categoria_id
    );

-- Solution 2:

SELECT 
	l.libro_id,
    l.titulo,
    l.cantidad_copias,
    m.media_categoria
FROM libros l
JOIN (
    SELECT 
        categoria_id,
        ROUND(AVG(cantidad_copias),2) AS media_categoria
    FROM libros
    GROUP BY categoria_id
) m ON m.categoria_id = l.categoria_id
WHERE l.cantidad_copias > m.media_categoria;

-- 4) Quin és el nom del llibre i del seu autor, del llibre que té un import més gran en multes 
-- (comptant la suma de totes les multes de cada llibre)?

SELECT l.libro_id, l.titulo, a.nombre, s.Total_importe
FROM libros l
JOIN autores a ON a.autor_id = l.autor_id
JOIN (
	SELECT p.libro_id, SUM(importe) AS Total_importe
	FROM multas m
    JOIN prestamos p ON p.prestamo_id = m.prestamo_id
	GROUP BY p.libro_id
) s ON s.libro_id = l.libro_id
ORDER BY s.Total_importe DESC
LIMIT 1

-- Sobre la BBDD “hospitales”, pots realitzar els següents exercicis per practicar les subqueries:
-- 5. Mostra el nom del hospital amb més pressupost de cada comunitat autònoma.
SELECT h.nombre, h.comunidad_autonoma, h.presupuesto_anual_millones
FROM hospitales h
WHERE h.presupuesto_anual_millones in (
    SELECT MAX(h2.presupuesto_anual_millones)
    FROM hospitales h2
    WHERE h2.comunidad_autonoma = h.comunidad_autonoma
);

-- 6. Mostra el nom de l'hospital i el nom del pacient que te menys edat de cada hospital.

-- Solution 1:

SELECT h.nombre, p.nombre, p.edad
FROM hospitales h
JOIN pacientes p ON p.hospital_id = h.hospital_id
WHERE p.edad in (
	SELECT MIN(p2.edad)
	FROM pacientes p2
    WHERE p2.hospital_id = p.hospital_id
    );

-- Solution 2:
    
SELECT 
    h.nombre AS hospital,
    p.nombre AS paciente,
    p.edad
FROM hospitales h
JOIN pacientes p 
    ON p.hospital_id = h.hospital_id
JOIN (
    SELECT 
        hospital_id,
        MIN(edad) AS edad_minima
    FROM pacientes
    GROUP BY hospital_id
) pm 
    ON pm.hospital_id = p.hospital_id
   AND pm.edad_minima = p.edad;
   
-- 7. Mostra els hospitals que estàn per sobre de la mitja de "indice_satisfaccion" de cada comunidad autònoma.

SELECT h.nombre, h.comunidad_autonoma, h2.Media_Comunidad
FROM hospitales h 
LEFT JOIN (
	SELECT 
    comunidad_autonoma,
	ROUND(AVG(indice_satisfaccion),2) AS Media_comunidad
	FROM hospitales 
	GROUP BY comunidad_autonoma
    ) h2
    ON h2.comunidad_autonoma = h.comunidad_autonoma
WHERE h.indice_satisfaccion > h2.Media_comunidad
ORDER BY h2.Media_comunidad DESC;


-- Exercicis JOIN
-- Sobre la BBDD “hospitales”, pots realitzar els següents exercicis per practicar els JOIN:
-- » 1. Mostra el nom dels hospitals i los pacients extranjers que hi ha a la localitat de Toledo.

SELECT h.nombre, p.nombre, p.nacionalidad, h.localidad
FROM hospitales h
JOIN pacientes p ON p.hospital_id = h.hospital_id
WHERE p.nacionalidad = 'Extranjera' 
AND h.localidad = 'Toledo';

-- » 2. Mostra el nom dels hospitals i la quantitat d'especialitats que hi ha als hospitals de la consulta anterior.

SELECT h.nombre, COUNT(DISTINCT e.especialidad) AS Num_especialidad
FROM hospitales h
JOIN pacientes p ON p.hospital_id = h.hospital_id
JOIN especialidades e ON e.hospital_id = h.hospital_id
WHERE p.nacionalidad = 'Extranjera' 
AND h.localidad = 'Toledo'
GROUP BY h.nombre;

-- » 3. Mostra el nom de l’hospital i les especialitats que té l’hospital amb identificador 105.

SELECT h.hospital_id, h.nombre AS Hospital, e.especialidad
FROM hospitales h
JOIN especialidades e ON e.hospital_id = h.hospital_id
WHERE h.hospital_id = 105;

-- » 4. Digues quants hospitals tenen dades a la taula "hospitales", però no tenen dades a la taula de "pacientes".

SELECT COUNT(DISTINCT h.hospital_id)  AS Total_Hospitales
FROM hospitales h 
LEFT JOIN pacientes p ON p.hospital_id = h.hospital_id
WHERE p.hospital_id IS NULL;

-- » 5. Mostra el nom de l'hospital que té menys especialitats fixes.

SELECT h.hospital_id, h.nombre, COUNT(DISTINCT e.especialidad) AS Num_especialidad
FROM hospitales h 
JOIN especialidades e ON e.hospital_id = h.hospital_id
WHERE e.fija = 'S'
GROUP BY h.hospital_id, h.nombre
ORDER BY Num_especialidad 
LIMIT 1;

-- » 6. Mostra el nom i el nombre total de visites de l'hospital amb identificador 45.

SELECT h.hospital_id, h.nombre, SUM(p.numero_visitas) AS Total_visitas
FROM hospitales h 
JOIN pacientes p ON p.hospital_id = h.hospital_id
WHERE p.hospital_id = 45
GROUP BY h.hospital_id, h.nombre;

-- » 7. Mostra el nom de l'hospital, el nom dels seus pacients estrangers i el nombre de visites, així com 
-- les especialitats que NO són fixes. Totes aquestes dades de l'hospital amb identificador 45.

SELECT h.nombre, e.especialidad, p.nombre, p.numero_visitas 
FROM hospitales h
JOIN especialidades e ON e.hospital_id = h.hospital_id
JOIN pacientes P ON p.hospital_id = h.hospital_id
WHERE h.hospital_id = 45
AND p.nacionalidad = 'Extranjera'
AND e.fija = 'N'; 

-- 1.Mostra el nom del llibre i el nom de l'autor dels llibres que són d'abans del 1927.

SELECT l.titulo, a.nombre, l.año_publicacion
FROM libros l
JOIN autores a ON a.autor_id = l.autor_id
WHERE l.año_publicacion < 1927
ORDER BY l.año_publicacion DESC;

-- 2.Sobre la pregunta anterior, quin és l'autor amb més llibres publicats abans de 1927?

SELECT  a.autor_id, a.nombre, COUNT(l.libro_id) AS total
FROM libros l
JOIN autores a ON a.autor_id = l.autor_id
WHERE l.año_publicacion < 1927
GROUP BY a.autor_id
ORDER BY total DESC
LIMIT 1;

-- 3.Mostra el nom dels llibres i la quantitat de vegades que han estat retornats amb retard. 
-- També s'ha de mostrar la mitjana dels dies de retard.

SELECT p.libro_id, l.titulo, COUNT(p.dias_retraso) AS Total,
ROUND(AVG(p.dias_retraso),2) AS Media	
FROM prestamos p
JOIN libros l ON l.libro_id = p.libro_id
WHERE p.estado_prestamo = 'finalizado con retraso'
GROUP BY p.libro_id
ORDER BY Total DESC;

-- Opcion2 

SELECT l.titulo, AVG(p.dias_retraso) AS MitjanaRetard, COUNT(p.prestamo_id) AS VegadesRetard
FROM libros l
JOIN prestamos p ON l.libro_id=p.libro_id
WHERE p.dias_retraso >0
GROUP BY l.titulo
ORDER BY l.titulo;
 
-- 4.Mostra la quantitat d'usuaris que no han realitzat cap préstec.

SELECT COUNT(u.usuario_id) AS Total_usuarios
FROM usuarios u 
LEFT JOIN prestamos p ON p.usuario_id = u.usuario_id
WHERE p.prestamo_id IS NULL;

-- 5.Mostra el nom dels 3 usuaris que han fet més préstecs.
SELECT u.nombre, u.apellido, COUNT(p.prestamo_id) AS Total_prestamos
FROM usuarios u 
JOIN prestamos p ON p.usuario_id = u.usuario_id
GROUP BY u.usuario_id, u.nombre
ORDER BY Total_prestamos DESC
LIMIT 3;


-- 6.Mostra el nom i l'ID dels usuaris estrangers i que han hagut de pagar una multa per retard en la devolució del 
-- préstec superior a 10 euros.

SELECT DISTINCT u.usuario_id, u.nombre, u.apellido, u.nacionalidad
FROM usuarios u
JOIN prestamos p ON p.usuario_id = u.usuario_id
JOIN multas m ON m.prestamo_id = p.prestamo_id
WHERE u.nacionalidad = 'extranjera' AND m.importe > 10
ORDER BY u.usuario_id;

-- 7.Mostra l'autor nascut després de 1980 que ha generat més préstecs en usuaris espanyols. 
-- A més, només s'han de comptabilitzar els préstecs finalitzats (ok o amb retard).

SELECT l.autor_id, a.nombre, COUNT(p.prestamo_id) AS Cantidad_Total
FROM libros l
JOIN prestamos p ON p.libro_id = l.libro_id
JOIN usuarios u ON u.usuario_id = p.usuario_id
JOIN autores a ON a.autor_id = l.autor_id
WHERE u.nacionalidad = 'española'
AND a.año_nacimiento > 1980
AND p.estado_prestamo IN ('finalizado ok', 'finalizado con retraso')
GROUP BY l.autor_id, a.nombre
ORDER BY Cantidad_Total DESC
LIMIT 1;

-- 8.Quina és la categoria de llibres que més demanen en préstec les persones que tenen targeta de fidelitat?

SELECT l.categoria_id, c.nombre, COUNT(p.prestamo_id) AS Total_prestados
FROM libros l
JOIN  categorias c ON c.categoria_id = l.categoria_id
JOIN prestamos p ON p.libro_id = l.libro_id
JOIN usuarios u ON u.usuario_id = p.usuario_id
WHERE u.tarjeta_fidelidad = 'Si'
GROUP BY l.categoria_id, c.nombre
ORDER BY Total_prestados DESC
LIMIT 1;


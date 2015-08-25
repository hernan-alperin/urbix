--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
--SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = urbix, pg_catalog;

--
-- Data for Name: bkn_sensor; Type: TABLE DATA; Schema: urbix; Owner: urbix
--

/*
COPY bkn_sensor (sensor_id, active_adq_id, sensor_type_code, organization_code, counting_line_code, access_code, branch_group_code, branch_code, branch_type_code, country_code, state_code, county_code, city_code, neighborhood_code, latitude, longitude, active, description) FROM stdin;
1       1       1       1       1       7       \N      1       1       1       2       2       1       \N      \N      \N      t       Sensor 7, Acceso Estacionamiento 2º subsuelo
8       1       1       1       1       8       \N      1       1       1       2       2       1       \N      \N      \N      t       Sensor 8, Acceso McCafe Sur, sobre rampa discapacitados.( L.M.Campos lado Maure)
2       1       1       1       1       2       \N      1       2       1       2       2       1       \N      \N      \N      t       Sensor 2, Acceso PUESTO 2.( Gorostiaga y L.M.Campos)
1       1       1       1       1       1       \N      1       1       1       2       2       1       \N      \N      \N      t       Sensor 1, Acceso  PUESTO 1.( proovedores y personal)
52      1       1       1       1       13      \N      2       1       1       2       2       1       \N      \N      \N      t       Sensor 5, linea de conteo #2, pasillo izquierdo respecto de Acc. a Nivel 1.
53      1       1       1       1       14      \N      2       1       1       2       2       1       \N      \N      \N      t       Sensor 5, linea de conteo #3, pasillo derecho respecto de Acc. a Nivel 1.
\.
*/

truncate bkn_sensor cascade;
COPY bkn_sensor (sensor_id, active_adq_id, sensor_type_code, organization_code, counting_line_code, access_code, branch_group_code, branch_code, branch_type_code, country_code, state_code, county_code, city_code, neighborhood_code, latitude, longitude, active, description) FROM stdin;
1	1	1	1	1	1	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 1,  PB Acceso Vicente Lopez McCafe
3	1	1	1	1	14	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 3,  PB Acceso Hall Ascensores
2	1	1	1	1	2	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 2,  PB Acceso Escalera Mecánica
4	1	1	1	1	3	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 4,  1° Piso - Uriburu Acceso Puntera Uriburu Lacoste
5	1	1	1	1	3	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 5,  1° Piso - Uriburu Acceso Puntera Uriburu Juleriaque
8	1	1	1	1	6	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 8,  1° Piso  Acceso Ascensores 1 piso
6	1	1	1	1	7	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 6,  1° Piso - Junín Acceso Puntera Junin Grimoldi
7	1	1	1	1	7	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 7,  1° Piso - Junín Acceso Puntera Just for Sport
9	1	1	1	1	10	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 9,  2° Piso  Acceso Hall Ascensores 2 piso
10	1	1	1	1	13	\N	1	1	1	2	2	1	\N	\N	\N	t	Sensor 10,  3° Piso  Acceso Hall Ascensores 2 piso
\.

--
-- Name: bkn_sensor_id_seq; Type: SEQUENCE SET; Schema: urbix; Owner: urbix
--

SELECT pg_catalog.setval('bkn_sensor_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--


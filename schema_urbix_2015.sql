drop schema urbix cascade;
create schema urbix;
begin;
CREATE SEQUENCE urbix.ftn_hall_to_bkn_variable_id_seq;

CREATE TABLE urbix.ftn_hall_to_bkn_variable (
                id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_hall_to_bkn_variable_id_seq'),
                variable_id INTEGER NOT NULL,
                hall_id INTEGER NOT NULL,
                factor NUMERIC(6,4) NOT NULL,
                CONSTRAINT ftn_hall_to_bkn_variable_pk PRIMARY KEY (id)
);


ALTER SEQUENCE urbix.ftn_hall_to_bkn_variable_id_seq OWNED BY urbix.ftn_hall_to_bkn_variable.id;

CREATE SEQUENCE urbix.ftn_hall_to_ftn_branch_id_seq;

CREATE TABLE urbix.ftn_hall_to_ftn_branch (
                id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_hall_to_ftn_branch_id_seq'),
                hall_id INTEGER NOT NULL,
                branch_id INTEGER NOT NULL,
                CONSTRAINT ftn_hall_to_ftn_branch_pk PRIMARY KEY (id)
);


ALTER SEQUENCE urbix.ftn_hall_to_ftn_branch_id_seq OWNED BY urbix.ftn_hall_to_ftn_branch.id;

CREATE SEQUENCE urbix.ftn_branch_tickets_shop_ticketshop_id_seq;

CREATE TABLE urbix.ftn_branch_tickets_shop (
                ticketshop_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_branch_tickets_shop_ticketshop_id_seq'),
                branch_code VARCHAR(10) NOT NULL,
                day DATE NOT NULL,
                tickets NUMERIC(8),
                CONSTRAINT ftn_branch_tickets_shop_pk PRIMARY KEY (ticketshop_id)
);


ALTER SEQUENCE urbix.ftn_branch_tickets_shop_ticketshop_id_seq OWNED BY urbix.ftn_branch_tickets_shop.ticketshop_id;

CREATE SEQUENCE urbix.ftn_branch_category_category_id_seq;

CREATE TABLE urbix.ftn_branch_category (
                category_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_branch_category_category_id_seq'),
                description VARCHAR(50) NOT NULL,
                CONSTRAINT ftn_branch_category_pk PRIMARY KEY (category_id)
);


ALTER SEQUENCE urbix.ftn_branch_category_category_id_seq OWNED BY urbix.ftn_branch_category.category_id;

CREATE SEQUENCE urbix.ftn_branch_subcategory_subcategory_id_seq;

CREATE TABLE urbix.ftn_branch_subcategory (
                subcategory_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_branch_subcategory_subcategory_id_seq'),
                description VARCHAR(100) NOT NULL,
                category_id INTEGER NOT NULL,
                CONSTRAINT ftn_branch_subcategory_pk PRIMARY KEY (subcategory_id)
);


ALTER SEQUENCE urbix.ftn_branch_subcategory_subcategory_id_seq OWNED BY urbix.ftn_branch_subcategory.subcategory_id;

CREATE SEQUENCE urbix.users_branch_users_brancn_id_seq;

CREATE TABLE urbix.users_branch (
                users_brancn_id INTEGER NOT NULL DEFAULT nextval('urbix.users_branch_users_brancn_id_seq'),
                userpi_id INTEGER,
                branch_id INTEGER,
                user_type CHAR(1),
                password VARCHAR(15),
                CONSTRAINT users_branch_pk PRIMARY KEY (users_brancn_id)
);


ALTER SEQUENCE urbix.users_branch_users_brancn_id_seq OWNED BY urbix.users_branch.users_brancn_id;

CREATE SEQUENCE urbix.ums_log_id_seq;

CREATE TABLE urbix.ums_log (
                id INTEGER NOT NULL DEFAULT nextval('urbix.ums_log_id_seq'),
                creation_date TIMESTAMP DEFAULT now() NOT NULL,
                type_code VARCHAR(10) NOT NULL,
                msg VARCHAR(4000) NOT NULL,
                CONSTRAINT ums_log_pk PRIMARY KEY (id)
);


ALTER SEQUENCE urbix.ums_log_id_seq OWNED BY urbix.ums_log.id;

CREATE TABLE urbix.ums_code (
                type VARCHAR(100) NOT NULL,
                code INTEGER NOT NULL,
                short_desc VARCHAR(100) NOT NULL,
                description VARCHAR(4000) NOT NULL,
                CONSTRAINT ums_code_pk PRIMARY KEY (type, code)
);


CREATE TABLE urbix.ftn_time_period (
                date DATE NOT NULL,
                day VARCHAR(15) NOT NULL,
                month VARCHAR(15) NOT NULL,
                year INTEGER NOT NULL,
                week VARCHAR(15) NOT NULL,
                holiday CHAR(1) NOT NULL,
                first_day_of_month CHAR(1) NOT NULL,
                comment VARCHAR(300),
                week_description VARCHAR(30),
                day_of_week NUMERIC(1) NOT NULL,
                day_colour VARCHAR(7) NOT NULL,
                CONSTRAINT ftn_time_period_pk PRIMARY KEY (date)
);


CREATE SEQUENCE urbix.ftn_supervisor_supervisor_id_seq;

CREATE TABLE urbix.ftn_supervisor (
                supervisor_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_supervisor_supervisor_id_seq'),
                name VARCHAR(200) NOT NULL,
                email VARCHAR(100),
                in_alert NUMERIC(10,4),
                out_alert NUMERIC(10,4),
                ocupation_alert NUMERIC(10,4),
                send_email BOOLEAN DEFAULT false NOT NULL,
                CONSTRAINT ftn_supervisor_pk PRIMARY KEY (supervisor_id)
);


ALTER SEQUENCE urbix.ftn_supervisor_supervisor_id_seq OWNED BY urbix.ftn_supervisor.supervisor_id;

CREATE SEQUENCE urbix.ftn_region_region_id_seq;

CREATE TABLE urbix.ftn_region (
                region_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_region_region_id_seq'),
                country VARCHAR(100) NOT NULL,
                state VARCHAR(100) NOT NULL,
                county VARCHAR(100) NOT NULL,
                city VARCHAR(100) NOT NULL,
                neighborhood VARCHAR(100) NOT NULL,
                CONSTRAINT ftn_region_pk PRIMARY KEY (region_id)
);


ALTER SEQUENCE urbix.ftn_region_region_id_seq OWNED BY urbix.ftn_region.region_id;

CREATE SEQUENCE urbix.ftn_company_company_id_seq;

CREATE TABLE urbix.ftn_company (
                company_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_company_company_id_seq'),
                name VARCHAR(200) NOT NULL,
                location VARCHAR(100) NOT NULL,
                country VARCHAR(40) NOT NULL,
                latitude NUMERIC(10,7) NOT NULL,
                longitude NUMERIC(10,7) NOT NULL,
                CONSTRAINT ftn_company_pk PRIMARY KEY (company_id)
);


ALTER SEQUENCE urbix.ftn_company_company_id_seq OWNED BY urbix.ftn_company.company_id;

CREATE SEQUENCE urbix.ftn_branch_type_branch_type_id_seq;

CREATE TABLE urbix.ftn_branch_type (
                branch_type_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_branch_type_branch_type_id_seq'),
                name VARCHAR(50) NOT NULL,
                description VARCHAR(100) NOT NULL,
                company_id INTEGER NOT NULL,
                CONSTRAINT ftn_branch_type_pk PRIMARY KEY (branch_type_id)
);


ALTER SEQUENCE urbix.ftn_branch_type_branch_type_id_seq OWNED BY urbix.ftn_branch_type.branch_type_id;

CREATE SEQUENCE urbix.ftn_branch_branch_id_seq;

CREATE SEQUENCE urbix.ftn_branch_end_audit_seq;

CREATE TABLE urbix.ftn_branch (
                branch_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_branch_branch_id_seq'),
                company_id INTEGER NOT NULL,
                region_id INTEGER NOT NULL,
                name VARCHAR(500) NOT NULL,
                surface NUMERIC(10,2) NOT NULL,
                latitude NUMERIC(10,7),
                longitude NUMERIC(10,7),
                employees INTEGER NOT NULL,
                branch_type_id INTEGER NOT NULL,
                branch_code VARCHAR(10) NOT NULL,
                subcategory_id INTEGER NOT NULL,
                address VARCHAR(50) NOT NULL,
                subsector_id INTEGER NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE NOT NULL,
                description character varying NOT NULL,
                "window" numeric NOT NULL,
                operator VARCHAR(50) NOT NULL,
                url VARCHAR(50) NOT NULL,
                start_audit DATE,
                end_audit bigint NOT NULL DEFAULT nextval('urbix.ftn_branch_end_audit_seq'),
                CONSTRAINT ftn_branch_pk PRIMARY KEY (branch_id)
);
COMMENT ON COLUMN urbix.ftn_branch.description IS 'Sinopsis de la marca/sucursal.';
COMMENT ON COLUMN urbix.ftn_branch."window" IS 'Metros lineales disponibles de vidriera.';


ALTER SEQUENCE urbix.ftn_branch_branch_id_seq OWNED BY urbix.ftn_branch.branch_id;

ALTER SEQUENCE urbix.ftn_branch_end_audit_seq OWNED BY urbix.ftn_branch.end_audit;

CREATE SEQUENCE urbix.ftn_ranking_tktm2_id_seq;

CREATE TABLE urbix.ftn_ranking_tktm2 (
                id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_ranking_tktm2_id_seq'),
                date DATE NOT NULL,
                branch_id INTEGER NOT NULL,
                ranking NUMERIC(4) NOT NULL,
                value NUMERIC(8,2) NOT NULL,
                CONSTRAINT ftn_ranking_tktm2_pk PRIMARY KEY (id)
);
COMMENT ON TABLE urbix.ftn_ranking_tktm2 IS 'Tabla con ranking de sucursales por tickets/m2';


ALTER SEQUENCE urbix.ftn_ranking_tktm2_id_seq OWNED BY urbix.ftn_ranking_tktm2.id;

CREATE SEQUENCE urbix.ftn_branch_sector_sector_id_seq;

CREATE TABLE urbix.ftn_branch_sector (
                sector_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_branch_sector_sector_id_seq'),
                branch_id INTEGER NOT NULL,
                supervisor_id INTEGER NOT NULL,
                description VARCHAR(100) NOT NULL,
                sector_colour VARCHAR(7) NOT NULL,
                CONSTRAINT ftn_branch_sector_pk PRIMARY KEY (sector_id)
);


ALTER SEQUENCE urbix.ftn_branch_sector_sector_id_seq OWNED BY urbix.ftn_branch_sector.sector_id;

CREATE SEQUENCE urbix.ftn_hall_ftn_hall_id_seq;

CREATE TABLE urbix.ftn_hall (
                hall_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_hall_ftn_hall_id_seq'),
                name VARCHAR(50) NOT NULL,
                description VARCHAR(200) NOT NULL,
                level NUMERIC(2) NOT NULL,
                hall_width NUMERIC(5,2) NOT NULL,
                sector_id INTEGER NOT NULL,
                hall_colour VARCHAR(7) NOT NULL,
                CONSTRAINT ftn_hall_pk PRIMARY KEY (hall_id)
);


ALTER SEQUENCE urbix.ftn_hall_ftn_hall_id_seq OWNED BY urbix.ftn_hall.hall_id;

CREATE SEQUENCE urbix.ftn_branch_subsector_subsector_id_seq;

CREATE TABLE urbix.ftn_branch_subsector (
                subsector_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_branch_subsector_subsector_id_seq'),
                sector_id INTEGER NOT NULL,
                description VARCHAR(100) NOT NULL,
                CONSTRAINT ftn_branch_subsector_pk PRIMARY KEY (subsector_id)
);


ALTER SEQUENCE urbix.ftn_branch_subsector_subsector_id_seq OWNED BY urbix.ftn_branch_subsector.subsector_id;

CREATE SEQUENCE urbix.ftn_branch_tickets_ticket_id_seq;

CREATE TABLE urbix.ftn_branch_tickets (
                ticket_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_branch_tickets_ticket_id_seq'),
                branch_id INTEGER NOT NULL,
                supervisor_id INTEGER,
                day DATE NOT NULL,
                tickets NUMERIC(8),
                last_update TIMESTAMP,
                CONSTRAINT ftn_branch_tickets_pk PRIMARY KEY (ticket_id)
);


ALTER SEQUENCE urbix.ftn_branch_tickets_ticket_id_seq OWNED BY urbix.ftn_branch_tickets.ticket_id;

CREATE SEQUENCE urbix.ftn_bitacora_category_bitacora_category_id_seq;

CREATE TABLE urbix.ftn_bitacora_category (
                bitacora_category_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_bitacora_category_bitacora_category_id_seq'),
                category_name VARCHAR(50) NOT NULL,
                CONSTRAINT ftn_bitacora_category_pk PRIMARY KEY (bitacora_category_id)
);


ALTER SEQUENCE urbix.ftn_bitacora_category_bitacora_category_id_seq OWNED BY urbix.ftn_bitacora_category.bitacora_category_id;

CREATE SEQUENCE urbix.ftn_bitacora_bitacora_id_seq;

CREATE TABLE urbix.ftn_bitacora (
                bitacora_id INTEGER NOT NULL DEFAULT nextval('urbix.ftn_bitacora_bitacora_id_seq'),
                bitacora_category_id INTEGER NOT NULL,
                branch_id INTEGER NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE NOT NULL,
                username VARCHAR(40) NOT NULL,
                description VARCHAR(500) NOT NULL,
                bitacora_name VARCHAR(50),
                private BOOLEAN,
                lun BOOLEAN,
                mar BOOLEAN,
                mie BOOLEAN,
                jue BOOLEAN,
                vie BOOLEAN,
                sab BOOLEAN,
                dom BOOLEAN,
                userpi_id INTEGER,
                CONSTRAINT ftn_bitacora_pk PRIMARY KEY (bitacora_id)
);


ALTER SEQUENCE urbix.ftn_bitacora_bitacora_id_seq OWNED BY urbix.ftn_bitacora.bitacora_id;

CREATE TABLE urbix.ft_people_impact (
                time TIMESTAMP,
                variable_id INTEGER,
                branch_id INTEGER,
                region_id INTEGER,
                company_id INTEGER,
                branch_type_id INTEGER,
                idtimeperiod TIMESTAMP,
                ingresos INTEGER,
                egresos DOUBLE PRECISION,
                ocupacion DOUBLE PRECISION,
                sector_id INTEGER
);


CREATE SEQUENCE urbix.bkn_variable_variable_id_seq;

CREATE TABLE urbix.bkn_variable (
                variable_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_variable_variable_id_seq'),
                description VARCHAR(500) NOT NULL,
                creation_date TIMESTAMP DEFAULT now() NOT NULL,
                end_date DATE,
                branch_id INTEGER NOT NULL,
                sensor_type_code INTEGER NOT NULL,
                access_code INTEGER NOT NULL,
                latitude NUMERIC(6,3) NOT NULL,
                longitude NUMERIC(6,3) NOT NULL,
                workday_start TIME NOT NULL,
                workday_duration INTEGER NOT NULL,
                sector_id INTEGER NOT NULL,
                public BOOLEAN DEFAULT FALSE NOT NULL,
                hall_id INTEGER NOT NULL,
                CONSTRAINT bkn_variable_pk PRIMARY KEY (variable_id)
);


ALTER SEQUENCE urbix.bkn_variable_variable_id_seq OWNED BY urbix.bkn_variable.variable_id;

CREATE INDEX bkn_variable_variable_id_idx
 ON urbix.bkn_variable USING BTREE
 ( variable_id );

CREATE TABLE urbix.ftn_variable_group (
                group_id INTEGER NOT NULL,
                variable_id INTEGER NOT NULL,
                CONSTRAINT ftn_variable_group_pk PRIMARY KEY (group_id, variable_id)
);


CREATE SEQUENCE urbix.bkn_time_range_time_range_id_seq;

CREATE TABLE urbix.bkn_time_range (
                time_range_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_time_range_time_range_id_seq'),
                description VARCHAR(500),
                r_from TIMESTAMP,
                r_to TIMESTAMP,
                presicion VARCHAR(20) NOT NULL,
                repeat VARCHAR(20) NOT NULL,
                CONSTRAINT bkn_time_range_pk PRIMARY KEY (time_range_id)
);


ALTER SEQUENCE urbix.bkn_time_range_time_range_id_seq OWNED BY urbix.bkn_time_range.time_range_id;

CREATE SEQUENCE urbix.bkn_time_filter_filter_id_seq;

CREATE TABLE urbix.bkn_time_filter (
                filter_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_time_filter_filter_id_seq'),
                description VARCHAR(500) NOT NULL,
                CONSTRAINT bkn_time_filter_pk PRIMARY KEY (filter_id)
);


ALTER SEQUENCE urbix.bkn_time_filter_filter_id_seq OWNED BY urbix.bkn_time_filter.filter_id;

CREATE TABLE urbix.bkn_time_filter_x_time_range (
                filter_id INTEGER NOT NULL,
                time_range_id INTEGER NOT NULL,
                range_not BOOLEAN DEFAULT false NOT NULL,
                CONSTRAINT bkn_time_filter_x_time_range_pk PRIMARY KEY (filter_id, time_range_id)
);


CREATE TABLE urbix.bkn_sensor_emulator (
                measure_time TIMESTAMP NOT NULL,
                sensor_1_1 NUMERIC(10,4),
                sensor_1_2 NUMERIC(10,4),
                sensor_2_1 NUMERIC(10,4),
                sensor_2_2 NUMERIC(10,4),
                sensor_3_1 NUMERIC(10,4),
                sensor_3_2 NUMERIC(10,4),
                sensor_4_1 NUMERIC(10,4),
                sensor_4_2 NUMERIC(10,4),
                sensor_5_1 NUMERIC(10,4),
                sensor_5_2 NUMERIC(10,4),
                sensor_6_1 NUMERIC(10,4),
                sensor_6_2 NUMERIC(10,4),
                sensor_8_1 NUMERIC(10,4),
                sensor_8_2 NUMERIC(10,4),
                sensor_11_1 NUMERIC(10,4),
                sensor_11_2 NUMERIC(10,4),
                sensor_12_1 NUMERIC(10,4),
                sensor_12_2 NUMERIC(10,4)
);


CREATE INDEX bkn_sensor_emulator_time_id
 ON urbix.bkn_sensor_emulator USING BTREE
 ( measure_time );

CREATE SEQUENCE urbix.bkn_result_result_id_seq;

CREATE TABLE urbix.bkn_result (
                result_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_result_result_id_seq'),
                variable_id INTEGER NOT NULL,
                time TIMESTAMP NOT NULL,
                data NUMERIC(10,4),
                CONSTRAINT bkn_result_pk1 PRIMARY KEY (result_id)
);


ALTER SEQUENCE urbix.bkn_result_result_id_seq OWNED BY urbix.bkn_result.result_id;

CREATE INDEX bkn_result_time_idx
 ON urbix.bkn_result USING BTREE
 ( time );

CREATE INDEX bkn_result_variable_idx
 ON urbix.bkn_result USING BTREE
 ( variable_id );

CREATE SEQUENCE urbix.bkn_formula_formula_id_seq;

CREATE TABLE urbix.bkn_formula (
                formula_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_formula_formula_id_seq'),
                name VARCHAR(100) NOT NULL,
                description VARCHAR(4000) NOT NULL,
                class VARCHAR(300) NOT NULL,
                end_date DATE,
                CONSTRAINT bkn_formula_pk PRIMARY KEY (formula_id)
);


ALTER SEQUENCE urbix.bkn_formula_formula_id_seq OWNED BY urbix.bkn_formula.formula_id;

CREATE SEQUENCE urbix.bkn_formula_param_param_id_seq;

CREATE TABLE urbix.bkn_formula_param (
                param_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_formula_param_param_id_seq'),
                formula_id INTEGER NOT NULL,
                description VARCHAR(500) NOT NULL,
                value VARCHAR(4000),
                type_code INTEGER NOT NULL,
                CONSTRAINT bkn_formula_param_pk PRIMARY KEY (param_id)
);


ALTER SEQUENCE urbix.bkn_formula_param_param_id_seq OWNED BY urbix.bkn_formula_param.param_id;

CREATE SEQUENCE urbix.bkn_adq_adq_id_seq;

CREATE TABLE urbix.bkn_adq (
                adq_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_adq_adq_id_seq'),
                creation_date TIMESTAMP DEFAULT now() NOT NULL,
                end_date DATE,
                description VARCHAR(500) NOT NULL,
                class VARCHAR(500) NOT NULL,
                CONSTRAINT bkn_adq_pk PRIMARY KEY (adq_id)
);


ALTER SEQUENCE urbix.bkn_adq_adq_id_seq OWNED BY urbix.bkn_adq.adq_id;

CREATE SEQUENCE urbix.bkn_adq_param_adq_param_id_seq;

CREATE TABLE urbix.bkn_adq_param (
                adq_param_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_adq_param_adq_param_id_seq'),
                adq_id INTEGER NOT NULL,
                description VARCHAR(500) NOT NULL,
                value VARCHAR(4000),
                type_code INTEGER NOT NULL,
                CONSTRAINT bkn_adq_param_pk PRIMARY KEY (adq_param_id)
);


ALTER SEQUENCE urbix.bkn_adq_param_adq_param_id_seq OWNED BY urbix.bkn_adq_param.adq_param_id;

CREATE SEQUENCE urbix.bkn_active_formula_active_formula_id_seq;

CREATE TABLE urbix.bkn_active_formula (
                active_formula_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_active_formula_active_formula_id_seq'),
                formula_id INTEGER NOT NULL,
                variable_id INTEGER NOT NULL,
                creation_date TIMESTAMP DEFAULT now() NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE,
                CONSTRAINT bkn_active_formula_pk PRIMARY KEY (active_formula_id)
);


ALTER SEQUENCE urbix.bkn_active_formula_active_formula_id_seq OWNED BY urbix.bkn_active_formula.active_formula_id;

CREATE SEQUENCE urbix.bkn_active_formula_param_active_formula_param_id_seq;

CREATE TABLE urbix.bkn_active_formula_param (
                active_formula_param_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_active_formula_param_active_formula_param_id_seq'),
                active_formula_id INTEGER NOT NULL,
                formula_param_id INTEGER NOT NULL,
                value VARCHAR(4000),
                CONSTRAINT bkn_active_formula_param_pk PRIMARY KEY (active_formula_param_id)
);


ALTER SEQUENCE urbix.bkn_active_formula_param_active_formula_param_id_seq OWNED BY urbix.bkn_active_formula_param.active_formula_param_id;

CREATE UNIQUE INDEX bkn_active_formula_param_idx
 ON urbix.bkn_active_formula_param USING BTREE
 ( active_formula_id, formula_param_id );

CREATE TABLE urbix.bkn_active_formula_param_x_time_filter (
                active_formula_param_id INTEGER NOT NULL,
                filter_id INTEGER NOT NULL,
                priority INTEGER NOT NULL,
                value VARCHAR(4000) NOT NULL,
                CONSTRAINT bkn_active_formula_param_x_time_filter_pk PRIMARY KEY (active_formula_param_id, filter_id, priority)
);


CREATE SEQUENCE urbix.bkn_active_adq_active_adq_id_seq;

CREATE TABLE urbix.bkn_active_adq (
                active_adq_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_active_adq_active_adq_id_seq'),
                adq_id INTEGER NOT NULL,
                creation_date TIMESTAMP DEFAULT now() NOT NULL,
                end_date DATE,
                CONSTRAINT bkn_active_adq_pk PRIMARY KEY (active_adq_id)
);


ALTER SEQUENCE urbix.bkn_active_adq_active_adq_id_seq OWNED BY urbix.bkn_active_adq.active_adq_id;

CREATE SEQUENCE urbix.bkn_sensor_sensor_id_seq;

CREATE TABLE urbix.bkn_sensor (
                sensor_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_sensor_sensor_id_seq'),
                active_adq_id INTEGER NOT NULL,
                sensor_type_code INTEGER,
                organization_code INTEGER,
                counting_line_code INTEGER,
                access_code INTEGER,
                branch_group_code INTEGER,
                branch_code INTEGER,
                branch_type_code INTEGER,
                country_code INTEGER,
                state_code INTEGER,
                county_code INTEGER,
                city_code INTEGER,
                neighborhood_code INTEGER,
                latitude NUMERIC(10,2),
                longitude NUMERIC(10,2),
                active BOOLEAN DEFAULT true,
                description VARCHAR(100),
                model VARCHAR(40) NOT NULL,
                serial_number VARCHAR(20) NOT NULL,
                installation_date DATE NOT NULL,
                CONSTRAINT bkn_sensor_pk PRIMARY KEY (sensor_id)
);


ALTER SEQUENCE urbix.bkn_sensor_sensor_id_seq OWNED BY urbix.bkn_sensor.sensor_id;

CREATE TABLE urbix.bkn_sensor_config (
                sensor_config_id INTEGER NOT NULL,
                sensor_id INTEGER NOT NULL,
                ip_device VARCHAR(15) NOT NULL,
                mask_device VARCHAR(15) NOT NULL,
                gateway_device VARCHAR(15) NOT NULL,
                dns_device VARCHAR(15) NOT NULL,
                ext_port_device NUMERIC(8) NOT NULL,
                int_port_device NUMERIC(8) NOT NULL,
                send_xml BOOLEAN NOT NULL,
                send_ftp BOOLEAN NOT NULL,
                ntp_server_ip VARCHAR(15) NOT NULL,
                public_ip VARCHAR(15) NOT NULL,
                CONSTRAINT bkn_sensor_config_pk PRIMARY KEY (sensor_config_id)
);


CREATE SEQUENCE urbix.bkn_sensor_factor_factor_id_seq;

CREATE TABLE urbix.bkn_sensor_factor (
                factor_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_sensor_factor_factor_id_seq'),
                sensor_id INTEGER NOT NULL,
                type_code INTEGER NOT NULL,
                factor_value NUMERIC(10,6) DEFAULT 1 NOT NULL,
                start_date DATE DEFAULT now() NOT NULL,
                end_date DATE,
                comment VARCHAR(600),
                CONSTRAINT bkn_sensor_factor_pk PRIMARY KEY (factor_id, sensor_id)
);


ALTER SEQUENCE urbix.bkn_sensor_factor_factor_id_seq OWNED BY urbix.bkn_sensor_factor.factor_id;

CREATE SEQUENCE urbix.bkn_sensor_status_log_log_id_seq;

CREATE TABLE urbix.bkn_sensor_status_log (
                log_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_sensor_status_log_log_id_seq'),
                sensor_id INTEGER NOT NULL,
                creation_date TIMESTAMP DEFAULT now() NOT NULL,
                status_code INTEGER NOT NULL,
                CONSTRAINT bkn_sensor_status_log_pk PRIMARY KEY (log_id)
);


ALTER SEQUENCE urbix.bkn_sensor_status_log_log_id_seq OWNED BY urbix.bkn_sensor_status_log.log_id;

CREATE SEQUENCE urbix.bkn_measure_measure_id_seq;

CREATE TABLE urbix.bkn_measure (
                measure_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_measure_measure_id_seq'),
                sensor_id INTEGER NOT NULL,
                creation_date TIMESTAMP DEFAULT now() NOT NULL,
                measure_time TIMESTAMP NOT NULL,
                refresh BOOLEAN DEFAULT true NOT NULL,
                CONSTRAINT bkn_measure_pk PRIMARY KEY (measure_id)
);


ALTER SEQUENCE urbix.bkn_measure_measure_id_seq OWNED BY urbix.bkn_measure.measure_id;

CREATE SEQUENCE urbix.bkn_measure_data_data_id_seq;

CREATE TABLE urbix.bkn_measure_data (
                data_id INTEGER NOT NULL DEFAULT nextval('urbix.bkn_measure_data_data_id_seq'),
                measure_id INTEGER NOT NULL,
                type_code INTEGER NOT NULL,
                value NUMERIC(10,4) NOT NULL,
                status INTEGER,
                original_value NUMERIC(10,4),
                CONSTRAINT bkn_measure_data_pk PRIMARY KEY (data_id)
);


ALTER SEQUENCE urbix.bkn_measure_data_data_id_seq OWNED BY urbix.bkn_measure_data.data_id;

CREATE TABLE urbix.bkn_active_adq_param (
                active_adq_id INTEGER NOT NULL,
                adq_param_id INTEGER NOT NULL,
                value VARCHAR(4000) NOT NULL,
                CONSTRAINT bkn_active_adq_param_pk PRIMARY KEY (active_adq_id, adq_param_id)
);


ALTER TABLE urbix.ftn_branch_subcategory ADD CONSTRAINT ftn_branch_category_ftn_branch_subcategory_fk
FOREIGN KEY (category_id)
REFERENCES urbix.ftn_branch_category (category_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch ADD CONSTRAINT ftn_branch_subcategory_ftn_branch_fk
FOREIGN KEY (subcategory_id)
REFERENCES urbix.ftn_branch_subcategory (subcategory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch_sector ADD CONSTRAINT ftn_supervisor_ftn_branch_sector_fk
FOREIGN KEY (supervisor_id)
REFERENCES urbix.ftn_supervisor (supervisor_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch ADD CONSTRAINT ftn_region_ftn_branch_fk
FOREIGN KEY (region_id)
REFERENCES urbix.ftn_region (region_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch ADD CONSTRAINT ftm_company_ftn_branch_fk
FOREIGN KEY (company_id)
REFERENCES urbix.ftn_company (company_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch_type ADD CONSTRAINT ftn_company_ftn_branch_type_fk
FOREIGN KEY (company_id)
REFERENCES urbix.ftn_company (company_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch ADD CONSTRAINT ftn_branch_type_ftn_branch_fk
FOREIGN KEY (branch_type_id)
REFERENCES urbix.ftn_branch_type (branch_type_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_variable ADD CONSTRAINT ftn_branch_bkn_active_formula_fk
FOREIGN KEY (branch_id)
REFERENCES urbix.ftn_branch (branch_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_bitacora ADD CONSTRAINT ftn_branch_ftn_bitacora_fk
FOREIGN KEY (branch_id)
REFERENCES urbix.ftn_branch (branch_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch_tickets ADD CONSTRAINT ftn_branch_ftn_branch_tickets_fk
FOREIGN KEY (branch_id)
REFERENCES urbix.ftn_branch (branch_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch_sector ADD CONSTRAINT ftn_branch_ftn_branch_sector_fk
FOREIGN KEY (branch_id)
REFERENCES urbix.ftn_branch (branch_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_ranking_tktm2 ADD CONSTRAINT ftn_branch_ftn_ranking_tktm2_fk
FOREIGN KEY (branch_id)
REFERENCES urbix.ftn_branch (branch_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_variable ADD CONSTRAINT ftn_branch_sector_bkn_variable_fk
FOREIGN KEY (sector_id)
REFERENCES urbix.ftn_branch_sector (sector_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch_subsector ADD CONSTRAINT ftn_branch_sector_ftn_branch_subsector_fk
FOREIGN KEY (sector_id)
REFERENCES urbix.ftn_branch_sector (sector_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_hall ADD CONSTRAINT ftn_branch_sector_ftn_hall_fk
FOREIGN KEY (sector_id)
REFERENCES urbix.ftn_branch_sector (sector_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_branch ADD CONSTRAINT ftn_branch_subsector_ftn_branch_fk
FOREIGN KEY (subsector_id)
REFERENCES urbix.ftn_branch_subsector (subsector_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_bitacora ADD CONSTRAINT ftn_bitacora_category_ftn_bitacora_fk
FOREIGN KEY (bitacora_category_id)
REFERENCES urbix.ftn_bitacora_category (bitacora_category_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_formula ADD CONSTRAINT bkn_variable_bkn_active_formula_fk
FOREIGN KEY (variable_id)
REFERENCES urbix.bkn_variable (variable_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_result ADD CONSTRAINT bkn_variable_bkn_result_fk
FOREIGN KEY (variable_id)
REFERENCES urbix.bkn_variable (variable_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.ftn_variable_group ADD CONSTRAINT bkn_variable_ftn_variable_group_fk
FOREIGN KEY (variable_id)
REFERENCES urbix.bkn_variable (variable_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_time_filter_x_time_range ADD CONSTRAINT bkn_time_range_bkn_time_filter_x_time_range_fk
FOREIGN KEY (time_range_id)
REFERENCES urbix.bkn_time_range (time_range_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_formula_param_x_time_filter ADD CONSTRAINT bkn_time_filter_bkn_active_formula_param_x_filter_fk
FOREIGN KEY (filter_id)
REFERENCES urbix.bkn_time_filter (filter_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_time_filter_x_time_range ADD CONSTRAINT bkn_time_filter_bkn_time_filter_x_time_range_fk
FOREIGN KEY (filter_id)
REFERENCES urbix.bkn_time_filter (filter_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_formula ADD CONSTRAINT bkn_formula_bkn_active_formula_fk
FOREIGN KEY (formula_id)
REFERENCES urbix.bkn_formula (formula_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_formula_param ADD CONSTRAINT bkn_formula_bkn_formula_param_fk
FOREIGN KEY (formula_id)
REFERENCES urbix.bkn_formula (formula_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_formula_param ADD CONSTRAINT bkn_param_bkn_active_param_fk
FOREIGN KEY (formula_param_id)
REFERENCES urbix.bkn_formula_param (param_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_adq ADD CONSTRAINT bkn_adq_bkn_active_adq_fk
FOREIGN KEY (adq_id)
REFERENCES urbix.bkn_adq (adq_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_adq_param ADD CONSTRAINT bkn_adq_bkn_adq_param_fk
FOREIGN KEY (adq_id)
REFERENCES urbix.bkn_adq (adq_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_adq_param ADD CONSTRAINT bkn_adq_param_bkn_active_adq_param_fk
FOREIGN KEY (adq_param_id)
REFERENCES urbix.bkn_adq_param (adq_param_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_formula_param ADD CONSTRAINT bkn_active_formula_bkn_variable_param_fk
FOREIGN KEY (active_formula_id)
REFERENCES urbix.bkn_active_formula (active_formula_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_formula_param_x_time_filter ADD CONSTRAINT bkn_active_formula_param_bkn_active_formula_param_x_filter_fk
FOREIGN KEY (active_formula_param_id)
REFERENCES urbix.bkn_active_formula_param (active_formula_param_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_active_adq_param ADD CONSTRAINT bkn_active_adq_bkn_active_adq_param_fk
FOREIGN KEY (active_adq_id)
REFERENCES urbix.bkn_active_adq (active_adq_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_sensor ADD CONSTRAINT bkn_active_adq_bkn_sensor_fk
FOREIGN KEY (active_adq_id)
REFERENCES urbix.bkn_active_adq (active_adq_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_measure ADD CONSTRAINT bkn_sensor_bkn_measure_fk
FOREIGN KEY (sensor_id)
REFERENCES urbix.bkn_sensor (sensor_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_sensor_status_log ADD CONSTRAINT bkn_sensor_bkn_sensor_status_log_fk
FOREIGN KEY (sensor_id)
REFERENCES urbix.bkn_sensor (sensor_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_sensor_factor ADD CONSTRAINT bkn_sensor_bkn_sensor_factor_fk
FOREIGN KEY (sensor_id)
REFERENCES urbix.bkn_sensor (sensor_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_sensor_config ADD CONSTRAINT bkn_sensor_bkn_sensor_config_fk
FOREIGN KEY (sensor_id)
REFERENCES urbix.bkn_sensor (sensor_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE urbix.bkn_measure_data ADD CONSTRAINT bkn_measure_masure_data_fk
FOREIGN KEY (measure_id)
REFERENCES urbix.bkn_measure (measure_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

commit;

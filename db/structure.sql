--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cell_changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cell_changes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    commit_id bytea NOT NULL,
    row_id uuid NOT NULL,
    column_id uuid NOT NULL,
    type character varying NOT NULL,
    cell_value text
);


--
-- Name: column_changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE column_changes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    commit_id bytea NOT NULL,
    column_id uuid NOT NULL,
    type character varying NOT NULL,
    column_name character varying
);


--
-- Name: commits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE commits (
    id bytea NOT NULL,
    parent_id bytea NOT NULL
);


--
-- Name: row_changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE row_changes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    commit_id bytea NOT NULL,
    row_id uuid NOT NULL,
    type character varying NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tables (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    head_id bytea NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cell_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cell_changes
    ADD CONSTRAINT cell_changes_pkey PRIMARY KEY (id);


--
-- Name: column_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY column_changes
    ADD CONSTRAINT column_changes_pkey PRIMARY KEY (id);


--
-- Name: commits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id);


--
-- Name: row_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY row_changes
    ADD CONSTRAINT row_changes_pkey PRIMARY KEY (id);


--
-- Name: tables_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tables
    ADD CONSTRAINT tables_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150402030031');

INSERT INTO schema_migrations (version) VALUES ('20150402035657');

INSERT INTO schema_migrations (version) VALUES ('20150403023312');

INSERT INTO schema_migrations (version) VALUES ('20150404170925');

INSERT INTO schema_migrations (version) VALUES ('20150404195357');

INSERT INTO schema_migrations (version) VALUES ('20150404203853');


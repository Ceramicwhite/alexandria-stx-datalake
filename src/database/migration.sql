
-- CreateTable
CREATE TABLE public."transaction" (
	hash varchar NOT NULL,
	tx jsonb NOT NULL,
	processed bool NOT NULL DEFAULT false,
	missing bool NOT NULL DEFAULT false,
    /* JSONB generated columns */
	contract_id text NULL GENERATED ALWAYS AS ((tx -> 'contract_call'::text) ->> 'contract_id'::text) STORED,
	block_height int8 NULL GENERATED ALWAYS AS ((tx -> 'block_height'::text)::bigint) STORED,

	CONSTRAINT "transaction_pkey" PRIMARY KEY (hash)
);

CREATE TABLE public.block (
	hash varchar NOT NULL,
	height int8 NOT NULL,
	"timestamp" timestamp NOT NULL,
	block jsonb NOT NULL,

	CONSTRAINT "block_hash_pkey" PRIMARY KEY (hash),
	CONSTRAINT "block_height_ukey" UNIQUE (height)
);


/* Create indexes for jsonb generated colums */
CREATE INDEX transaction_block_height ON public.transaction USING btree (block_height);
CREATE INDEX transaction_contract_id ON public.transaction USING btree (contract_id);

/* Create function to notify upon block saved */
CREATE OR REPLACE FUNCTION public.notify_block()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare 
	begin 
		perform pg_notify( cast('new_block' as text), new.height::TEXT);
	    return null;
	end
$function$
;

/* Add trigger to notify events */
create trigger notify_blocks after
insert
    on
    public.block for each row execute function notify_block();









-- create a separate user for hasura (if you don't already have one)

CREATE USER hasurauser WITH PASSWORD 'hasurauser';

-- create pgcrypto extension, required for UUID

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- create the schemas required by the hasura cloud system

CREATE SCHEMA IF NOT EXISTS hdb_catalog;


CREATE SCHEMA IF NOT EXISTS hdb_views;


CREATE SCHEMA IF NOT EXISTS hdb_pro_catalog;

-- make the user an owner of the hasura cloud system schemas

ALTER SCHEMA hdb_catalog OWNER TO hasurauser;


ALTER SCHEMA hdb_views OWNER TO hasurauser;


ALTER SCHEMA hdb_pro_catalog OWNER TO hasurauser;

-- grant select permissions on information_schema and pg_catalog
GRANT
SELECT ON ALL TABLES IN SCHEMA information_schema TO hasurauser;

GRANT
SELECT ON ALL TABLES IN SCHEMA pg_catalog TO hasurauser;

-- grant all privileges on all tables in the public schema (this is optional and can be customized)
GRANT USAGE ON SCHEMA public TO hasurauser;

GRANT ALL ON ALL TABLES IN SCHEMA public TO hasurauser;

GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO hasurauser;

GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO hasurauser;

-- Similarly add these for other schemas as well, if you have any
-- GRANT USAGE ON SCHEMA <schema-name> TO hasurauser;
-- GRANT ALL ON ALL TABLES IN SCHEMA <schema-name> TO hasurauser;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA <schema-name> TO hasurauser;
-- GRANT ALL ON ALL FUNCTIONS IN SCHEMA <schema-name> TO hasurauser;
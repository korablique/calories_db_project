-- Подключаем расширение dblink (однажды подключил - используется всегда)
CREATE EXTENSION dblink;


-- функция создания БД с заданым именем
CREATE OR REPLACE FUNCTION f_create_calories_db(dbname text)
  RETURNS void AS
$func$
BEGIN
	-- проверка на существование БД с таким же именем
	IF EXISTS (SELECT 1 FROM pg_database WHERE datname = dbname) THEN
	   -- Возвращаем сообщение (не ошибку)
	   RAISE NOTICE 'Database already exists'; 
	ELSE
	   -- выполняем SQL запрос на создание БД. оператор || - конкатенация
	   -- current_database() - возврашает название БД в которой сейчас выполняется транзакция
	   -- принцип работы dblink_exec: подключается к указанной бд(в примере - текущая), и выполняет запрос, 
	   -- переданный вторым аргументом.
	   -- для доп.информации можно добавить hostaddr=127.0.0.1 port=5432 dbname=mydb user=postgres password=mypasswd
	   PERFORM dblink_exec('dbname=' || current_database()   -- current db
	                     , 'CREATE DATABASE ' || quote_ident(dbname) || ' WITH TEMPLATE calories_db_template OWNER postgres;');
	END IF;

END
$func$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION f_drop_db(db_to_delete text)
  RETURNS void AS
$func$
BEGIN
	PERFORM dblink_exec('dbname=' || current_database()
	                  ,'DROP DATABASE ' || quote_ident(db_to_delete));
END
$func$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION f_init_tables()
RETURNS void AS 
$func$
BEGIN
	CREATE TABLE IF NOT EXISTS user_parameters (
		id SERIAL PRIMARY KEY,
		name TEXT NOT NULL
	);

	CREATE TABLE IF NOT EXISTS foodstuff (
		id SERIAL PRIMARY KEY,
		name TEXT NOT NULL,
		lower_case_name TEXT,  
		protein NUMERIC(4, 1) CHECK (protein BETWEEN 0 and 100),  --max value is 100 -> 3 digits + 1 digit after the decimal point--
		fats NUMERIC(4, 1) CHECK (fats BETWEEN 0 and 100),
		carbs NUMERIC(4, 1) CHECK (carbs BETWEEN 0 and 100),
		calories NUMERIC(4, 1)  --max value is 900--
	);

	CREATE TABLE IF NOT EXISTS history (
		entry_id SERIAL PRIMARY KEY,
		user_id INTEGER REFERENCES user_parameters,
		date DATE NOT NULL DEFAULT CURRENT_DATE,
		foodstuff_id INTEGER REFERENCES foodstuff, 
		foodstuff_weight INTEGER CHECK (foodstuff_weight > 0)
	);

	CREATE TABLE IF NOT EXISTS exercise (
		id SERIAL PRIMARY KEY,
		user_id INTEGER REFERENCES user_parameters,
		date DATE NOT NULL DEFAULT CURRENT_DATE,
		calories NUMERIC(5, 1) CHECK (calories >= 0)  --max value ~ 9000
	);

	CREATE INDEX IF NOT EXISTS foodstuff_lowercase_idx ON foodstuff (lower_case_name);

	CREATE INDEX IF NOT EXISTS foodstuff_calories_idx ON foodstuff (calories);
END;
$func$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION f_init_triggers()
RETURNS void AS
$func$
BEGIN
	CREATE OR REPLACE FUNCTION f_calculate_calories()
	RETURNS trigger AS $$
	BEGIN
		NEW.calories := NEW.protein * 4 + NEW.fats * 9 + NEW.carbs * 4;
		RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION f_foodstuff_name_to_lowercase()
	RETURNS trigger AS $$
	BEGIN
		NEW.lower_case_name := lower(NEW.name);
		RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE OR REPLACE TRIGGER calculate_calories
		BEFORE INSERT OR UPDATE ON foodstuff
		FOR EACH ROW
		EXECUTE FUNCTION f_calculate_calories();

	CREATE OR REPLACE TRIGGER foodstuff_name_to_lowercase
		BEFORE INSERT OR UPDATE ON foodstuff
		FOR EACH ROW
		EXECUTE FUNCTION f_foodstuff_name_to_lowercase();
END;
$func$ LANGUAGE plpgsql;


-- INSERT INTO foodstuff (name, protein, fats, carbs) VALUES ('Apple', 0.2, 0, 10);
-- INSERT INTO foodstuff (name, protein, fats, carbs) VALUES ('BANANA', 1, 0, 20);

CREATE OR REPLACE FUNCTION f_add_foodstuff(name foodstuff.name%TYPE, protein foodstuff.protein%TYPE, fats foodstuff.fats%TYPE, carbs foodstuff.carbs%TYPE)
RETURNS void AS $$
BEGIN
	INSERT INTO foodstuff (name, protein, fats, carbs) VALUES (name, protein, fats, carbs);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION f_delete_foodstuff(foodstuff_id_arg foodstuff.id%TYPE)
RETURNS void AS $$
BEGIN
	DELETE FROM history WHERE history.foodstuff_id = foodstuff_id_arg;
	DELETE FROM foodstuff WHERE foodstuff.id = foodstuff_id_arg;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION f_get_all_foodstuffs()
RETURNS TABLE (
	id INTEGER,
	name TEXT,
	lower_case_name TEXT,  
	protein NUMERIC,
	fats NUMERIC,
	carbs NUMERIC,
	calories NUMERIC
) AS $$
BEGIN
	return QUERY SELECT * FROM foodstuff;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION f_am_I_admin()
RETURNS BOOL AS $$
DECLARE
    c INTEGER;
BEGIN
	c := count(*) FROM pg_roles WHERE rolname = CURRENT_USER AND rolsuper = true;
	IF c = 1 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;


--creating roles and users--
CREATE ROLE user_role;
GRANT ALL PRIVILEGES ON TABLE foodstuff TO user_role;
GRANT ALL PRIVILEGES ON TABLE history TO user_role;
GRANT ALL PRIVILEGES ON TABLE exercise TO user_role;
ALTER ROLE user_role WITH LOGIN;

CREATE ROLE glasha login password 'pass';
CREATE ROLE petya login password 'pass';
GRANT user_role TO glasha;
GRANT user_role TO petya;

GRANT ALL PRIVILEGES ON TABLE foodstuff TO glasha;
GRANT ALL PRIVILEGES ON TABLE history TO glasha;
GRANT ALL PRIVILEGES ON TABLE exercise TO glasha;

GRANT ALL PRIVILEGES ON TABLE foodstuff TO petya;
GRANT ALL PRIVILEGES ON TABLE history TO petya;
GRANT ALL PRIVILEGES ON TABLE exercise TO petya;

GRANT ALL PRIVILEGES ON TABLE foodstuff_id_seq TO glasha;
GRANT ALL PRIVILEGES ON TABLE history_entry_id_seq TO glasha;
GRANT ALL PRIVILEGES ON TABLE exercise_id_seq TO glasha;

GRANT ALL PRIVILEGES ON TABLE foodstuff_id_seq TO petya;
GRANT ALL PRIVILEGES ON TABLE history_entry_id_seq TO petya;
GRANT ALL PRIVILEGES ON TABLE exercise_id_seq TO petya;


--update row with foodstuff--
CREATE OR REPLACE FUNCTION f_update_foodstuff(
	foodstuff_id foodstuff.id%TYPE,
	new_name foodstuff.name%TYPE,
	new_protein foodstuff.protein%TYPE,
	new_fats foodstuff.fats%TYPE,
	new_carbs foodstuff.carbs%TYPE)
RETURNS void AS $$
BEGIN
	UPDATE foodstuff SET (name, protein, fats, carbs) = (new_name, new_protein, new_fats, new_carbs) WHERE foodstuff.id = foodstuff_id;
END;
$$ LANGUAGE plpgsql;


--search for foodstuff--
CREATE OR REPLACE FUNCTION f_search_foodstuffs(name_substr foodstuff.name%TYPE)
RETURNS TABLE (
	id INTEGER,
	name TEXT,
	lower_case_name TEXT,  
	protein NUMERIC,
	fats NUMERIC,
	carbs NUMERIC,
	calories NUMERIC
) AS $$
BEGIN
	return QUERY SELECT * FROM foodstuff WHERE foodstuff.lower_case_name LIKE '%' || lower(name_substr) || '%';
END;
$$ LANGUAGE plpgsql;


--delete all foodstuffs by substring--
CREATE OR REPLACE FUNCTION f_delete_foodstuffs_by_substr(name_substr foodstuff.name%TYPE)
RETURNS void AS $$
BEGIN
	DELETE FROM foodstuff WHERE foodstuff.lower_case_name LIKE '%' || lower(name_substr) || '%';
END;
$$ LANGUAGE plpgsql;


--delete all foodstuffs--
CREATE OR REPLACE FUNCTION f_delete_all_foodstuffs()
RETURNS void AS $$
BEGIN
	DELETE FROM foodstuff;
END;
$$ LANGUAGE plpgsql;

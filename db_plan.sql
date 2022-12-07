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
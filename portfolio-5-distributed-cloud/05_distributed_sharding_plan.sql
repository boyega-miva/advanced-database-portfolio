CREATE TABLE GlobalPatients (
    patient_id BIGINT GENERATED ALWAYS AS IDENTITY,
    region_code VARCHAR(10) NOT NULL,
    anonymised_uuid UUID DEFAULT uuid_generate_v4(),
    dob DATE NOT NULL,
    PRIMARY KEY (patient_id, region_code)
) PARTITION BY LIST (region_code);

CREATE TABLE Patients_Lagos PARTITION OF GlobalPatients
    FOR VALUES IN ('NG-LAG');

CREATE TABLE Patients_Abuja PARTITION OF GlobalPatients
    FOR VALUES IN ('NG-ABJ');

INSERT INTO GlobalPatients (region_code, dob) 
VALUES ('NG-LAG', '1992-05-18'), ('NG-ABJ', '1988-11-20');

-- Query partition directly to prove sharding routing
SELECT * FROM Patients_Lagos;

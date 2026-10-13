CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE Facilities (
    facility_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    facility_name VARCHAR(150) NOT NULL,
    facility_type VARCHAR(50) NOT NULL CHECK (facility_type IN ('Hospital', 'Regional Warehouse', 'Clinic')),
    city VARCHAR(100) NOT NULL,
    ndpa_compliance_code VARCHAR(64) UNIQUE NOT NULL
);

CREATE TABLE Staff (
    staff_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    facility_id INT NOT NULL REFERENCES Facilities(facility_id) ON DELETE RESTRICT,
    full_name VARCHAR(120) NOT NULL,
    role_type VARCHAR(50) NOT NULL CHECK (role_type IN ('Chief Physician', 'Pharmacist', 'Logistics Lead', 'Compliance Auditor')),
    email_hash VARCHAR(64) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE Patients (
    patient_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    facility_id INT NOT NULL REFERENCES Facilities(facility_id) ON DELETE RESTRICT,
    anonymised_uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    dob DATE NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M', 'F')),
    risk_classification VARCHAR(30) DEFAULT 'Standard' NOT NULL
);

CREATE TABLE Medications (
    medication_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    formulation VARCHAR(60) NOT NULL,
    requires_cold_chain BOOLEAN DEFAULT FALSE NOT NULL,
    unit_cost NUMERIC(12, 2) NOT NULL CHECK (unit_cost >= 0.00)
);

CREATE TABLE Prescriptions (
    prescription_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    staff_id INT NOT NULL REFERENCES Staff(staff_id) ON DELETE RESTRICT,
    prescribed_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(30) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Dispensed', 'Cancelled'))
);

CREATE TABLE PrescriptionItems (
    prescription_id INT NOT NULL REFERENCES Prescriptions(prescription_id) ON DELETE CASCADE,
    medication_id INT NOT NULL REFERENCES Medications(medication_id) ON DELETE RESTRICT,
    dosage_mg INT NOT NULL CHECK (dosage_mg > 0),
    quantity_prescribed INT NOT NULL CHECK (quantity_prescribed > 0),
    PRIMARY KEY (prescription_id, medication_id)
);

CREATE TABLE Shipments (
    shipment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    origin_facility INT NOT NULL REFERENCES Facilities(facility_id),
    dest_facility INT NOT NULL REFERENCES Facilities(facility_id),
    shipment_status VARCHAR(30) DEFAULT 'In-Transit' CHECK (shipment_status IN ('Staged', 'In-Transit', 'Delivered', 'Compromised')),
    dispatched_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IoTTelemetry (
    telemetry_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipment_id INT NOT NULL REFERENCES Shipments(shipment_id) ON DELETE CASCADE,
    timestamp_recorded TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    recorded_temp_celsius NUMERIC(5, 2) NOT NULL,
    tamper_flag BOOLEAN DEFAULT FALSE NOT NULL
);

-- Seed testing batch
INSERT INTO Facilities (facility_name, facility_type, city, ndpa_compliance_code)
VALUES ('Ikeja Distribution Hub', 'Regional Warehouse', 'Lagos', 'NDPA-LAG-002');

INSERT INTO Patients (facility_id, dob, gender, risk_classification)
VALUES (1, '1985-04-12', 'M', 'High');

INSERT INTO Staff (facility_id, full_name, role_type, email_hash)
VALUES (1, 'Dr. T. Balogun', 'Chief Physician', 'hash_tbalogun_9982');

INSERT INTO Medications (product_name, formulation, requires_cold_chain, unit_cost)
VALUES ('mRNA Booster Vaccine', 'Vial', TRUE, 4500.00);

INSERT INTO Prescriptions (patient_id, staff_id, status)
VALUES (1, 1, 'Pending');

INSERT INTO PrescriptionItems (prescription_id, medication_id, dosage_mg, quantity_prescribed)
VALUES (1, 1, 50, 20);

-- Unoptimised Plan Analysis
EXPLAIN ANALYZE
SELECT 
    f.facility_name, 
    m.product_name, 
    SUM(pi.quantity_prescribed) AS total_units_demanded
FROM Facilities f
JOIN Patients p ON f.facility_id = p.facility_id
JOIN Prescriptions pr ON p.patient_id = pr.patient_id
JOIN PrescriptionItems pi ON pr.prescription_id = pi.prescription_id
JOIN Medications m ON pi.medication_id = m.medication_id
WHERE pr.status = 'Pending' 
  AND m.requires_cold_chain = TRUE
GROUP BY f.facility_name, m.product_name;

-- Create Covering & Partial Indexes
CREATE INDEX idx_prescriptions_perf 
ON Prescriptions(status, prescription_id, patient_id) 
WHERE status = 'Pending';

CREATE INDEX idx_medications_coldchain 
ON Medications(medication_id) 
INCLUDE (product_name) 
WHERE requires_cold_chain = TRUE;

-- Optimised Plan Analysis
EXPLAIN ANALYZE
SELECT 
    f.facility_name, 
    m.product_name, 
    SUM(pi.quantity_prescribed) AS total_units_demanded
FROM Prescriptions pr
JOIN PrescriptionItems pi ON pr.prescription_id = pi.prescription_id
JOIN Medications m ON pi.medication_id = m.medication_id
JOIN Patients p ON pr.patient_id = p.patient_id
JOIN Facilities f ON p.facility_id = f.facility_id
WHERE pr.status = 'Pending' 
  AND m.requires_cold_chain = TRUE
GROUP BY f.facility_name, m.product_name;

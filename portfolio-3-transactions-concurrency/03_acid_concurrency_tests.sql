BEGIN;

SAVEPOINT validation_step;

-- Pessimistic locking to prevent concurrent lost updates
SELECT prescription_id, status 
FROM Prescriptions 
WHERE prescription_id = 1 
FOR UPDATE;

UPDATE Prescriptions
SET status = 'Dispensed'
WHERE prescription_id = 1 AND status = 'Pending';

UPDATE Medications
SET unit_cost = unit_cost
WHERE medication_id = 1;

COMMIT;

-- Verify final state
SELECT prescription_id, status FROM Prescriptions WHERE prescription_id = 1;

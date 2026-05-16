CREATE TABLE patients (
    patient_id   INT PRIMARY KEY AUTO_INCREMENT,
    full_name    VARCHAR(100) NOT NULL,
    age          INT,
    contact      VARCHAR(15),
    created_at   DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE medicines (
    medicine_id  INT PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    description  VARCHAR(255)
);

CREATE TABLE schedules (
    schedule_id  INT PRIMARY KEY AUTO_INCREMENT,
    patient_id   INT NOT NULL,
    medicine_id  INT NOT NULL,
    dosage       VARCHAR(50),
    time_of_day  ENUM('Morning', 'Afternoon', 'Night') NOT NULL,
    start_date   DATE,
    end_date     DATE,
    is_active    BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (patient_id)  REFERENCES patients(patient_id),
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);

CREATE TABLE intake_log (
    log_id       INT PRIMARY KEY AUTO_INCREMENT,
    schedule_id  INT NOT NULL,
    taken_date   DATE NOT NULL,
    is_taken     BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id)
);

INSERT INTO patients (full_name, age, contact) VALUES
('Ramesh Panda',   54, '9437012345'),
('Priya Nayak',    32, '8763049210'),
('Ankit Sharma',   28, '7894561230'),
('Sita Devi',      61, '9861023478'),
('Mohan Das',      45, '8917465321');

INSERT INTO medicines (name, category, description) VALUES
('Metformin',      'Antidiabetic',     '500mg tablet for blood sugar control'),
('Amlodipine',     'Antihypertensive', '5mg tablet for blood pressure'),
('Vitamin D3',     'Supplement',       '1000 IU softgel'),
('Omeprazole',     'Antacid',          '20mg capsule before meals'),
('Iron Supplement','Supplement',       '150mg ferrous sulphate capsule'),
('Omega-3',        'Supplement',       '1000mg fish oil softgel');

INSERT INTO schedules (patient_id, medicine_id, dosage, time_of_day, start_date, end_date) VALUES
(1, 1, '1 tablet',   'Morning',   '2025-05-01', '2025-07-31'),
(1, 2, '1 tablet',   'Night',     '2025-05-01', '2025-07-31'),
(2, 3, '1 softgel',  'Morning',   '2025-04-15', '2025-06-15'),
(2, 5, '1 capsule',  'Afternoon', '2025-04-15', '2025-06-15'),
(3, 4, '1 capsule',  'Morning',   '2025-05-10', '2025-05-25'),
(4, 1, '1 tablet',   'Morning',   '2025-03-01', '2025-08-31'),
(4, 2, '1 tablet',   'Afternoon', '2025-03-01', '2025-08-31'),
(5, 6, '2 softgels', 'Night',     '2025-05-05', '2025-07-05');

INSERT INTO intake_log (schedule_id, taken_date, is_taken) VALUES
(1, '2025-05-15', TRUE),
(2, '2025-05-15', TRUE),
(3, '2025-05-15', FALSE),
(4, '2025-05-15', TRUE),
(5, '2025-05-15', FALSE),
(6, '2025-05-15', TRUE),
(7, '2025-05-15', TRUE),
(8, '2025-05-15', FALSE);

-- Full schedule for a specific patient
SELECT
    p.full_name,
    m.name          AS medicine,
    s.dosage,
    s.time_of_day,
    s.start_date,
    s.end_date
FROM schedules s
JOIN patients  p ON s.patient_id  = p.patient_id
JOIN medicines m ON s.medicine_id = m.medicine_id
WHERE p.full_name = 'Ramesh Panda' AND s.is_active = TRUE;

-- All pending medicines for today
SELECT
    p.full_name,
    m.name      AS medicine,
    s.time_of_day,
    il.taken_date
FROM intake_log il
JOIN schedules  s  ON il.schedule_id  = s.schedule_id
JOIN patients   p  ON s.patient_id    = p.patient_id
JOIN medicines  m  ON s.medicine_id   = m.medicine_id
WHERE il.taken_date = CURRENT_DATE AND il.is_taken = FALSE
ORDER BY s.time_of_day;

-- Intake summary per patient
SELECT
    p.full_name,
    COUNT(*)                                      AS total,
    SUM(CASE WHEN il.is_taken = TRUE THEN 1 END)  AS taken,
    SUM(CASE WHEN il.is_taken = FALSE THEN 1 END) AS pending
FROM intake_log il
JOIN schedules s ON il.schedule_id = s.schedule_id
JOIN patients  p ON s.patient_id   = p.patient_id
WHERE il.taken_date = CURRENT_DATE
GROUP BY p.full_name;

-- Most prescribed medicine
SELECT
    m.name,
    COUNT(s.schedule_id) AS times_prescribed
FROM schedules  s
JOIN medicines  m ON s.medicine_id = m.medicine_id
GROUP BY m.name
ORDER BY times_prescribed DESC;

-- Mark a medicine as taken
UPDATE intake_log
SET    is_taken = TRUE
WHERE  schedule_id = 3 AND taken_date = CURRENT_DATE;

-- Deactivate schedules whose end date has passed
UPDATE schedules
SET    is_active = FALSE
WHERE  end_date < CURRENT_DATE;

DELETE FROM schedules
WHERE  schedule_id = 5;

-- Clear intake logs older than 90 days
DELETE FROM intake_log
WHERE  taken_date < DATE_SUB(CURRENT_DATE, INTERVAL 90 DAY);

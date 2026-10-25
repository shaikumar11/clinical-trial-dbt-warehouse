"""Generate synthetic clinical trial source extracts with deliberate data quality problems."""
import csv, random, datetime as dt
from pathlib import Path

random.seed(42)
OUT = Path(__file__).resolve().parent.parent / "data" / "raw"
OUT.mkdir(parents=True, exist_ok=True)

STUDIES = [("ST001", "CardioShield Phase III", "Cardiology", "III"),
           ("ST002", "OncoPath Phase II", "Oncology", "II"),
           ("ST003", "GlucoBalance Phase III", "Endocrinology", "III")]
COUNTRIES = [("India", "Mumbai"), ("India", "Hyderabad"), ("Poland", "Warsaw"),
             ("Germany", "Berlin"), ("USA", "Cincinnati"), ("Spain", "Madrid")]
VISIT_TYPES = ["Screening", "Baseline", "Week 4", "Week 8", "Week 12"]
AE_TERMS = [("Headache", "Mild"), ("Nausea", "Mild"), ("Fatigue", "Moderate"),
            ("Rash", "Mild"), ("Hypertension", "Severe"), ("Dizziness", "Moderate")]


def write(name, header, rows):
    with open(OUT / name, "w", newline="") as f:
        w = csv.writer(f); w.writerow(header); w.writerows(rows)


def main():
    write("studies.csv", ["study_id", "study_name", "therapeutic_area", "phase"], STUDIES)

    sites = []
    for i in range(1, 25):
        country, city = random.choice(COUNTRIES)
        study = random.choice(STUDIES)[0]
        sites.append((f"SITE{i:03d}", study, f"{city} Clinical Centre {i}", country, city))
    write("sites.csv", ["site_id", "study_id", "site_name", "country", "city"], sites)

    subjects, visits, aes = [], [], []
    start = dt.date(2025, 1, 1)
    sid = 0
    for site in sites:
        for _ in range(random.randint(8, 20)):
            sid += 1
            subj = f"SUBJ{sid:04d}"
            enrolled = start + dt.timedelta(days=random.randint(0, 240))
            status = random.choices(["Active", "Completed", "Withdrawn"], [60, 25, 15])[0]
            subjects.append((subj, site[0], enrolled.isoformat(), random.randint(18, 80),
                             random.choice(["M", "F", "m", "f", "Male", "Female"]), status))
            n_visits = {"Completed": 5, "Active": random.randint(2, 4), "Withdrawn": random.randint(1, 3)}[status]
            for v in range(n_visits):
                vdate = enrolled + dt.timedelta(days=28 * v + random.randint(0, 4))
                sbp = random.randint(105, 170)
                visits.append((f"V{len(visits)+1:06d}", subj, VISIT_TYPES[v], vdate.isoformat(), sbp))
            if random.random() < 0.35:
                term, sev = random.choice(AE_TERMS)
                ae_date = enrolled + dt.timedelta(days=random.randint(5, 80))
                aes.append((f"AE{len(aes)+1:05d}", subj, term, sev, ae_date.isoformat()))

    # deliberate problems for the pipeline to catch and handle
    visits.append(visits[0])                                      # exact duplicate row
    visits.append(("V999998", "SUBJ9999", "Week 4", "2025-06-01", 120))   # orphan subject
    visits.append(("V999999", subjects[0][0], "Week 4", "2025-06-01", ""))  # missing measurement
    subjects.append(subjects[3])                                  # duplicate subject row

    write("subjects.csv", ["subject_id", "site_id", "enrollment_date", "age", "sex", "status"], subjects)
    write("visits.csv", ["visit_id", "subject_id", "visit_type", "visit_date", "systolic_bp"], visits)
    write("adverse_events.csv", ["ae_id", "subject_id", "ae_term", "severity", "ae_date"], aes)
    print(f"studies={len(STUDIES)} sites={len(sites)} subjects={len(subjects)} visits={len(visits)} aes={len(aes)}")


if __name__ == "__main__":
    main()

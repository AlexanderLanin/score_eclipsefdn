import json
import subprocess
import time
from datetime import datetime
from pathlib import Path
from typing import Any

import pandas as pd

# --- Settings ---
REPO = "AlexanderLanin/score_eclipsefdn"
WORKFLOW = "build-page.yml"
LIMIT = "50"
CUTOFF_TIME = datetime.fromisoformat("2025-06-14T19:10:00+00:00")
CACHE_DIR = Path(".cache")
CACHE_DIR.mkdir(exist_ok=True)


# --- Helpers ---
def decode_job_name(name: str) -> str:
    if name.startswith("deb_install"):
        base = "Download and install .deb files"
    elif name.startswith("deb_cached"):
        base = "Get .deb files from GitHub cache and install them"
    elif name.startswith("via_action"):
        base = "Install via setup-graphviz action"
    elif name.startswith("via_apt_install"):
        base = "Install via apt"
    else:
        raise ValueError(f"Unknown job name format: {name}")

    extras = []
    if "_update" in name:
        extras.append("no apt update")
    if "_recommends" in name:
        extras.append("no recommends")
    if "_mandb" in name:
        extras.append("no mandb")

    return f"{base}, " + ", ".join(extras) if extras else base


# --- Step 1: Fetch Workflow Runs ---
print(f"Fetching latest {LIMIT} runs for {WORKFLOW}...\n")

run_list = subprocess.run(
    [
        "gh",
        "run",
        "list",
        "--repo",
        REPO,
        "--workflow",
        WORKFLOW,
        "--limit",
        LIMIT,
        "--json",
        "databaseId,createdAt,conclusion",
    ],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True,
)

if run_list.returncode != 0:
    print("❌ Failed to fetch workflow runs:", run_list.stderr)
    exit(1)

runs = json.loads(run_list.stdout)
filtered_runs = [
    r
    for r in runs
    if datetime.fromisoformat(r["createdAt"].replace("Z", "+00:00")) >= CUTOFF_TIME
]

print(f"Found {len(filtered_runs)} successful runs after cutoff\n")

# --- Step 2: Fetch Jobs (cached) ---
records: list[dict[str, object]] = []

for run in filtered_runs:
    run_id = run["databaseId"]
    cache_file = CACHE_DIR / f"jobs_{run_id}"
    if cache_file.exists():
        print(f"Using cached data for run {run_id}")
        with cache_file.open("r") as f:
            job_data = json.load(f)
    else:
        print(f"Fetching jobs for run {run_id}...")
        run_detail = subprocess.run(
            ["gh", "run", "view", str(run_id), "--repo", REPO, "--json", "jobs"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if run_detail.returncode != 0:
            print(f"⚠️ Skipping run {run_id}: {run_detail.stderr.strip()}")
            continue
        job_data = json.loads(run_detail.stdout)
        with cache_file.open("w") as f:
            json.dump(job_data, f)

    for job in job_data.get("jobs", []):
        start = job.get("startedAt")
        end = job.get("completedAt")
        if not (start and end):
            continue
        t_start = datetime.fromisoformat(start.replace("Z", "+00:00"))
        t_end = datetime.fromisoformat(end.replace("Z", "+00:00"))
        records.append(
            {"job_name": job["name"], "duration": (t_end - t_start).total_seconds()}
        )

    time.sleep(0.5)

# --- Step 3: Summarize ---
if not records:
    print("❌ No job durations available. Check if job start/end timestamps exist.")
    exit(1)

df = pd.DataFrame(records)

summary = (
    df.groupby("job_name")["duration"]
    .agg(
        mean="mean",
        median="median",
        in_30_60=lambda x: ((x > 30) & (x <= 60)).sum(),
        over_60s=lambda x: (x > 60).sum(),
    )
    .reset_index()
)

summary["method"] = summary["job_name"].apply(decode_job_name)

# --- Step 4: Print Markdown Table ---
print("## 📊 Per-Job Duration Summary (Successful Runs After Cutoff)\n")
print(f"\nℹ️ Based on {len(filtered_runs)} successful workflow runs")

print("| Method | Mean (s) | Median (s) | 30–60s | >60s |")
print("|--------|----------|------------|--------|------|")

for _, row in summary.iterrows():
    mean: float = row["mean"]
    median: float = row["median"]
    in_30_60 = int(row["in_30_60"])
    over_60s = int(row["over_60s"])
    emoji_mean = "🟢" if mean <= 10 else "🟡" if mean <= 20 else "🔴"
    emoji_median = "🟢" if median <= 10 else "🟡" if median <= 20 else "🔴"
    print(
        f"| {row['method']} | {emoji_mean} {mean:.1f} | {emoji_median} {median:.1f} | {in_30_60} | {over_60s} |"
    )

#!/usr/bin/env python3
"""Generate benchmark comparison reports from raw CSV data."""

import csv
import json
import os
import sys
import statistics
from collections import defaultdict
from pathlib import Path

ROOT_DIR = Path(__file__).parent.parent
RESULTS_DIR = ROOT_DIR / "results"
REPORT_TEMPLATE = Path(__file__).parent / "templates" / "report.html"
BASELINE_ENGINE = "lua"


def load_system_info(results_dir):
    json_file = results_dir / "system_info.json"
    if json_file.exists():
        with open(json_file) as f:
            return json.load(f)
    return {}


def find_latest_results():
    if len(sys.argv) > 1:
        p = Path(sys.argv[1])
        if p.exists():
            return p.resolve()
        print(f"[ERROR] Specified results path not found: {p}")
        sys.exit(1)

    if not RESULTS_DIR.exists():
        print("[ERROR] No results directory found. Run 'make bench' first.")
        sys.exit(1)

    latest = RESULTS_DIR / "latest"
    if latest.is_symlink() or latest.is_dir():
        return latest.resolve()

    dirs = sorted([d for d in RESULTS_DIR.iterdir() if d.is_dir()])
    if not dirs:
        print("[ERROR] No results found. Run 'make bench' first.")
        sys.exit(1)
    return dirs[-1]


def load_csv(results_dir):
    csv_file = results_dir / "raw.csv"
    rows = []
    with open(csv_file) as f:
        reader = csv.DictReader(f)
        for row in reader:
            row["wall_ms"] = float(row["wall_ms"])
            row["user_ms"] = float(row["user_ms"])
            row["sys_ms"] = float(row["sys_ms"])
            row["peak_rss_kb"] = int(row["peak_rss_kb"])
            row["run"] = int(row["run"])
            rows.append(row)
    return rows


def compute_stats(rows):
    """Group by (engine, benchmark) and compute median wall_ms and peak_rss."""
    grouped = defaultdict(list)
    for row in rows:
        key = (row["engine"], row["benchmark"], row["category"])
        grouped[key].append(row)

    stats = {}
    for (engine, bench, category), runs in grouped.items():
        wall_times = [r["wall_ms"] for r in runs]
        rss_values = [r["peak_rss_kb"] for r in runs]
        stats[(engine, bench)] = {
            "engine": engine,
            "benchmark": bench,
            "category": category,
            "wall_ms": statistics.median(wall_times),
            "wall_mean": statistics.mean(wall_times),
            "wall_stdev": statistics.stdev(wall_times) if len(wall_times) > 1 else 0,
            "peak_rss_kb": statistics.median(rss_values),
            "runs": len(runs),
        }
    return stats


def compute_relative(stats):
    """Compute relative performance vs baseline engine."""
    benchmarks = sorted(set(b for (_, b) in stats.keys()))
    engines = sorted(set(e for (e, _) in stats.keys()))

    relative = {}
    for bench in benchmarks:
        baseline = stats.get((BASELINE_ENGINE, bench))
        if not baseline or baseline["wall_ms"] == 0:
            continue
        base_wall = baseline["wall_ms"]
        base_rss = baseline["peak_rss_kb"]
        for engine in engines:
            s = stats.get((engine, bench))
            if not s:
                continue
            relative[(engine, bench)] = {
                **s,
                "relative_time": s["wall_ms"] / base_wall if base_wall > 0 else 0,
                "relative_rss": s["peak_rss_kb"] / base_rss if base_rss > 0 else 0,
                "baseline_ms": base_wall,
            }
    return relative


def compute_category_summary(relative):
    """Compute per-category average relative time."""
    cat_data = defaultdict(lambda: defaultdict(list))
    for (engine, bench), data in relative.items():
        cat_data[data["category"]][engine].append(data["relative_time"])

    summary = {}
    for category, engines_data in sorted(cat_data.items()):
        summary[category] = {}
        for engine, times in sorted(engines_data.items()):
            summary[category][engine] = {
                "avg_relative": statistics.mean(times),
                "median_relative": statistics.median(times),
                "count": len(times),
            }
    return summary


def compute_overall(stats):
    """Compute overall total time per engine (sum of medians)."""
    engine_totals = defaultdict(float)
    engine_category_totals = defaultdict(lambda: defaultdict(float))

    for (engine, bench), s in stats.items():
        engine_totals[engine] += s["wall_ms"]
        engine_category_totals[engine][s["category"]] += s["wall_ms"]

    engines_sorted = sorted(engine_totals.keys(), key=lambda e: engine_totals[e])

    baseline_total = engine_totals.get(BASELINE_ENGINE, 1)
    overall = []
    for engine in engines_sorted:
        total = engine_totals[engine]
        overall.append({
            "engine": engine,
            "total_ms": total,
            "relative": total / baseline_total if baseline_total > 0 else 0,
            "category_breakdown": dict(engine_category_totals[engine]),
        })
    return overall


def generate_markdown(stats, relative, cat_summary, overall, results_dir, system_info):
    lines = []
    lines.append("# lua-js-benchmark Report")
    lines.append("")
    lines.append(f"Results from: `{results_dir.name}`")
    lines.append(f"Baseline: **{BASELINE_ENGINE}** (1.00x)")
    lines.append("")

    # Test Environment
    sys_info = system_info.get("system", {})
    if sys_info:
        lines.append("## Test Environment")
        lines.append("")
        lines.append("| Item | Value |")
        lines.append("|------|-------|")
        lines.append(f"| Date | {sys_info.get('date', '-')} |")
        lines.append(f"| OS | {sys_info.get('os', '-')} {sys_info.get('kernel', '')} |")
        lines.append(f"| Architecture | {sys_info.get('arch', '-')} |")
        lines.append(f"| CPU | {sys_info.get('cpu', '-')} |")
        lines.append(f"| CPU Cores | {sys_info.get('cpu_cores', '-')} |")
        lines.append(f"| Memory | {sys_info.get('memory', '-')} |")
        lines.append("")

    engine_info = system_info.get("engines", {})
    if engine_info:
        lines.append("## Engines")
        lines.append("")
        lines.append("| Engine | Name | Version |")
        lines.append("|--------|------|---------|")
        for eid, edata in engine_info.items():
            lines.append(f"| {eid} | {edata.get('display_name', eid)} | {edata.get('version', '-')} |")
        lines.append("")

    # Overall
    lines.append("## Overall Performance")
    lines.append("")
    lines.append("| Rank | Engine | Total Time (ms) | vs Lua | ")
    lines.append("|------|--------|----------------:|-------:|")
    for i, o in enumerate(overall, 1):
        base_mark = " (baseline)" if o["engine"] == BASELINE_ENGINE else ""
        lines.append(f"| #{i} | {o['engine']}{base_mark} | {o['total_ms']:.0f} | {o['relative']:.2f}x |")
    lines.append("")

    # Category summary
    lines.append("## Performance by Category")
    lines.append("")
    engines = sorted(set(e for (e, _) in relative.keys()))
    header = "| Category | " + " | ".join(engines) + " |"
    sep = "|----------|" + "|".join(["-------:" for _ in engines]) + "|"
    lines.append(header)
    lines.append(sep)
    for category in sorted(cat_summary.keys()):
        row = f"| {category} |"
        for engine in engines:
            data = cat_summary[category].get(engine)
            if data:
                val = data["avg_relative"]
                if engine == BASELINE_ENGINE:
                    row += " 1.00x |"
                else:
                    row += f" {val:.2f}x |"
            else:
                row += " - |"
        lines.append(row)
    lines.append("")

    # Detailed results
    lines.append("## Detailed Results")
    lines.append("")
    header = f"| Benchmark | Category | {BASELINE_ENGINE} (ms) | " + " | ".join(
        e for e in engines if e != BASELINE_ENGINE) + " |"
    sep = "|-----------|----------|------------:|" + "|".join(
        ["-------:" for e in engines if e != BASELINE_ENGINE]) + "|"
    lines.append(header)
    lines.append(sep)

    benchmarks = sorted(set(b for (_, b) in relative.keys()))
    for bench in benchmarks:
        base = relative.get((BASELINE_ENGINE, bench))
        if not base:
            continue
        row = f"| {bench} | {base['category']} | {base['wall_ms']:.0f} |"
        for engine in engines:
            if engine == BASELINE_ENGINE:
                continue
            data = relative.get((engine, bench))
            if data:
                row += f" {data['relative_time']:.2f}x |"
            else:
                row += " - |"
        lines.append(row)
    lines.append("")

    # Memory
    lines.append("## Memory Usage (Peak RSS)")
    lines.append("")
    header = "| Benchmark | " + " | ".join(f"{e} (KB)" for e in engines) + " |"
    sep = "|-----------|" + "|".join(["----------:" for _ in engines]) + "|"
    lines.append(header)
    lines.append(sep)
    for bench in benchmarks:
        row = f"| {bench} |"
        for engine in engines:
            data = stats.get((engine, bench))
            if data:
                row += f" {data['peak_rss_kb']:.0f} |"
            else:
                row += " - |"
        lines.append(row)

    report_path = results_dir / "report.md"
    with open(report_path, "w") as f:
        f.write("\n".join(lines))
    print(f"[OK] Markdown report: {report_path}")
    return report_path


def generate_html(stats, relative, cat_summary, overall, results_dir, system_info):
    engines = sorted(set(e for (e, _) in stats.keys()))
    categories = sorted(set(s["category"] for s in stats.values()))
    benchmarks = sorted(set(b for (_, b) in relative.keys()))

    categories_with_data = sorted(cat_summary.keys())

    chart_data = {
        "baseline": BASELINE_ENGINE,
        "engines": engines,
        "categories": categories_with_data,
        "system_info": system_info,
        "overall": overall,
        "category_summary": {
            cat: {e: cat_summary[cat].get(e, {}).get("avg_relative", 0) for e in engines}
            for cat in categories_with_data
        },
        "benchmarks": [],
        "memory": [],
    }

    for bench in benchmarks:
        entry = {"name": bench, "category": ""}
        for engine in engines:
            data = relative.get((engine, bench))
            if data:
                entry["category"] = data["category"]
                entry[engine] = {
                    "wall_ms": data["wall_ms"],
                    "relative": data["relative_time"],
                }
        chart_data["benchmarks"].append(entry)

    for bench in benchmarks:
        entry = {"name": bench}
        for engine in engines:
            data = stats.get((engine, bench))
            if data:
                entry[engine] = data["peak_rss_kb"]
        chart_data["memory"].append(entry)

    template_path = REPORT_TEMPLATE
    if not template_path.exists():
        print(f"[WARN] HTML template not found: {template_path}")
        return None

    with open(template_path) as f:
        template = f.read()

    html = template.replace("/*__CHART_DATA__*/{}", json.dumps(chart_data, indent=2))

    report_path = results_dir / "report.html"
    with open(report_path, "w") as f:
        f.write(html)
    print(f"[OK] HTML report: {report_path}")
    return report_path


def main():
    results_dir = find_latest_results()
    print(f"[INFO] Loading results from: {results_dir}")

    rows = load_csv(results_dir)
    print(f"[INFO] Loaded {len(rows)} data points")

    system_info = load_system_info(results_dir)

    stats = compute_stats(rows)
    relative = compute_relative(stats)
    cat_summary = compute_category_summary(relative)
    overall = compute_overall(stats)

    generate_markdown(stats, relative, cat_summary, overall, results_dir, system_info)
    generate_html(stats, relative, cat_summary, overall, results_dir, system_info)


if __name__ == "__main__":
    main()

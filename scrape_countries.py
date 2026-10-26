"""Scrape country + population data from scrapethissite.com/pages/simple/.

Cleaned-up version of the notebook work in
web_scraped/data_col.ipynb — same source, same selectors,
but as a single runnable script instead of notebook cells.

For each country it extracts:
  - name        (h3)
  - population  (the following div's span.country-population)

The site lists 250 countries on one page.

Output: data/countries.csv  (columns: name, population)
"""

import csv

import requests
from bs4 import BeautifulSoup

URL = "https://www.scrapethissite.com/pages/simple/"
OUTPUT_FILE = "data/countries.csv"
HEADERS = {"User-Agent": "data-pipeline-learning-project (contact: salimananp@gmail.com)"}


def main() -> None:
    response = requests.get(URL, headers=HEADERS, timeout=30)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "lxml")

    rows = []
    for h3 in soup.find_all("h3"):
        name = h3.get_text(strip=True)
        population = h3.find_next("div").select_one("span.country-population").get_text(strip=True)
        rows.append({"name": name, "population": int(population)})

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["name", "population"])
        writer.writeheader()
        writer.writerows(rows)

    print(f"Saved {len(rows)} countries to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()

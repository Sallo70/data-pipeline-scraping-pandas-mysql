"""Scrape quotes from quotes.toscrape.com (pages 1-10).

Cleaned-up version of the notebook work in
web_scraped/ass_data.ipynb — same source, same selectors,
but as a single runnable script instead of notebook cells.

For each quote it extracts:
  - text    (span.text)
  - author  (small.author)
  - tags    (.tags .tag)

Output: data/quotes.csv  (columns: page, text, author, tags)
"""

import csv
import time

import requests
from bs4 import BeautifulSoup

BASE_URL = "https://quotes.toscrape.com/page/{page}/"
OUTPUT_FILE = "data/quotes.csv"
HEADERS = {"User-Agent": "data-pipeline-learning-project (contact: salimananp@gmail.com)"}


def scrape_page(page: int) -> list[dict]:
    """Scrape one page of quotes.toscrape.com. Returns a list of rows."""
    response = requests.get(BASE_URL.format(page=page), headers=HEADERS, timeout=30)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "lxml")
    rows = []
    for quote in soup.select("div.quote"):
        text = quote.select_one("span.text").get_text(strip=True)
        author = quote.select_one("small.author").get_text(strip=True)
        tags = ", ".join(t.get_text(strip=True) for t in quote.select(".tags .tag"))
        rows.append({"page": page, "text": text, "author": author, "tags": tags})
    return rows


def main() -> None:
    all_rows: list[dict] = []
    for page in range(1, 11):
        rows = scrape_page(page)
        if not rows:
            print(f"Page {page}: no quotes found, stopping.")
            break
        print(f"Page {page}: {len(rows)} quotes")
        all_rows.extend(rows)
        time.sleep(0.5)  # be polite to the practice site

    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["page", "text", "author", "tags"])
        writer.writeheader()
        writer.writerows(all_rows)

    print(f"Saved {len(all_rows)} quotes to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()

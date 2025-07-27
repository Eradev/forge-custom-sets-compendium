import requests
from bs4 import BeautifulSoup
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
import time
import re

def decode_html(text):
    import html
    return html.unescape(text)

def get_set_metadata(soup):
    # Default values
    metadata = {
        'Name': "MSEM Set",
        'Date': ''
    }

    # Title parsing
    title_tag = soup.find('title')
    if title_tag and '-' in title_tag.text:
        metadata['Name'] = decode_html(title_tag.text.split('-')[0].strip())

    # Released date
    released_tag = soup.find(string=lambda text: text and "Released:" in text)
    if released_tag:
        date_text = released_tag.split("Released:")[-1].strip()
        metadata['Date'] = date_text

    return metadata

def get_cards_from_page(soup, set_code):
    cards = []
    for h3 in soup.select('h3.card_title > a'):
        href = h3.get('href')
        if not href:
            continue
        # Extract card number from URL, format: /card/TOW/1/Card-Name
        parts = href.strip('/').split('/')
        if len(parts) >= 3 and parts[1] == set_code:
            number = parts[2]
            name = decode_html(h3.text.strip())
            cards.append({'number': number, 'name': name, 'url': href})
    return cards

def fetch_card_details(card):
    card_url = f"https://msem-instigator.herokuapp.com{card['url']}"
    print(f"Fetching card details: {card_url}")
    try:
        resp = requests.get(card_url)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, 'html.parser')

        # Rarity
        rarity = 'C'  # default Common
        rarity_li = soup.find('li', string=lambda s: s and 'Rarity:' in s)
        if rarity_li:
            text = rarity_li.get_text(strip=True).lower()
            if 'common' in text:
                rarity = 'C'
            elif 'uncommon' in text:
                rarity = 'U'
            elif 'rare' in text:
                rarity = 'R'
            elif 'mythic' in text:
                rarity = 'M'
            elif 'special' in text:
                rarity = 'S'

        # Artist
        artist = ''
        # Find all list items with class "infolabel"
        info_items = soup.select('li.infolabel')
        for li in info_items:
            span = li.find('span')
            if span and span.text.strip() == "Artist:":
                artist_link = li.find('a')
                if artist_link:
                    artist = artist_link.text.strip()
                break

        return {
            'number': card['number'],
            'name': card['name'],
            'rarity': rarity,
            'artist': artist,
            'url': card['url']
        }

    except Exception as e:
        print(f"⚠️ Failed to fetch details for card {card['name']}: {e}")
        return {
            'number': card['number'],
            'name': card['name'],
            'rarity': 'C',
            'artist': '',
            'url': card['url']
        }

def sort_key(card):
    # Extract numeric part and optional letter suffix
    match = re.match(r"(\d+)([a-z]*)", card['number'], re.I)
    if match:
        number = int(match.group(1))
        suffix = match.group(2)
        # Sort by number, then suffix (empty suffix comes before letters)
        return (number, suffix)
    else:
        # If no match, put at end
        return (float('inf'), card['number'])

def main():
    if len(sys.argv) < 2:
        print("Usage: python forge-gen.py <setcode>")
        sys.exit(1)

    set_code = sys.argv[1].upper()
    base_url = f"https://msem-instigator.herokuapp.com/set/{set_code}"
    print(f"Retrieving set metadata from {base_url}")

    try:
        resp = requests.get(base_url)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, 'html.parser')
    except Exception as e:
        print(f"❌ Failed to fetch set page: {e}")
        sys.exit(1)

    metadata = get_set_metadata(soup)

    # Get cards, including pagination if needed
    all_cards = []
    page = 1
    while True:
        url = base_url if page == 1 else f"{base_url}?page={page}"
        print(f"Processing page {page} - {url}")
        try:
            resp = requests.get(url)
            resp.raise_for_status()
            page_soup = BeautifulSoup(resp.text, 'html.parser')
        except Exception as e:
            print(f"❌ Failed to fetch page {page}: {e}")
            break

        cards = get_cards_from_page(page_soup, set_code)
        if not cards:
            break
        all_cards.extend(cards)
        page += 1
        time.sleep(0.5)  # polite delay between pages

    print(f"Found {len(all_cards)} cards. Fetching details concurrently...")

    detailed_cards = []
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(fetch_card_details, card): card for card in all_cards}
        for future in as_completed(futures):
            result = future.result()
            detailed_cards.append(result)

    # Sort cards by number as string (you may convert to int if needed)
    detailed_cards.sort(key=sort_key)

    # Build output
    output_lines = []
    output_lines.append("[metadata]")
    output_lines.append(f"Code={set_code}")
    output_lines.append(f"Name={metadata.get('Name','')}")
    output_lines.append(f"Date={metadata.get('Date','')}")
    output_lines.append("Type=Custom")
    output_lines.append("")
    output_lines.append("[cards]")

    for card in detailed_cards:
        artist_part = f" @{card['artist']}" if card['artist'] else ""
        line = f"{card['number']} {card['rarity']} {card['name']}{artist_part}"
        output_lines.append(line)

    output_lines.append("")
    output_text = "\n".join(output_lines)
    output_filename = f"{set_code}.txt"
    with open(output_filename, 'w', encoding='utf-8') as f:
        f.write(output_text)

    print(f"✅ Success! Created {output_filename} with {len(detailed_cards)} cards.")

if __name__ == "__main__":
    main()

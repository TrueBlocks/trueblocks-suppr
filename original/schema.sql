-- CheckPlease Philly Restaurant Database
-- Single restaurants table with awards abstraction for lists/ratings

PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

---------------------------------------------------------------
-- Core restaurant table
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS restaurants (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    address       TEXT,
    neighborhood  TEXT,
    city          TEXT DEFAULT 'Philadelphia',
    state         TEXT DEFAULT 'PA',
    zip           TEXT,
    cuisine       TEXT,
    founding_date TEXT,              -- ISO date or just year
    founder       TEXT,
    chef          TEXT,
    website       TEXT,
    phone         TEXT,
    status        TEXT DEFAULT 'open',  -- open, closed, relocated
    source        TEXT,              -- where we first learned about it
    notes         TEXT,
    created_at    TEXT DEFAULT (datetime('now')),
    updated_at    TEXT DEFAULT (datetime('now'))
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_restaurants_name_city
    ON restaurants(name, city);

---------------------------------------------------------------
-- Award sources (Philly Mag 50 Best, Michelin, James Beard, etc.)
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS award_sources (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL UNIQUE,
    description TEXT,
    url         TEXT
);

---------------------------------------------------------------
-- Per-year source URLs for award lists (where we found the data)
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS award_source_urls (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    award_source_id INTEGER NOT NULL REFERENCES award_sources(id),
    year            INTEGER NOT NULL,
    url             TEXT NOT NULL,      -- the page we scraped (Wayback or live)
    notes           TEXT,
    UNIQUE(award_source_id, year)
);

---------------------------------------------------------------
-- Awards linking restaurants to award sources by year
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS awards (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    restaurant_id   INTEGER NOT NULL REFERENCES restaurants(id),
    award_source_id INTEGER NOT NULL REFERENCES award_sources(id),
    year            INTEGER NOT NULL,
    position        INTEGER,         -- rank (1-50) or star count (1-3), etc.
    notes           TEXT,
    UNIQUE(restaurant_id, award_source_id, year)
);

---------------------------------------------------------------
-- Check, Please! Philly episodes
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cp_episodes (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    season       INTEGER NOT NULL,
    episode_num  INTEGER NOT NULL,
    title        TEXT NOT NULL,
    url          TEXT,
    duration_min INTEGER,
    description  TEXT,
    UNIQUE(season, episode_num)
);

---------------------------------------------------------------
-- Link restaurants to Check, Please! episodes
---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cp_appearances (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id),
    episode_id    INTEGER NOT NULL REFERENCES cp_episodes(id),
    UNIQUE(restaurant_id, episode_id)
);

---------------------------------------------------------------
-- Seed award sources
---------------------------------------------------------------
INSERT INTO award_sources (name, description, url) VALUES
    ('Philly Mag 50 Best', 'Philadelphia Magazine annual 50 Best Restaurants list', 'https://www.phillymag.com/'),
    ('Michelin Guide', 'Michelin star ratings', 'https://guide.michelin.com/'),
    ('James Beard Award', 'James Beard Foundation awards', 'https://www.jamesbeard.org/'),
    ('Check, Please! Philly', 'WHYY TV show featuring Philly area restaurants', 'https://watch.whyy.org/show/check-please-philly/');

---------------------------------------------------------------
-- Seed award source URLs (per-year scrape provenance)
---------------------------------------------------------------
INSERT INTO award_source_urls (award_source_id, year, url, notes) VALUES
    (1, 2015, 'https://web.archive.org/web/20160215215607/http://www.phillymag.com/foobooz/50-best-restaurants-2015/', 'Wayback capture Feb 2016. Same content at /foobooz/50-best-restaurants/ captured Dec 2014.'),
    (1, 2016, 'https://web.archive.org/web/20220128001911/https://www.phillymag.com/foobooz/50-best-restaurants-2021/50-best-restaurants-january-2016/', 'Wayback capture Jan 2022. Title: 50 Best Restaurants - January 2016.'),
    (1, 2017, 'https://web.archive.org/web/20170713112424/http://www.phillymag.com:80/foobooz/50-best-restaurants/', 'Wayback capture Jul 2017. Title: 50 Best Restaurants in Philadelphia: Summer 2017. Same content in Jan 2018 capture.'),
    (1, 2019, 'https://web.archive.org/web/20190116040906/https://www.phillymag.com/foobooz/50-best-restaurants/', 'Wayback capture Jan 2019. Title: These Are the 50 Best Restaurants in Philadelphia. Same content through Sep 2020.'),
    (1, 2021, 'https://web.archive.org/web/20220524214740/https://www.phillymag.com/foobooz/50-best-restaurants-2021/', 'Wayback capture May 2022. Mixed format: ~18 unranked new additions + ranked entries #3-#50.'),
    (1, 2022, 'https://web.archive.org/web/20250115234117/https://www.phillymag.com/foobooz/50-best-restaurants-2022/', 'Wayback capture Jan 2025. All entries unranked (no position numbers). 45 restaurants.'),
    (1, 2023, 'https://web.archive.org/web/20241125061238/https://www.phillymag.com/foobooz/50-best-restaurants-2023/', 'Wayback capture Nov 2024. 50 ranked restaurants.'),
    (1, 2024, 'https://web.archive.org/web/20251108050015/https://www.phillymag.com/foobooz/50-best-restaurants-2024/', 'Wayback capture Nov 2025. 50 ranked restaurants.'),
    (1, 2026, 'https://www.phillymag.com/restaurants/50-best-restaurants/', 'Live page scraped May 2026. 50 ranked. URL changed from /foobooz/ to /restaurants/ path.');

---------------------------------------------------------------
-- Seed episodes
---------------------------------------------------------------
INSERT INTO cp_episodes (season, episode_num, title, url, duration_min) VALUES
-- Season 1
(1, 1,  'Bittersweet Kitchen, Vedge & Saad''s Halal', 'https://watch.whyy.org/show/check-please-philly/video/bittersweet-kitchen-vedge-saads-halal-3yyrzz/', 26),
(1, 2,  'Suraya, Sardine Bar & Park Place', 'https://watch.whyy.org/show/check-please-philly/video/suraya-sardine-bar-park-place-y1cdk5/', 26),
(1, 3,  'Sang Kee Peking Duck House, Heartbeet Kitchen & Victor Cafe', 'https://watch.whyy.org/show/check-please-philly/video/sang-kee-peking-duck-house-heartbeet-kitchen-victor-cafe-8mvfd0/', 26),
(1, 4,  'Marsha Brown, Silk City & Mica', 'https://watch.whyy.org/show/check-please-philly/video/marsha-brown-silk-city-mica-6x2e9b/', 25),
(1, 5,  'Hardena, Kimberton Inn & Poi Dog', 'https://watch.whyy.org/show/check-please-philly/video/hardena-kimberton-inn-poi-dog-g87st2/', 26),
(1, 7,  'Del Pez, Sate Kampar & Georgian Bread', 'https://watch.whyy.org/show/check-please-philly/video/del-pez-sate-kampar-georgian-bread-1sdzwy/', 26),
(1, 8,  'The House of William & Merry, Nam Phuong, Lloyd', 'https://watch.whyy.org/show/check-please-philly/video/the-house-of-william-merry-nam-phuong-lloyd-nmiwa6/', 26),
(1, 9,  'Ripplewood Whiskey & Craft, Bing Bing Dim Sum & Vernick', 'https://watch.whyy.org/show/check-please-philly/video/ripplewood-whiskey-craft-bing-bing-dim-sum-vernick-ultmqy/', 25),
(1, 10, 'Los Gallos, Coco Thai Bistro & Rione', 'https://watch.whyy.org/show/check-please-philly/video/los-gallos-coco-thai-bistro-rione-yrpct5/', 26),
(1, 11, 'Noord, Jug Handle Inn & High Street on Market', 'https://watch.whyy.org/show/check-please-philly/video/noord-jug-handle-inn-high-street-on-market-xnalqn/', 26),
(1, 12, 'Marrakesh, Mrs. Robino''s & Rex 1516', 'https://watch.whyy.org/show/check-please-philly/video/marrakesh-mrs-robinos-rex-1516-cxgekr/', 26),
(1, 13, 'Little Fish, Dana Mandi & Bomb Bomb BBQ', 'https://watch.whyy.org/show/check-please-philly/video/little-fish-dana-mandi-bomb-bomb-bbq-peagpi/', 26),
-- Season 2
(2, 1,  'Check, Please! Special Roundtable', 'https://watch.whyy.org/show/check-please-philly/video/check-please-special-roundtable-nuiywu/', 24),
(2, 2,  'Stina, Youma, Forsythia', 'https://watch.whyy.org/show/check-please-philly/video/stina-youma-forsythia-3amkx7/', 26),
(2, 3,  'Murph''s Bar, Oyster House, Autana', 'https://watch.whyy.org/show/check-please-philly/video/murphs-bar-oyster-house-autana-del7il/', 28),
(2, 4,  'E Mei, Parc, SOUTH', 'https://watch.whyy.org/show/check-please-philly/video/e-mei-parc-south-0sqaqg/', 28),
(2, 5,  'Tattooed Mom, Bar Bombon, Spice Finch', 'https://watch.whyy.org/show/check-please-philly/video/tattooed-mom-bar-bombon-spice-finch-jnrnax/', 28),
(2, 6,  'Blue Corn, Khyber Pass, Hymie''s', 'https://watch.whyy.org/show/check-please-philly/video/blue-corn-khyber-pass-hymies-2yfwyt/', 28),
-- Season 3
(3, 1,  'Gabriella''s Vietnam, Irie Entree, Cake', 'https://watch.whyy.org/show/check-please-philly/video/check-please-philly-gabriellas-vietnam-irie-entree-cak-ymqxpv/', 28),
(3, 2,  'Tomo, Middle Child Clubhouse, Jerry''s Bar', 'https://watch.whyy.org/show/check-please-philly/video/tomo-middle-child-clubhouse-jerrys-bar-6voxhl/', 28),
(3, 3,  'Cry Baby Pasta, Cantina Feliz, The Ways Brewery', 'https://watch.whyy.org/show/check-please-philly/video/cry-baby-pasta-cantina-feliz-the-ways-brewery-ifv4mx/', 28),
(3, 4,  'El Mezcal Cantina, Momoyama, Mike''s BBQ', 'https://watch.whyy.org/show/check-please-philly/video/el-mezcal-cantina-momoyama-mikes-bbq-61mcaq/', 28),
(3, 5,  'Bardea, Dim Sum Garden, Twisted Tail', 'https://watch.whyy.org/show/check-please-philly/video/bardea-dim-sum-garden-twisted-tail-figngt/', 27),
-- Season 4
(4, 1,  'Meetinghouse, Omegas, La Esperanza', 'https://watch.whyy.org/show/check-please-philly/video/meetinghouse-omegas-la-esperanza-rxgwsk/', 26),
(4, 2,  'Mawn, Chef Reeky, Chengdu Famous Food', 'https://watch.whyy.org/show/check-please-philly/video/mawn-chef-reeky-chengdu-famous-food-xgcaoj/', 26),
(4, 3,  'Lesbiveggies, June, Paesanos', 'https://watch.whyy.org/show/check-please-philly/video/lesbiveggies-june-paesanos-fnijfw/', 26),
(4, 4,  'Jay''s Steak, Rosemary, Suya Suya', 'https://watch.whyy.org/show/check-please-philly/video/jays-steak-rosemary-suya-suya-whwhre/', 26),
(4, 5,  'Primary Plant Based, Le Virtu, La Carreta', 'https://watch.whyy.org/show/check-please-philly/video/primary-plant-based-le-virtu-la-carreta-gu443w/', 26),
(4, 6,  'Sophie''s Kitchen, Flannel, The Pub', 'https://watch.whyy.org/show/check-please-philly/video/sophies-kitchen-flannel-the-pub-aqqhww/', 26),
(4, 7,  'Sulimay''s, Mish Mish, Stargazy', 'https://watch.whyy.org/show/check-please-philly/video/sulimays-mish-mish-stargazy-ultvry/', 26),
-- Season 5
(5, 1,  'The Clam Tavern, Le Cavalier, Terakawa', 'https://watch.whyy.org/show/check-please-philly/video/the-clam-tavern-le-cavalier-terakawa-3svqqz/', 26),
(5, 2,  'Fiore, Abyssinia, Cafe Carmela', 'https://watch.whyy.org/show/check-please-philly/video/restaurant-favorites-fiore-abyssinia-cafe-carmela-wo04ob/', 26),
(5, 3,  'Sofi''s Corner Cafe, Sorrentino''s Pasta + Provisions, DuBu', 'https://watch.whyy.org/show/check-please-philly/video/restaurant-favorites-sofis-corner-cafe-sorrentinos-pasta-provisions-dubu-en6x6a/', 26),
(5, 4,  'Carbon Copy, Tuna Bar, Snuff Mill', 'https://watch.whyy.org/show/check-please-philly/video/restaurant-favorites-carbon-copy-tuna-bar-snuff-mill-ungrvo/', 26),
(5, 5,  'Sky Cafe, Under the Moon, Chabaa Thai Bistro', 'https://watch.whyy.org/show/check-please-philly/video/sky-cafe-under-the-moon-chabaa-thai-bistro-117xc8/', 26),
-- Season 6
(6, 1,  'Doro Bet, Dog and Bull, Enswell', 'https://watch.whyy.org/show/check-please-philly/video/doro-bet-dog-and-bull-enswell-pojtzt/', 26),
(6, 2,  'White Yak, Casa Mexico, Nunzio', 'https://watch.whyy.org/show/check-please-philly/video/white-yak-casa-mexico-nunzio-jdkalp/', 26),
(6, 3,  'Vanilya, Harry''s Savoy Grill, Prime Fusion', 'https://watch.whyy.org/show/check-please-philly/video/vanilya-harrys-savoy-grill-prime-fusion-icgew0/', 26),
(6, 4,  'Pizza by Elizabeths, Mom-Mom''s, The Dandelion', 'https://watch.whyy.org/show/check-please-philly/video/pizza-by-elizabeths-mom-moms-the-dandelion-ynyfdq/', 26),
(6, 5,  'Cafe Nhan, A Truck Called Sandoz, The Mercury Cafe', 'https://watch.whyy.org/show/check-please-philly/video/cafe-nhan-a-truck-called-sandoz-the-mercury-cafe-vykdsl/', 26),
(6, 6,  'Comfort and Floyd, El Chingon, Southwark', 'https://watch.whyy.org/show/check-please-philly/video/comfort-and-floyd-el-chingon-southwark-juaior/', 26);

---------------------------------------------------------------
-- Seed restaurants from Check, Please! Philly
---------------------------------------------------------------
INSERT INTO restaurants (name, neighborhood, city, state, cuisine, source) VALUES
-- Season 1
('Bittersweet Kitchen', 'West Philadelphia', 'Philadelphia', 'PA', 'American', 'Check, Please! Philly'),
('Vedge', NULL, 'Philadelphia', 'PA', 'Vegan', 'Check, Please! Philly'),
('Saad''s Halal', NULL, 'Philadelphia', 'PA', 'Halal', 'Check, Please! Philly'),
('Suraya', 'Fishtown', 'Philadelphia', 'PA', 'Lebanese', 'Check, Please! Philly'),
('American Sardine Bar', NULL, 'Philadelphia', 'PA', 'American/Bar', 'Check, Please! Philly'),
('Park Place', NULL, 'Merchantville', 'NJ', 'American/Foraged', 'Check, Please! Philly'),
('Sang Kee Peking Duck House', NULL, 'Philadelphia', 'PA', 'Chinese', 'Check, Please! Philly'),
('Heartbeet Kitchen', NULL, 'Philadelphia', 'PA', 'Vegan/Gluten-Free', 'Check, Please! Philly'),
('Victor Cafe', NULL, 'Philadelphia', 'PA', 'Italian', 'Check, Please! Philly'),
('Marsha Brown', NULL, 'New Hope', 'PA', 'Creole/Southern', 'Check, Please! Philly'),
('Silk City', NULL, 'Philadelphia', 'PA', 'American/Diner', 'Check, Please! Philly'),
('Mica', 'Chestnut Hill', 'Philadelphia', 'PA', 'American', 'Check, Please! Philly'),
('Hardena', NULL, 'Philadelphia', 'PA', 'Indonesian', 'Check, Please! Philly'),
('Kimberton Inn', NULL, 'Kimberton', 'PA', 'American/Fine Dining', 'Check, Please! Philly'),
('Poi Dog', NULL, 'Philadelphia', 'PA', 'Hawaiian', 'Check, Please! Philly'),
('Del Pez', NULL, 'Wilmington', 'DE', 'Mexican/Seafood', 'Check, Please! Philly'),
('Sate Kampar', 'Passyunk', 'Philadelphia', 'PA', 'Malaysian', 'Check, Please! Philly'),
('Georgian Bread', 'Northeast Philadelphia', 'Philadelphia', 'PA', 'Georgian', 'Check, Please! Philly'),
('The House of William & Merry', NULL, NULL, 'DE', 'American', 'Check, Please! Philly'),
('Nam Phuong', 'South Philadelphia', 'Philadelphia', 'PA', 'Vietnamese', 'Check, Please! Philly'),
('Lloyd Whiskey Bar', 'Fishtown', 'Philadelphia', 'PA', 'American/Bar', 'Check, Please! Philly'),
('Ripplewood Whiskey & Craft', NULL, 'Ardmore', 'PA', 'American', 'Check, Please! Philly'),
('Bing Bing Dim Sum', 'Passyunk', 'Philadelphia', 'PA', 'Chinese/Dim Sum', 'Check, Please! Philly'),
('Vernick', 'Center City', 'Philadelphia', 'PA', 'American', 'Check, Please! Philly'),
('Los Gallos', 'South Philadelphia', 'Philadelphia', 'PA', 'Mexican', 'Check, Please! Philly'),
('Coco Thai Bistro', NULL, 'Narberth', 'PA', 'Thai', 'Check, Please! Philly'),
('Rione', 'Center City', 'Philadelphia', 'PA', 'Pizza', 'Check, Please! Philly'),
('Noord', 'Passyunk Square', 'Philadelphia', 'PA', 'Dutch', 'Check, Please! Philly'),
('Jug Handle Inn', NULL, 'Cinnaminson', 'NJ', 'American/Wings', 'Check, Please! Philly'),
('High Street on Market', 'Old City', 'Philadelphia', 'PA', 'American/Bakery', 'Check, Please! Philly'),
('Marrakesh', 'Queen Village', 'Philadelphia', 'PA', 'Moroccan', 'Check, Please! Philly'),
('Mrs. Robino''s', NULL, 'Wilmington', 'DE', 'Italian', 'Check, Please! Philly'),
('Rex 1516', 'South Street', 'Philadelphia', 'PA', 'American', 'Check, Please! Philly'),
('Little Fish', 'Queen Village', 'Philadelphia', 'PA', 'Seafood', 'Check, Please! Philly'),
('Dana Mandi', 'West Philadelphia', 'Philadelphia', 'PA', 'Indian/Pakistani', 'Check, Please! Philly'),
('Bomb Bomb BBQ', 'South Philadelphia', 'Philadelphia', 'PA', 'Italian/BBQ', 'Check, Please! Philly'),
-- Season 2
('Stina Pizzeria', NULL, 'Philadelphia', 'PA', 'Turkish/Pizza', 'Check, Please! Philly'),
('Youma', NULL, 'Philadelphia', 'PA', 'Senegalese', 'Check, Please! Philly'),
('Forsythia', NULL, 'Philadelphia', 'PA', 'French', 'Check, Please! Philly'),
('Murph''s Bar', NULL, 'Philadelphia', 'PA', 'Italian/Bar', 'Check, Please! Philly'),
('Oyster House', NULL, 'Philadelphia', 'PA', 'Seafood', 'Check, Please! Philly'),
('Autana', NULL, 'Philadelphia', 'PA', 'Venezuelan', 'Check, Please! Philly'),
('E Mei', NULL, 'Philadelphia', 'PA', 'Sichuan', 'Check, Please! Philly'),
('Parc', NULL, 'Philadelphia', 'PA', 'French', 'Check, Please! Philly'),
('SOUTH Restaurant & Jazz Club', NULL, 'Philadelphia', 'PA', 'Southern/Jazz', 'Check, Please! Philly'),
('Tattooed Mom', NULL, 'Philadelphia', 'PA', 'American/Bar', 'Check, Please! Philly'),
('Bar Bombon', NULL, 'Philadelphia', 'PA', 'Vegan/Mexican', 'Check, Please! Philly'),
('Spice Finch', NULL, 'Philadelphia', 'PA', 'Mediterranean', 'Check, Please! Philly'),
('Blue Corn', NULL, 'Philadelphia', 'PA', 'Mexican', 'Check, Please! Philly'),
('Khyber Pass Pub', NULL, 'Philadelphia', 'PA', 'American/Bar', 'Check, Please! Philly'),
('Hymie''s Deli', NULL, 'Philadelphia', 'PA', 'Deli', 'Check, Please! Philly'),
-- Season 3
('Gabriella''s Vietnam', NULL, 'Philadelphia', 'PA', 'Vietnamese', 'Check, Please! Philly'),
('Irie Entree', NULL, 'Philadelphia', 'PA', 'Jamaican', 'Check, Please! Philly'),
('Cake', NULL, 'Philadelphia', 'PA', 'American/Brunch', 'Check, Please! Philly'),
('Tomo', NULL, 'Philadelphia', 'PA', 'Japanese/Vegan Sushi', 'Check, Please! Philly'),
('Middle Child Clubhouse', NULL, 'Philadelphia', 'PA', 'American/Cocktails', 'Check, Please! Philly'),
('Jerry''s Bar', NULL, 'Philadelphia', 'PA', 'American/Bar', 'Check, Please! Philly'),
('Cry Baby Pasta', NULL, 'Philadelphia', 'PA', 'Italian/Pasta', 'Check, Please! Philly'),
('Cantina Feliz', NULL, 'Philadelphia', 'PA', 'Mexican', 'Check, Please! Philly'),
('The Ways Brewery', NULL, 'Philadelphia', 'PA', 'Brewery', 'Check, Please! Philly'),
('El Mezcal Cantina', NULL, 'Philadelphia', 'PA', 'Mexican', 'Check, Please! Philly'),
('Momoyama', NULL, 'Philadelphia', 'PA', 'Japanese/Ramen', 'Check, Please! Philly'),
('Mike''s BBQ', NULL, 'Philadelphia', 'PA', 'BBQ', 'Check, Please! Philly'),
('Bardea', NULL, 'Wilmington', 'DE', 'Italian', 'Check, Please! Philly'),
('Dim Sum Garden', 'Chinatown', 'Philadelphia', 'PA', 'Chinese/Dim Sum', 'Check, Please! Philly'),
('Twisted Tail', NULL, 'Philadelphia', 'PA', 'Southern/Live Music', 'Check, Please! Philly'),
-- Season 4
('Meetinghouse', NULL, 'Philadelphia', 'PA', 'American/Bar', 'Check, Please! Philly'),
('Omegas', NULL, 'Merchantville', 'NJ', 'Soul Food', 'Check, Please! Philly'),
('La Esperanza', NULL, 'Lindenwald', 'NJ', 'Mexican', 'Check, Please! Philly'),
('Mawn', NULL, 'Philadelphia', 'PA', 'Cambodian', 'Check, Please! Philly'),
('Chef Reeky', NULL, NULL, 'PA', 'Vegan', 'Check, Please! Philly'),
('Chengdu Famous Food', 'University City', 'Philadelphia', 'PA', 'Sichuan', 'Check, Please! Philly'),
('Lesbiveggies', NULL, 'Audubon', 'PA', 'Vegan/Gluten-Free', 'Check, Please! Philly'),
('June', NULL, 'Philadelphia', 'PA', 'French', 'Check, Please! Philly'),
('Paesanos', 'Italian Market', 'Philadelphia', 'PA', 'Italian/Sandwiches', 'Check, Please! Philly'),
('Jay''s Steak', NULL, 'Philadelphia', 'PA', 'Cheesesteaks', 'Check, Please! Philly'),
('Rosemary', NULL, 'Ridley Park', 'PA', 'American', 'Check, Please! Philly'),
('Suya Suya', 'Northern Liberties', 'Philadelphia', 'PA', 'Nigerian', 'Check, Please! Philly'),
('Primary Plant Based', 'Fishtown', 'Philadelphia', 'PA', 'Vegan', 'Check, Please! Philly'),
('Le Virtu', 'Passyunk', 'Philadelphia', 'PA', 'Italian/Abruzzi', 'Check, Please! Philly'),
('La Carreta', NULL, 'Hammonton', 'NJ', 'Mexican/Food Truck', 'Check, Please! Philly'),
('Sophie''s Kitchen', 'South Philadelphia', 'Philadelphia', 'PA', 'Cambodian', 'Check, Please! Philly'),
('Flannel', 'Passyunk', 'Philadelphia', 'PA', 'Southern', 'Check, Please! Philly'),
('The Pub', NULL, 'Pennsauken', 'NJ', 'Steakhouse', 'Check, Please! Philly'),
('Sulimay''s', 'Fishtown', 'Philadelphia', 'PA', 'American/Diner', 'Check, Please! Philly'),
('Mish Mish', NULL, 'Philadelphia', 'PA', 'Mediterranean', 'Check, Please! Philly'),
('Stargazy', NULL, 'Philadelphia', 'PA', 'British', 'Check, Please! Philly'),
-- Season 5
('The Clam Tavern', NULL, 'Clifton Heights', 'PA', 'Seafood', 'Check, Please! Philly'),
('Le Cavalier', NULL, 'Wilmington', 'DE', 'French', 'Check, Please! Philly'),
('Terakawa', 'Chinatown', 'Philadelphia', 'PA', 'Japanese/Ramen', 'Check, Please! Philly'),
('Fiore', 'Fishtown', 'Philadelphia', 'PA', 'Italian/Bakery', 'Check, Please! Philly'),
('Abyssinia', 'West Philadelphia', 'Philadelphia', 'PA', 'Ethiopian', 'Check, Please! Philly'),
('Cafe Carmela', NULL, 'Huntingdon Valley', 'PA', 'Italian', 'Check, Please! Philly'),
('Sofi''s Corner Cafe', 'Center City', 'Philadelphia', 'PA', 'French-Moroccan', 'Check, Please! Philly'),
('Sorrentino''s Pasta + Provisions', NULL, 'Ambler', 'PA', 'Italian/Pasta', 'Check, Please! Philly'),
('DuBu', NULL, 'Elkins Park', 'PA', 'Korean', 'Check, Please! Philly'),
('Carbon Copy', 'West Philadelphia', 'Philadelphia', 'PA', 'Pizza/Brewery', 'Check, Please! Philly'),
('Tuna Bar', 'Old City', 'Philadelphia', 'PA', 'Japanese/Sushi', 'Check, Please! Philly'),
('Snuff Mill', NULL, 'Wilmington', 'DE', 'Steakhouse', 'Check, Please! Philly'),
('Sky Cafe', 'South Philadelphia', 'Philadelphia', 'PA', 'Indonesian', 'Check, Please! Philly'),
('Under the Moon', NULL, 'Lambertville', 'NJ', 'Argentinian/Tapas', 'Check, Please! Philly'),
('Chabaa Thai Bistro', 'Manayunk', 'Philadelphia', 'PA', 'Thai', 'Check, Please! Philly'),
-- Season 6
('Doro Bet', 'West Philadelphia', 'Philadelphia', 'PA', 'Ethiopian/Fried Chicken', 'Check, Please! Philly'),
('Dog and Bull Taphouse', NULL, 'Croydon', 'PA', 'American/Pub', 'Check, Please! Philly'),
('Enswell', 'Center City', 'Philadelphia', 'PA', 'Coffee/Cocktail Bar', 'Check, Please! Philly'),
('White Yak', NULL, 'Philadelphia', 'PA', 'Tibetan', 'Check, Please! Philly'),
('Casa Mexico', 'Italian Market', 'Philadelphia', 'PA', 'Mexican', 'Check, Please! Philly'),
('Nunzio', NULL, NULL, 'NJ', 'Italian', 'Check, Please! Philly'),
('Vanilya', NULL, 'Philadelphia', 'PA', 'American/Bagels', 'Check, Please! Philly'),
('Harry''s Savoy Grill', NULL, NULL, 'DE', 'Steakhouse', 'Check, Please! Philly'),
('Prime Fusion', NULL, 'Philadelphia', 'PA', 'Pan-African/Cocktails', 'Check, Please! Philly'),
('Pizza by Elizabeths', NULL, NULL, 'DE', 'Pizza', 'Check, Please! Philly'),
('Mom-Mom''s', 'Port Richmond', 'Philadelphia', 'PA', 'Polish', 'Check, Please! Philly'),
('The Dandelion', 'Rittenhouse', 'Philadelphia', 'PA', 'British/Pub', 'Check, Please! Philly'),
('Cafe Nhan', 'South Philadelphia', 'Philadelphia', 'PA', 'Vietnamese', 'Check, Please! Philly'),
('A Truck Called Sandoz', 'West Philadelphia', 'Philadelphia', 'PA', 'Food Truck', 'Check, Please! Philly'),
('The Mercury Cafe', NULL, 'Philadelphia', 'PA', 'Cafe/Music', 'Check, Please! Philly'),
('Comfort and Floyd', NULL, 'Philadelphia', 'PA', 'American/Diner', 'Check, Please! Philly'),
('El Chingon', 'South Philadelphia', 'Philadelphia', 'PA', 'Mexican', 'Check, Please! Philly'),
('Southwark', 'Queen Village', 'Philadelphia', 'PA', 'Italian/Modern', 'Check, Please! Philly');

---------------------------------------------------------------
-- Link restaurants to episodes (cp_appearances)
---------------------------------------------------------------
-- S1E1
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Bittersweet Kitchen' AND e.season=1 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Vedge' AND e.season=1 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Saad''s Halal' AND e.season=1 AND e.episode_num=1;
-- S1E2
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Suraya' AND e.season=1 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='American Sardine Bar' AND e.season=1 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Park Place' AND e.season=1 AND e.episode_num=2;
-- S1E3
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Sang Kee Peking Duck House' AND e.season=1 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Heartbeet Kitchen' AND e.season=1 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Victor Cafe' AND e.season=1 AND e.episode_num=3;
-- S1E4
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Marsha Brown' AND e.season=1 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Silk City' AND e.season=1 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Mica' AND e.season=1 AND e.episode_num=4;
-- S1E5
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Hardena' AND e.season=1 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Kimberton Inn' AND e.season=1 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Poi Dog' AND e.season=1 AND e.episode_num=5;
-- S1E7
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Del Pez' AND e.season=1 AND e.episode_num=7;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Sate Kampar' AND e.season=1 AND e.episode_num=7;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Georgian Bread' AND e.season=1 AND e.episode_num=7;
-- S1E8
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='The House of William & Merry' AND e.season=1 AND e.episode_num=8;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Nam Phuong' AND e.season=1 AND e.episode_num=8;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Lloyd Whiskey Bar' AND e.season=1 AND e.episode_num=8;
-- S1E9
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Ripplewood Whiskey & Craft' AND e.season=1 AND e.episode_num=9;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Bing Bing Dim Sum' AND e.season=1 AND e.episode_num=9;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Vernick' AND e.season=1 AND e.episode_num=9;
-- S1E10
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Los Gallos' AND e.season=1 AND e.episode_num=10;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Coco Thai Bistro' AND e.season=1 AND e.episode_num=10;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Rione' AND e.season=1 AND e.episode_num=10;
-- S1E11
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Noord' AND e.season=1 AND e.episode_num=11;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Jug Handle Inn' AND e.season=1 AND e.episode_num=11;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='High Street on Market' AND e.season=1 AND e.episode_num=11;
-- S1E12
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Marrakesh' AND e.season=1 AND e.episode_num=12;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Mrs. Robino''s' AND e.season=1 AND e.episode_num=12;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Rex 1516' AND e.season=1 AND e.episode_num=12;
-- S1E13
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Little Fish' AND e.season=1 AND e.episode_num=13;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Dana Mandi' AND e.season=1 AND e.episode_num=13;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Bomb Bomb BBQ' AND e.season=1 AND e.episode_num=13;
-- S2E2
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Stina Pizzeria' AND e.season=2 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Youma' AND e.season=2 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Forsythia' AND e.season=2 AND e.episode_num=2;
-- S2E3
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Murph''s Bar' AND e.season=2 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Oyster House' AND e.season=2 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Autana' AND e.season=2 AND e.episode_num=3;
-- S2E4
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='E Mei' AND e.season=2 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Parc' AND e.season=2 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='SOUTH Restaurant & Jazz Club' AND e.season=2 AND e.episode_num=4;
-- S2E5
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Tattooed Mom' AND e.season=2 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Bar Bombon' AND e.season=2 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Spice Finch' AND e.season=2 AND e.episode_num=5;
-- S2E6
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Blue Corn' AND e.season=2 AND e.episode_num=6;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Khyber Pass Pub' AND e.season=2 AND e.episode_num=6;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Hymie''s Deli' AND e.season=2 AND e.episode_num=6;
-- S3E1
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Gabriella''s Vietnam' AND e.season=3 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Irie Entree' AND e.season=3 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Cake' AND e.season=3 AND e.episode_num=1;
-- S3E2
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Tomo' AND e.season=3 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Middle Child Clubhouse' AND e.season=3 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Jerry''s Bar' AND e.season=3 AND e.episode_num=2;
-- S3E3
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Cry Baby Pasta' AND e.season=3 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Cantina Feliz' AND e.season=3 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='The Ways Brewery' AND e.season=3 AND e.episode_num=3;
-- S3E4
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='El Mezcal Cantina' AND e.season=3 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Momoyama' AND e.season=3 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Mike''s BBQ' AND e.season=3 AND e.episode_num=4;
-- S3E5
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Bardea' AND e.season=3 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Dim Sum Garden' AND e.season=3 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Twisted Tail' AND e.season=3 AND e.episode_num=5;
-- S4E1
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Meetinghouse' AND e.season=4 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Omegas' AND e.season=4 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='La Esperanza' AND e.season=4 AND e.episode_num=1;
-- S4E2
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Mawn' AND e.season=4 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Chef Reeky' AND e.season=4 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Chengdu Famous Food' AND e.season=4 AND e.episode_num=2;
-- S4E3
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Lesbiveggies' AND e.season=4 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='June' AND e.season=4 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Paesanos' AND e.season=4 AND e.episode_num=3;
-- S4E4
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Jay''s Steak' AND e.season=4 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Rosemary' AND e.season=4 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Suya Suya' AND e.season=4 AND e.episode_num=4;
-- S4E5
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Primary Plant Based' AND e.season=4 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Le Virtu' AND e.season=4 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='La Carreta' AND e.season=4 AND e.episode_num=5;
-- S4E6
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Sophie''s Kitchen' AND e.season=4 AND e.episode_num=6;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Flannel' AND e.season=4 AND e.episode_num=6;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='The Pub' AND e.season=4 AND e.episode_num=6;
-- S4E7
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Sulimay''s' AND e.season=4 AND e.episode_num=7;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Mish Mish' AND e.season=4 AND e.episode_num=7;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Stargazy' AND e.season=4 AND e.episode_num=7;
-- S5E1
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='The Clam Tavern' AND e.season=5 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Le Cavalier' AND e.season=5 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Terakawa' AND e.season=5 AND e.episode_num=1;
-- S5E2
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Fiore' AND e.season=5 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Abyssinia' AND e.season=5 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Cafe Carmela' AND e.season=5 AND e.episode_num=2;
-- S5E3
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Sofi''s Corner Cafe' AND e.season=5 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Sorrentino''s Pasta + Provisions' AND e.season=5 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='DuBu' AND e.season=5 AND e.episode_num=3;
-- S5E4
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Carbon Copy' AND e.season=5 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Tuna Bar' AND e.season=5 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Snuff Mill' AND e.season=5 AND e.episode_num=4;
-- S5E5
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Sky Cafe' AND e.season=5 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Under the Moon' AND e.season=5 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Chabaa Thai Bistro' AND e.season=5 AND e.episode_num=5;
-- S6E1
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Doro Bet' AND e.season=6 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Dog and Bull Taphouse' AND e.season=6 AND e.episode_num=1;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Enswell' AND e.season=6 AND e.episode_num=1;
-- S6E2
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='White Yak' AND e.season=6 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Casa Mexico' AND e.season=6 AND e.episode_num=2;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Nunzio' AND e.season=6 AND e.episode_num=2;
-- S6E3
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Vanilya' AND e.season=6 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Harry''s Savoy Grill' AND e.season=6 AND e.episode_num=3;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Prime Fusion' AND e.season=6 AND e.episode_num=3;
-- S6E4
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Pizza by Elizabeths' AND e.season=6 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Mom-Mom''s' AND e.season=6 AND e.episode_num=4;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='The Dandelion' AND e.season=6 AND e.episode_num=4;
-- S6E5
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Cafe Nhan' AND e.season=6 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='A Truck Called Sandoz' AND e.season=6 AND e.episode_num=5;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='The Mercury Cafe' AND e.season=6 AND e.episode_num=5;
-- S6E6
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Comfort and Floyd' AND e.season=6 AND e.episode_num=6;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='El Chingon' AND e.season=6 AND e.episode_num=6;
INSERT INTO cp_appearances (restaurant_id, episode_id) SELECT r.id, e.id FROM restaurants r, cp_episodes e WHERE r.name='Southwark' AND e.season=6 AND e.episode_num=6;

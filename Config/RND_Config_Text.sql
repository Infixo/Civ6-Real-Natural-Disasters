--------------------------------------------------------------
-- Real Natural Disasters Config Text
-- Author: Infixo
-- 2017-04-05: Created
-- 2018-03-16: Sknaht converted all texts into LOCs
--------------------------------------------------------------

INSERT INTO LocalizedText (Language, Tag, Text) VALUES
("en_US", "LOC_RND_CONFIG_NUMDIS_NAME",     "Number of Disasters"),
("en_US", "LOC_RND_CONFIG_NUMDIS_DESC",     "Number of natural disasters in a game"),
("en_US", "LOC_RND_CONFIG_ADJMAPSIZE_NAME", "Map Size Adjustment"),
("en_US", "LOC_RND_CONFIG_ADJMAPSIZE_DESC", "Should the number of disasters be also adjusted for the map size"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_NAME",  "Disasters Strength"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_DESC",  "Disasters strength"),
("en_US", "LOC_RND_CONFIG_RANGE_NAME",      "Disasters Range"),
("en_US", "LOC_RND_CONFIG_RANGE_DESC",      "Disasters range"),
-- Number of natural disasters in a game
("en_US", "LOC_RND_CONFIG_NUMDIS_MINI_NAME",     "Minimal ~25"),
("en_US", "LOC_RND_CONFIG_NUMDIS_MINI_DESC",     "There will be ~25 natural disasters during the game"),
("en_US", "LOC_RND_CONFIG_NUMDIS_LOW_NAME",      "Low ~50"),
("en_US", "LOC_RND_CONFIG_NUMDIS_LOW_DESC",      "There will be ~50 natural disasters during the game"),
("en_US", "LOC_RND_CONFIG_NUMDIS_MEDIUM_NAME",   "Medium ~75"),
("en_US", "LOC_RND_CONFIG_NUMDIS_MEDIUM_DESC",   "There will be ~75 natural disasters during the game"),
("en_US", "LOC_RND_CONFIG_NUMDIS_STANDARD_NAME", "Standard ~100"),
("en_US", "LOC_RND_CONFIG_NUMDIS_STANDARD_DESC", "There will be ~100 natural disasters during the game (default)"),
("en_US", "LOC_RND_CONFIG_NUMDIS_HIGH_NAME",     "High ~150"),
("en_US", "LOC_RND_CONFIG_NUMDIS_HIGH_DESC",     "There will be ~150 natural disasters during the game"),
("en_US", "LOC_RND_CONFIG_NUMDIS_EXTREME_NAME",  "Extreme ~200"),
("en_US", "LOC_RND_CONFIG_NUMDIS_EXTREME_DESC",  "There will be ~200 natural disasters during the game"),
("en_US", "LOC_RND_CONFIG_NUMDIS_INSANE_NAME",   "Insane ~250"),
("en_US", "LOC_RND_CONFIG_NUMDIS_INSANE_DESC",   "There will be ~250 natural disasters during the game"),
("en_US", "LOC_RND_CONFIG_NUMDIS_CHICKEN_NAME",  "Chicken..."),
("en_US", "LOC_RND_CONFIG_NUMDIS_CHICKEN_DESC",  "There will be NO natural disasters during the game"),
-- Adjust for map size
("en_US", "LOC_RND_CONFIG_ADJMAPSIZE_NO_NAME",  "Do NOT adjust for map size"),
("en_US", "LOC_RND_CONFIG_ADJMAPSIZE_NO_DESC",  "Number of disasters will NOT be adjusted for map size"),
("en_US", "LOC_RND_CONFIG_ADJMAPSIZE_YES_NAME", "Adjust for map size"),
("en_US", "LOC_RND_CONFIG_ADJMAPSIZE_YES_DESC", "Number of disasters will be adjusted for map size (default)"),
-- Disasters strength
("en_US", "LOC_RND_CONFIG_MAGNITUDE_VERY_WEAK_NAME",   "Very weak (-20)"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_VERY_WEAK_DESC",   "Very weak: Magnitude decreased by -20 for each disaster"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_WEAKER_NAME",      "Weaker (-10)"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_WEAKER_DESC",      "Weaker: Magnitude decreased by -10 for each disaster"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_STANDARD_NAME",    "Standard"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_STANDARD_DESC",    "Standard: No change in Magnitude (default)"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_STRONGER_NAME",    "Stronger (+10)"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_STRONGER_DESC",    "Stronger: Magnitude increased by +10 for each disaster"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_VERY_STRONG_NAME", "Very strong (+20)"),
("en_US", "LOC_RND_CONFIG_MAGNITUDE_VERY_STRONG_DESC", "Very strong: Magnitude increased by +20 for each disaster"),
-- Disasters range
("en_US", "LOC_RND_CONFIG_RANGE_SMALL_NAME",      "Smaller (-1)"),
("en_US", "LOC_RND_CONFIG_RANGE_SMALL_DESC",      "Smaller: -1 tile, good for Duel and Tiny maps"),
("en_US", "LOC_RND_CONFIG_RANGE_STANDARD_NAME",   "Standard"),
("en_US", "LOC_RND_CONFIG_RANGE_STANDARD_DESC",   "Standard: no change in range, good for Small, Standard and Large maps (default)"),
("en_US", "LOC_RND_CONFIG_RANGE_LARGE_NAME",      "Larger (+1)"),
("en_US", "LOC_RND_CONFIG_RANGE_LARGE_DESC",      "Larger: +1 tile, good for Huge and Enormous maps"),
("en_US", "LOC_RND_CONFIG_RANGE_VERY_LARGE_NAME", "Very large (+2)"),
("en_US", "LOC_RND_CONFIG_RANGE_VERY_LARGE_DESC", "Very large: +2 tiles, good for Giant maps"),
("en_US", "LOC_RND_CONFIG_RANGE_EXTREME_NAME",    "Extreme (+3)"),
("en_US", "LOC_RND_CONFIG_RANGE_EXTREME_DESC",    "Extreme: +3 tiles, good for Ludicrous maps");

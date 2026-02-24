# ThikrSpace Firestore Schema v1

## Strategy: Lazy Item Creation (Cost Control)
We DO NOT pre-generate 6,236 ayah documents when a user signs up. 
The client stores a `cursor` (e.g., Surah 1, Ayah 1) locally in Hive. 
When the daily queue generator runs, it looks at the cursor, introduces the next `dailyNew` items, and *only then* creates those specific item documents in Firestore.

## Collections & Documents

### `users/{uid}`
The root profile document.
* **Access:** `read` (Owner only), `write` (Owner only, strictly bounded).
* **Fields:**
  * `id` (String): matches the document UID.
  * `flags` (Map): **[READ-ONLY TO CLIENT]**
    * `betaAccess` (Bool): System access.
    * `pro` (Bool): Future paywall gate.
  * `settings` (Map):
    * `isOnboarded` (Bool)
    * `surahStart`, `surahEnd` (Int): 1..114
    * `dailyNew` (Int): Max 50
    * `dailyMaxReviews` (Int): Max 500
    * `timezone` (String)
  * `stats` (Map):
    * `currentStreak`, `longestStreak` (Int)
    * `totalReviews` (Int)
    * `itemsMastered` (Int)
  * `meta` (Map): **[LAZY CURSOR STATE]**
    * `cursorSurah` (Int): The surah of the next new item to learn.
    * `cursorAyah` (Int): The ayah of the next new item to learn.

### `users/{uid}/items/{itemId}`
The Spaced Repetition (SRS) item. 
* **ID Format:** Deterministic `s{surah}_a{ayah}` (e.g., `s1_a1`).
* **Access:** `read`, `write` (Owner only, tight bounds).
* **Fields:**
  * `surah` (Int): 1..114
  * `ayah` (Int): >= 1
  * `ease` (Double): 1.3 to 2.7 (SM-2 bounds)
  * `intervalDays` (Int): 0 to 3650 (10 years)
  * `reps` (Int): >= 0
  * `lapses` (Int): >= 0
  * `dueAt` (Timestamp): UTC time this item is next due.
  * `createdAt`, `updatedAt` (Timestamp)
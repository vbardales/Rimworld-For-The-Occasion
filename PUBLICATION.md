# For the Occasion: publication notes

Status 2026-10-15: stage `playTests[1.0.0]`. Only the gallery plan below is written. The Steam description,
the thank-you messages, the dependency list and the adult-content answers are `writeDocs` work and do not exist yet.
Nothing in this file has been played: no gallery scenario exists and no capture has been taken.

## Gallery: the story, "The feast day"

One day at Nelim's Sanctuary (Nelim is the colonist of the shared save, and the protagonist of every image).
A death in the family of the sanctuary puts an obligation on the ideoligion's ritual. The colony hears about it at
dawn, gets ready, lays an offering table, holds the rite at dusk, and is back in ordinary clothes the next morning.
Each image shows one thing the mod does, in the order the player meets it.

Place: the house, mostly `ritual-hall` (206, 117) for the wardrobe and the table, `hearth-hall` (181, 115) for the
rite itself, the brazier room. All of them are read from their empty photographs before the scenarios are written.
Time: the author's rhythm is one hour per image, 07:00 to 19:00, then 07:00 the next morning (a different hour per
image is allowed, GALLERY.md 2026-10-14). Light is the story: cold dawn, warm braziers at dusk.

Mods staged for the series (a gallery `-DepMap` of its own: the Sanctuary map plus the offering providers):
Facial Animation, EyeGenes3 (Nelim's brown eyes, the fixture's default), the four offering providers of
`Tests/Pickle/wsl-deps.avec-offrandes.map` (RimScent incense, Perfumes, Vanilla Brewing Expanded, Rum and Shanties),
Vanilla Hair Expanded (the braid and the crop), Moving Vanilla Eyes if a smile is wanted (without it only `MouthNormal`, `BrowNormal`, `BrowThick`, `LidNormal` resolve).
Animals: Shogun (labrador), facing the camera in image 3, then a thrumbo behind the glass in the rite. Not played.

What each person wears and looks like, decided in advance (colours chosen against warm amber light, so the
ceremonial garments read; clothes are the game's own ceremonial-tagged ones: `Apparel_Robe`, `Apparel_Cape`,
`Apparel_HatTop`, `Apparel_Corset`):

| Person | Wears | Hair | Face |
| --- | --- | --- | --- |
| Nelim | indigo robe, ivory cape; her ordinary trousers and corset in images 1 and 7 | her own, tied back so it shows under no hat | her fixture face (two brows, smirk, blink); drawn face paint in images 2 to 6 |
| Tomas (guest) | forest-green robe, top hat | cropped, dark | solemn: `BrowThick`, `MouthNormal` |
| Maelys (guest) | rust cape over a cream robe | long, grey-white, one braid | `BrowNormal`, a small smile only if Moving Vanilla Eyes is in the pass |

Expression by image (only pieces that resolve without a mod: `BrowThick`, `BrowNormal`, `MouthNormal`, `LidNormal`; a smile needs
Moving Vanilla Eyes): 1 Nelim sleepy, lids half down; 2 Nelim attentive, brows level; 3 Nelim curious, a smirk, eyes on the table;
4 Nelim and Maelys calm, Tomas solemn; 6 Nelim tired, eyes lowered; 7 Nelim rested, a smirk. The guests need a bare face so the
face paint shows (scenario 6); Nelim's own face carries none beforehand.
The outfit stand needs Odyssey (scenario 3): the gallery pass lists Odyssey with the Sanctuary map. Hairstyles come from Vanilla Hair Expanded (`VanillaExpanded.VHE`, Workshop 1888705256, a 1.6 folder present): Maelys `VHE_SideBraid` (the one braid, hair colour grey-white), Tomas `VHE_Buzzcut` (cropped, dark), Nelim keeps her own style tied back. Staged in the gallery `-DepMap`; to be checked on the capture.

Plan, one line per image (place, moment, subject, composition, life in the scene, what it says):

| # | Place and moment | Subject and composition | What it says | Mod behaviour shown (TESTING.md) |
| --- | --- | --- | --- | --- |
| 1 | `ritual-hall`, 07:00 | Nelim in work clothes, wide shot, the outfit stand off-centre with the robe and cape folded in it (Nelim's ceremonial owner stand, scenario 3), Shogun asleep in the foreground | the day starts; nobody is dressed yet | scenario 8, anticipation |
| 2 | `ritual-hall`, 08:00 | Nelim at the stand, robe and cape on, face paint just drawn, medium shot, her old clothes folded on the stand | she walks to the stand and takes the robe | scenarios 3 and 6 |
| 3 | `ritual-hall`, 11:00 | The offering table, close: incense, perfume, a meal, a cider or rum, a little gold; Shogun sniffs it, facing the camera | four kinds of offering, not four hundred beers | scenario 1 |
| 4 | `hearth-hall`, 17:00 | Nelim, Tomas and Maelys round the central hearth in ceremonial dress, braziers lit, low camera | the whole colony dressed for the same rite | scenario 3 on three pawns, scenario 6 |
| 5 | Interface, no subtitle | The ritual quality tooltip, "Ceremonial dress" line and the offering bonus | the game shows what the table and the clothes add | scenario 1 and the quality factors |
| 6 | `hearth-hall`, 19:00 | The rite is over, the table cleared, the braziers burning down, Nelim at the edge of the light | what was offered is spent | scenario 2, **blocked: feature 14 has never run** |
| 7 | `ritual-hall`, next day 07:00 | Nelim back in work clothes, the stand holding the robe, her face bare | the robes go back on the stand and the paint is gone | scenario 4, scenario 6 |
| 8 | Interface, no subtitle | The mod settings window, cropped as GALLERY.md says | what the player can switch | scenario 10 |

Checks against the written scenarios (2026-10-15): images 1, 2, 3, 4 and 7 match scenarios 8, 3, 1, 3 and 4 of
`TESTING.md`. Image 6 shows the consumption of scenario 2, which only a real rite begun from the game's own window
can prove, and Pickle feature 14 (the ritual hook) has never run: the image waits for it, and no subtitle claims it
before. Image 4 asks for three dressed pawns, which no scenario has played yet. Both are gallery risks, not
reasons to drop the image.

## Gallery subtitles

One line of English at the bottom of each scene without an interface window (GALLERY.md, "Sous-titres"). Interface
captures (5 and 8) and `0-` carry none. The clean originals go to `Art/Gallery-clean/`, the subtitled images to
`Art/Gallery/`, with the same file names. These names are the plan; they are final once the captures are accepted
and the indexes are made contiguous.

| Index | File | Line |
| --- | --- | --- |
| 1 | `1-dawn.jpg` | The feast day is announced, and nobody has changed yet. |
| 2 | `2-the-stand.jpg` | Nelim trades her work clothes for the stand's ceremonial robe. |
| 3 | `3-the-table.jpg` | Incense, a fine meal, a drink and a little gold: four kinds, one table. |
| 4 | `4-the-hearth.jpg` | Everyone is in ceremonial dress, and the paint goes on with it. |
| 6 | `6-the-spent-table.jpg` | When the rite ends, what was offered is spent. |
| 7 | `7-next-morning.jpg` | Next morning the robes are back on the stand and the paint is gone. |

Image 5 (`5-ritual-quality.jpg`) and image 8 (`8-settings.jpg`) are interface captures.

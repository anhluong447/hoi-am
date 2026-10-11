# Complete newsroom art assembly

The new pack has 34 cutout prop groups, 7 painted surfaces and catalog-resolved
world signs. All physical boxes are hidden or shadow-only. Existing actor/UI art
is unchanged. Horizontal floor grain and corrected poster placement supersede
the exploratory v1 captures; v2 captures are current for this chapter.

699 headless checks and 83 native checks pass. One first native interaction run
failed the existing synthetic pointer check at 1920×1080; its raw log is preserved
in `evidence/hd04-newsroom-v2/native-interaction-first-attempt.log`. The complete
native rerun passed without modifying production UI or weakening the assertion.
This intermittent input-test result is recorded for later integration review.

Assignment-board spatial target now sits in front of the cabinet-mounted board.
Stable target ID and command remain unchanged. Added furniture/shelf/plant proxies
protect their physical footprint. Final user visual acceptance remains pending.

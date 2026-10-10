# Coastal editorial v1 — reference

Bốn ảnh concept người dùng đã chọn, nhập nguyên byte kèm prompt và SHA-256.
Không load các ảnh này như runtime UI hoặc bake chữ/nút từ ảnh vào production art.

- [01 — dialogue](01-dialogue.png)
- [02 — menu](02-menu.png)
- [03 — HUD/world direction](03-hud-map.png)
- [04 — dossier](04-dossier.png)
- [Prompt record](prompts.json)
- [Active reference metadata](references.json)
- [Original metadata snapshot](references.source.json)

Phạm vi UI cố định và attached decorations theo
[hướng nghệ thuật mới](../../ART-DIRECTION.md). World trở thành một track 2.5D
riêng, không cần match camera/actor identity của ảnh để đóng visual gate UI.

Active roadmap là [migration chapters](../../migration/README.md); các stage và
full-frame scores của bản browser không trở thành nghiệm thu Godot tự động.

extends RefCounted

const PEOPLE = preload("res://src/domain/gameplay/gameplay_people.gd")
const EVENTS = preload("res://src/domain/gameplay/gameplay_events.gd")
const CALENDAR = preload("res://src/domain/gameplay/gameplay_calendar.gd")


static func apply(state: Dictionary, action: Dictionary, pack: Dictionary) -> Dictionary:
	var tuning: Dictionary = pack.balance.PERSONAL
	var person := PEOPLE.person(state, str(action.get("person", "")))
	var stat := str(action.get("stat", ""))
	var stat_key := ""
	for definition: Dictionary in pack.stats:
		if definition.id == stat:
			stat_key = definition.name_key
	var free: bool = state.phase in ["personal", "evening", "weekend1", "weekend2"]
	match action.type:
		"activity":
			if not free:
				return EVENTS.reject("khong_phai_slot_ca_nhan")
			var khue := PEOPLE.person(state, "khue")
			match action.get("kind"):
				"investigate":
					state.investigationFrom = state.phase
					state.phase = "investigation"
					state.energy = state.config.outsideEnergy
					EVENTS.note(state, "src.gameplay.engine.bat_dau_dieu_tra_ngoai_gio")
					return {"ok": true}
				"hangout":
					if not _joined_other(state, person):
						return EVENTS.reject("nhan_vat_chua_kha_dung")
					person.bond += 1
					person.events += 1
					state.metrics.hangouts += 1
					if person.events == tuning.synergyEvents:
						person.skills.append("synergy")
						EVENTS.note(state, "src.gameplay.engine.value0_mo_ky_nang_hiep_dong_mock", {"value0": EVENTS.text_ref(person.name_key)})
					EVENTS.note(state, "src.gameplay.engine.hangout_voi_value0_bond_value1_moc_value2", {"value0": EVENTS.text_ref(person.name_key), "value1": person.bond, "value2": person.events})
				"job":
					state.money += state.config.jobPay
					khue.fatigue += tuning.jobFatigue
					state.metrics.jobs += 1
					EVENTS.note(state, "src.gameplay.engine.lam_them_value0_d", {"value0": state.config.jobPay})
				"train":
					if stat_key.is_empty():
						return EVENTS.reject("chi_so_khong_hop_le")
					if state.money < state.config.trainingCost:
						return EVENTS.reject("khong_du_tien_hoc")
					state.money -= state.config.trainingCost
					khue.stats[stat] += tuning.trainingGrowth
					khue.fatigue += tuning.trainingFatigue
					EVENTS.note(state, "src.gameplay.engine.ren_value0_0_5", {"value0": EVENTS.text_ref(stat_key)})
				"rest":
					khue.fatigue = maxf(0.0, khue.fatigue - tuning.restRecovery)
					EVENTS.note(state, "src.gameplay.engine.nghi_ngoi_giam_20_met")
				_:
					return EVENTS.reject("hoat_dong_khong_hop_le")
			CALENDAR.consume_slot(state)
		"date":
			if not free:
				return EVENTS.reject("hen_ho_can_mot_slot_ca_nhan")
			if person.is_empty() or not person.female or person.joinDay > state.day or person.bond < tuning.dateBond or person.events < tuning.dateEvents or person.romance:
				return EVENTS.reject("chua_du_dieu_kien_to_tinh")
			person.romance = true
			person.bond += 1
			EVENTS.note(state, "src.gameplay.engine.khue_va_value0_bat_dau_hen_ho_quyet_dinh_khong_the_rut_lai", {"value0": EVENTS.text_ref(person.name_key)})
			CALENDAR.consume_slot(state)
		"gift":
			if not free:
				return EVENTS.reject("tang_qua_trong_slot_gap_go")
			if not _joined_other(state, person):
				return EVENTS.reject("nhan_vat_chua_kha_dung")
			if state.money < state.config.giftCost:
				return EVENTS.reject("khong_du_tien_mua_qua")
			state.money -= state.config.giftCost
			person.bond += 1
			EVENTS.note(state, "src.gameplay.engine.tang_qua_tang_bond_khong_tang_moc_su_kien")
			CALENDAR.consume_slot(state)
		"tool":
			if state.phase in ["bed", "investigation", "morning"]:
				return EVENTS.reject("mua_cong_cu_truoc_luc_ngu_trong_gio_tu_do_hoac_clb")
			if stat_key.is_empty():
				return EVENTS.reject("cong_cu_khong_hop_le")
			if person.is_empty() or person.joinDay > state.day or stat in person.tools:
				return EVENTS.reject("trang_bi_khong_kha_dung")
			if state.money < state.config.toolCost:
				return EVENTS.reject("khong_du_tien")
			state.money -= state.config.toolCost
			person.tools.append(stat)
			EVENTS.note(state, "src.gameplay.engine.mua_cong_cu_value0_cho_value1", {"value0": EVENTS.text_ref(stat_key), "value1": EVENTS.text_ref(person.name_key)})
		"boost":
			if state.phase not in ["club", "investigation"]:
				return EVENTS.reject("hay_vao_buoi_clb_hoac_chon_dieu_tra_ngoai_gio")
			if state.get("boostToday", false):
				return EVENTS.reject("chi_dung_mot_do_uong_moi_ngay")
			if state.money < tuning.boostCost:
				return EVENTS.reject("khong_du_tien_mua_do_uong")
			state.money -= tuning.boostCost
			state.boostToday = true
			state.energy += tuning.boostEnergy
			EVENTS.note(state, "src.gameplay.engine.do_uong_1_energy_mock_toi_da_mot_lan_ngay")
		"upgrade":
			if not _joined_other(state, person) or stat_key.is_empty():
				return EVENTS.reject("nang_cap_khong_hop_le")
			if state.grants <= 0:
				return EVENTS.reject("chua_co_suat_ho_tro")
			state.grants -= 1
			person.stats[stat] += tuning.upgradeGrowth
			EVENTS.note(state, "src.gameplay.engine.dung_suat_clb_value0_value1_0_5", {"value0": EVENTS.text_ref(person.name_key), "value1": EVENTS.text_ref(stat_key)})
	return {"ok": true}


static func _joined_other(state: Dictionary, person: Dictionary) -> bool:
	return not person.is_empty() and person.id != "khue" and person.joinDay <= state.day

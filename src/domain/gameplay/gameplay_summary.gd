extends RefCounted


static func summarize(state: Dictionary, pack: Dictionary) -> Dictionary:
	var tuning: Dictionary = pack.balance.SUMMARY
	var k := 0.0
	var t := 0.0
	var kc := 0
	var tc := 0
	for article: Dictionary in state.articles:
		if article.published:
			if article.branch == "khue":
				k += article.quality
				kc += 1
			else:
				t += article.quality
				tc += 1
	var weeks := floorf(state.config.days / pack.balance.CALENDAR.daysPerWeek)
	k = minf(tuning.max, k / maxf(1.0, weeks) * tuning.max)
	t = minf(tuning.max, t / maxf(1.0, weeks * tuning.teamArticlesPerWeek) * tuning.max)
	var total: float = tuning.khueWeight * k + tuning.teamWeight * t
	return {"K": k, "T": t, "total": total, "good": k >= tuning.branchThreshold and t >= tuning.branchThreshold and total >= tuning.totalThreshold,
		"teamArticles": tc, "khueArticles": kc}

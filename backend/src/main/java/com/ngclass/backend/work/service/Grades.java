package com.ngclass.backend.work.service;

import com.ngclass.backend.common.ApiException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Collection;
import java.util.List;

/** Grade rules (docs/03-conception/03-BUSINESS_RULES.md section 5): /20, simple mean, trend. */
public final class Grades {
	private static final BigDecimal TWENTY = BigDecimal.valueOf(20);
	private static final BigDecimal HALF = new BigDecimal("0.5");

	private Grades() {
	}

	/** From 0 to [max], in half points ("14,5"). */
	public static BigDecimal checked(BigDecimal score, int max) {
		if (score == null || score.signum() < 0 || score.compareTo(BigDecimal.valueOf(max)) > 0
				|| score.remainder(HALF).signum() != 0) {
			throw ApiException.badRequest("invalid_score", max);
		}
		return score.setScale(2, RoundingMode.UNNECESSARY);
	}

	/** 7/10 is 14,00/20. */
	public static BigDecimal on20(BigDecimal score, int max) {
		return score.multiply(TWENTY).divide(BigDecimal.valueOf(max), 2, RoundingMode.HALF_UP);
	}

	/** The simple mean, no coefficients (Q6); null without a grade. */
	public static BigDecimal average(Collection<BigDecimal> scores20) {
		if (scores20.isEmpty()) {
			return null;
		}
		BigDecimal sum = scores20.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
		return sum.divide(BigDecimal.valueOf(scores20.size()), 2, RoundingMode.HALF_UP);
	}

	/** The last 3 grades against those before them (oldest first): UP from +1, DOWN from -1; null under 4 grades. */
	public static String trend(List<BigDecimal> chronological) {
		if (chronological.size() < 4) {
			return null;
		}
		int split = chronological.size() - 3;
		BigDecimal before = average(chronological.subList(0, split));
		BigDecimal last = average(chronological.subList(split, chronological.size()));
		BigDecimal change = last.subtract(before);
		if (change.compareTo(BigDecimal.ONE) >= 0) {
			return "UP";
		}
		return change.compareTo(BigDecimal.ONE.negate()) <= 0 ? "DOWN" : "STABLE";
	}
}

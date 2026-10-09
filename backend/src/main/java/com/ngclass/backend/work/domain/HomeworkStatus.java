package com.ngclass.backend.work.domain;

/** One pupil's state for one homework (spec 06, statuses). CORRECTED comes with the correction step. */
public enum HomeworkStatus {
	TODO,
	SUBMITTED,
	LATE,
	MISSING,
	CORRECTED
}

package org.xmf.annot

import java.lang.annotation.Retention
import java.lang.annotation.Target

@Target(METHOD)
@Retention(SOURCE)
annotation Operation {}

@Target(FIELD)
@Retention(SOURCE)
annotation Opposite {
	/** attribute name in the target type */
	String value
}

@Target(TYPE)
@Retention(SOURCE)
annotation XPackage {
	String value // eNS_URI
}

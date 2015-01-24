package org.xmf.annot

import java.lang.annotation.Retention
import java.lang.annotation.Target

@Target(FIELD)
@Retention(SOURCE)
annotation OppositeOf {
	/** attribute name in the target type */
	String value
}

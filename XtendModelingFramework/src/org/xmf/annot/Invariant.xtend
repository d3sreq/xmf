package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import org.xmf.annot.compile.InvariantCompilationParticipant

@Target(METHOD)
@Retention(SOURCE)
@Active(InvariantCompilationParticipant)
@Beta
annotation Invariant {
	/** Error message when violated */
	String value
}

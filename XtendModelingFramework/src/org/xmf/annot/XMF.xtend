package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import org.xmf.annot.compile.XmfCompilationParticipant

// ===============================================================================
// Active Annotation best practices
// http://mnmlst-dvlpr.blogspot.de/2013/06/active-annotation-best-practices.html
// ===============================================================================

@Beta
@Target(TYPE)
@Retention(SOURCE)
@Active(XmfCompilationParticipant)
annotation XMF {}

package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active

@Active(AttributeCompilationParticipant)
@Target(FIELD)
@Retention(SOURCE)
@Beta
annotation ID {}
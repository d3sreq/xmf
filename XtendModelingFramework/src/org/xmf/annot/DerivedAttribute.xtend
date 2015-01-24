package org.xmf.annot

import java.lang.annotation.Retention
import java.lang.annotation.Target
import com.google.common.annotations.Beta

@Beta
@Target(METHOD)
@Retention(SOURCE)
annotation DerivedAttribute {}
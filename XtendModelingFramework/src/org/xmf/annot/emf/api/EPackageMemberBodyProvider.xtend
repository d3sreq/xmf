package org.xmf.annot.emf.api

import org.eclipse.xtend2.lib.StringConcatenationClient

interface EPackageMemberBodyProvider {
	def StringConcatenationClient defaultValueInitializer()
	def StringConcatenationClient cachedValueInitializer()
	def StringConcatenationClient getterMethod()
	def StringConcatenationClient setterMethod()
	def StringConcatenationClient basicGetterMethod()
	def StringConcatenationClient basicSetterMethod()
}

package org.xmf.features.api

import org.eclipse.xtend2.lib.StringConcatenationClient

/**
 * Templates for various switch cases inside generated method.
 */
interface EPackageCaseFragmentProvider {
	def StringConcatenationClient eInverseRemove()
	def StringConcatenationClient eGet()
	def StringConcatenationClient eSet()
	def StringConcatenationClient eUnset()
	def StringConcatenationClient eIsSet()
	
}